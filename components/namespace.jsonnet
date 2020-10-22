local params = import '../params.libsonnet';
local namespace = {
  apiVersion: 'v1',
  kind: 'Namespace',
  metadata: {
    name: std.extVar('qbec.io/defaultNs'),
    labels: {
      'istio-injection': params.components.namespace.istio,
    },
  },
};

local peerAuthentication = if params.components.namespace.istio == 'enabled' then
  {
    apiVersion: 'security.istio.io/v1beta1',
    kind: 'PeerAuthentication',
    metadata: {
      name: 'default',
      namespace: std.extVar('qbec.io/defaultNs'),
    },
    spec: {
      mtls: {
        mode: 'STRICT',
      },
    },
  }
else {};

[namespace, peerAuthentication]
