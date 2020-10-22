local params = import '../params.libsonnet';
local service = import 'service.libsonnet';
local pdb = import 'pdb.libsonnet';

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
[proxyPdb,proxyPublicSvc, proxyApiSvc]
