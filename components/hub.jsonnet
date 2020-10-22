local params = import '../params.libsonnet';
local pdb = import 'pdb.libsonnet';
local role = import 'role.libsonnet';
local rolebinding = import 'rolebinding.libsonnet';
local serviceAccount = import 'serviceaccount.libsonnet';
local service = import 'service.libsonnet';

local hub = params.components.hub;
local hubPdb = pdb.pdb(hub);

local secret = {
  apiVersion: 'v1',
  kind: 'Secret',
  type: 'Opaque',
  metadata: {
    namespace: std.extVar('qbec.io/defaultNs'),
    name: 'hub-secret',
  },
  data: {
    'proxy.token': std.base64(hub.secretToken),
  },
};

local hubServiceAccount = serviceAccount.serviceAccount('hub');

local hubRole = role.role('hub', [
  {
    apiGroups: [
      '',
    ],
    resources: [
      'pods',
      'services',
      'persistentvolumeclaims',
    ],
    verbs: [
      'get',
      'watch',
      'list',
      'create',
      'delete',
      'patch',
    ],
  },
  {
    apiGroups: [
      '',
    ],
    resources: [
      'events',
      'configmaps',
      'secrets',
    ],
    verbs: [
      'get',
      'watch',
      'list',
    ],
  },
]);
local hubRoleBinding = rolebinding.roleBinding('hub', 'hub', 'hub');

local hubPorts = [{
  name: 'http',
  port: 8081,
  targetPort: 8081,
  protocol: 'TCP',
}];
local hubSvc = service.service('hub', { component: hub.name }, hubPorts, 'ClusterIP');

[hubPdb, secret, hubServiceAccount, hubRole, hubRoleBinding,hubSvc]
