local pdb(component) = {
  apiVersion: 'policy/v1beta1',
  kind: 'PodDisruptionBudget',
  metadata: {
    name: component.name,
    namespace: std.extVar('qbec.io/defaultNs'),
  },
  spec: {
    maxUnavailable: component.maxUnavailable,
    selector: {
      matchLabels: {
        app: 'jupyterhub',
        component: component.name,
      },
    },
  },
};
{ pdb: pdb }
