local params = import '../params.libsonnet';
local pdb = import 'pdb.libsonnet';
local service = import 'service.libsonnet';

local proxy = params.components.proxy;

local proxyPdb = pdb.pdb(proxy);

local publicPorts = [{
  name: 'https',
  port: 443,
  targetPort: 443,
  protocol: 'TCP',
}, {
  name: 'http',
  port: 80,
  targetPort: 8000,
  protocol: 'TCP',
}];

local apiPorts = [{
  name: 'http',
  port: 8001,
  targetPort: 8001,
  protocol: 'TCP',
}];
local proxyPublicSvc = service.service('proxy-public', { component: proxy.name }, publicPorts, 'LoadBalancer');
local proxyApiSvc = service.service('proxy-api', { component: proxy.name }, apiPorts, 'ClusterIP');

local deployment = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: proxy.name,
    labels: {
      app: 'jupyter',
      component: proxy.name,
    },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: {
        app: 'jupyter',
        component: proxy.name,
      },
    },
    strategy: {
      type: 'Recreate',
    },
    template: {
      metadata: {
        labels: {
          app: 'jupyter',
          component: proxy.name,
        },
      },
      spec: {
        containers: [
          {
            name: 'proxy',
            image: 'jupyterhub/configurable-http-proxy:4.2.1',
            command: [
              'configurable-http-proxy',
              '--ip=0.0.0.0',
              '--api-ip=0.0.0.0',
              '--api-port=8001',
              '--default-target=http://$(HUB_SERVICE_HOST):$(HUB_SERVICE_PORT)',
              '--error-target=http://$(HUB_SERVICE_HOST):$(HUB_SERVICE_PORT)/hub/error',
              '--port=8000',
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
            ],
            ports: [
              {
                containerPort: 8001,
                name: 'proxy-api',
              },
              {
                containerPort: 8000,
                name: 'proxy-public',
              },
            ],
            resources: {
              cpu: '200m',
              memory: '512Mi',
            },
            securityContext: {
              allowPrivilegeEscalation: false,
            },
          },
        ],
      },
    },
  },
};


[proxyPdb, proxyPublicSvc, proxyApiSvc, deployment]
