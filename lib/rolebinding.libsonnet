local roleBinding(name, roleName, serviceAccountName) = {
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: name,
    namespace: std.extVar('qbec.io/defaultNs'),
  },
  subjects: [{
    kind: 'ServiceAccount',
    name: serviceAccountName,
    namespace: std.extVar('qbec.io/defaultNs'),
  }],
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'Role',
    name: roleName,
  },
};
{ roleBinding: roleBinding }
