local serviceAccount(serviceAccountName) = {
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: serviceAccountName,
    namespace: std.extVar('qbec.io/defaultNs'),
  },
};

{
  serviceAccount:: serviceAccount,
}
