local role(name, rules) = {
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: name,
    namespace: std.extVar('qbec.io/defaultNs'),
  },
  rules: rules,
};
{ role: role }
