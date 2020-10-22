local service(name, selector, ports, serviceType='ClusterIP') = {
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: name,
    namespace: std.extVar('qbec.io/defaultNs'),
  },
  spec: {
    ports: ports,
    selector: selector,
    type: serviceType,
  },
};
{ service: service }
