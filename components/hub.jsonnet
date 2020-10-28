local params = import '../params.libsonnet';
local pdb = import 'pdb.libsonnet';
local role = import 'role.libsonnet';
local rolebinding = import 'rolebinding.libsonnet';
local service = import 'service.libsonnet';
local serviceAccount = import 'serviceaccount.libsonnet';

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

local hubServiceAccount = serviceAccount.serviceAccount(hub.name);

local hubRole = role.role(hub.name, [
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
local hubRoleBinding = rolebinding.roleBinding(hub.name, hub.name, hub.name);

local hubPorts = [{
  name: 'http',
  port: 8081,
  targetPort: 8081,
  protocol: 'TCP',
}];
local hubSvc = service.service(hub.name, { component: hub.name }, hubPorts, 'ClusterIP');
local hubConfigmap = {
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'hub-config',
  },
  data: {
    'jupyterhub_config.py': if params.components.namespace.istio == 'disabled' then importstr 'hub/files/jupyterhub_config.py' else
      importstr 'hub/files/jupyterhub_config_istio.py',
    'z2jh.py': importstr 'hub/files/z2jh.py',
    'values.yaml': std.manifestYamlDoc({ hub: params.components.hub, auth: params.global.auth, singleuser: params.global.singleuser, debug: params.global.debug }),
  },
};

local deployment = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: hub.name,
    labels: {
      app: 'jupyter',
      component: hub.name,
    },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: {
        app: 'jupyter',
        component: hub.name,
      },
    },
    strategy: {
      type: hub.deploymentStrategy,
    },
    template: {
      metadata: {
        labels: {
          app: 'jupyter',
          component: hub.name,
        },
        annotations: {
          'checksum/config-map': std.md5(std.manifestYamlDoc(hubConfigmap)),
        },
      },
      spec: {
        serviceAccountName: hub.name,
        securityContext: {
          fsGroup: hub.fsGid,
        },
        containers: [
          {
            name: hub.name,
            image: hub.image.name + ':' + hub.image.tag,
            command: [
              'jupyterhub',
              '--config',
              '/etc/jupyterhub/jupyterhub_config.py',
              '--upgrade-db',
            ],
            env: [
              {
                name: 'CONFIGPROXY_AUTH_TOKEN',
                valueFrom: {
                  secretKeyRef: {
                    name: 'hub-secret',
                    key: 'proxy.token',
                  },
                },
              },
              {
                name: 'PYTHONUNBUFFERED',
                value: '1',
              },
              {
                name: 'POD_NAMESPACE',
                valueFrom: {
                  fieldRef: {
                    apiVersion: 'v1',
                    fieldPath: 'metadata.namespace',
                  },
                },
              },
            ],
            ports: [
              {
                containerPort: 8080,
                name: hub.name,
              },
            ],
            resources: hub.resources,
            securityContext: {
              allowPrivilegeEscalation: false,
              runAsUser: hub.uid,
            },
            volumeMounts: [
              {
                mountPath: '/etc/jupyterhub/config/values.yaml',
                name: 'config',
                subPath: 'values.yaml',
              },
              {
                mountPath: '/etc/jupyterhub/secret/',
                name: 'secret',
              },
              {
                mountPath: '/etc/jupyterhub/z2jh.py',
                name: 'config',
                subPath: 'z2jh.py',
              },
              {
                mountPath: '/etc/jupyterhub/jupyterhub_config.py',
                name: 'config',
                subPath: 'jupyterhub_config.py',
              },
              {
                mountPath: '/etc/jupyterhub/cull_idle_servers.py',
                name: 'config',
                subPath: 'cull_idle_servers.py',
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'config',
            configMap: {
              name: 'hub-config',
            },
          },
          {
            name: 'secret',
            secret: {
              secretName: 'hub-secret',
            },
          },
        ],
      },
    },
  },
};
[hubPdb, secret, hubServiceAccount, hubRole, hubRoleBinding, hubSvc, hubConfigmap, deployment]
