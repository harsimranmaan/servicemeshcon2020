// this file has the baseline default parameters
{
  components: {
    namespace: {
      istio: 'disabled',
    },
    hub: {
      name: 'hub',
      secretToken: '2030f40d45efca8663a2ad022c540c78ead3f1fee0bde1af3a2569419c3eea46',
      maxUnavailable: 1,
    },
    proxy: {
      name: 'proxy',
      maxUnavailable: 1,
    },
  },
}
