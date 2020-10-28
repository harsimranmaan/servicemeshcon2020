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
  targetPort: if params.components.namespace.istio == 'disabled' then 8001 else 8000,
  protocol: 'TCP',
}];
local proxyPublicSvc = if params.components.namespace.istio == 'disabled' then service.service('proxy-public', { component: proxy.name }, publicPorts, 'LoadBalancer') else {
  apiVersion: 'networking.istio.io/v1alpha3',
  kind: 'Gateway',
  metadata: {
    name: 'jupyterhub-gateway',
    namespace: std.extVar('qbec.io/defaultNs'),
  },
  spec: {
    selector: {
      istio: 'ingressgateway',  // use istio default controller
    },
    servers: [
      {
        port: {
          number: 80,
          name: 'http',
          protocol: 'HTTP',
        },
        hosts: ['*'],
      },
    ],
  },
};
local proxyApiSvc = service.service('proxy-api', { component: proxy.name }, apiPorts, 'ClusterIP');

local deployment = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: proxy.name,
    namespace: std.extVar('qbec.io/defaultNs'),
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
      type: if params.components.namespace.istio == 'disabled' then 'Recreate' else 'RollingUpdate',
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
            image: if params.components.namespace.istio == 'disabled' then 'jupyterhub/configurable-http-proxy:4.2.1' else 'splunk/jupyterhub-istio-proxy:0.1.0',
            command: if params.components.namespace.istio == 'disabled' then [
              'configurable-http-proxy',
              '--ip=0.0.0.0',
              '--api-ip=0.0.0.0',
              '--api-port=8001',
              '--default-target=http://$(HUB_SERVICE_HOST):$(HUB_SERVICE_PORT)',
              '--error-target=http://$(HUB_SERVICE_HOST):$(HUB_SERVICE_PORT)/hub/error',
              '--port=8000',
            ] else [
              '/proxy/jupyterhub-istio-proxy',
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
            ] + if params.components.namespace.istio == 'enabled' then [
              {
                name: 'ISTIO_GATEWAY',
                value: 'jupyterhub-gateway',
              },
              {
                name: 'K8S_NAMESPACE',
                valueFrom: {
                  fieldRef: {
                    fieldPath: 'metadata.namespace',
                  },
                },
              },
              {
                name: 'SUB_DOMAIN_HOST',
                value: '*',
              },
              {
                name: 'VIRTUAL_SERVICE_PREFIX',
                value: 'jupyterhub',
              },
              {
                name: 'WAIT_FOR_WARMUP',
                value: 'false',
              },
            ] else [],
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
