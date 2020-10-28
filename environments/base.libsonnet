// this file has the baseline default parameters
{
  components: {
    namespace: {
      istio: std.extVar('ISTIO'),
    },
    hub: {
      name: 'hub',
      secretToken: '2030f40d45efca8663a2ad022c540c78ead3f1fee0bde1af3a2569419c3eea46',
      maxUnavailable: 1,
      activeServerLimit: null,
      allowNamedServers: false,
      annotations: {},
      authenticatePrometheus: null,
      baseUrl: '/',
      concurrentSpawnLimit: 64,
      consecutiveFailureLimit: 5,
      db: {
        password: null,
        type: 'sqlite-memory',
        upgrade: null,
        url: null,
      },
      deploymentStrategy: 'Recreate',
      extraConfig: {},
      extraContainers: [],
      extraVolumeMounts: [],
      extraVolumes: [],
      fsGid: 1000,
      image: {
        name: 'jupyterhub/k8s-hub',
        tag: '0.9.0',
      },
      imagePullSecret: {
        email: null,
        enabled: false,
        password: null,
        registry: null,
        username: null,
      },
      initContainers: [],
      labels: {},
      livenessProbe: {

        enabled: false,
        initialDelaySeconds: 30,
        periodSeconds: 10,
      },
      namedServerLimitPerUser: null,
      nodeSelector: {},
      publicURL: null,
      readinessProbe: {
        enabled: true,
        initialDelaySeconds: 0,
        periodSeconds: 10,
      },
      redirectToServer: null,
      resources: {
        requests: {
          cpu: '200m',
          memory: '512Mi',
        },
      },
      service: {
        annotations: {},
        loadBalancerIP: null,
        ports: {
          nodePort: null,
        },
        type: 'ClusterIP',
      },
      services: {},
      shutdownOnLogout: null,
      templatePaths: [],
      templateVars: {},
      uid: 1000,
    },
    proxy: {
      name: 'proxy',
      maxUnavailable: 1,
    },
  },
  global: {
    auth: {
      admin: {
        access: true,
        users: null,
      },
      dummy: {
        password: null,
      },
      state: {
        enabled: false,
      },
      type: 'dummy',
      whitelist: {
        users: null,
      },
    },
    cull: {
      enabled: false,
    },
    debug: {
      enabled: false,
    },
    singleuser: {
      cloudMetadata: {
        enabled: true,
      },
      cmd: 'jupyterhub-singleuser',
      cpu: {
        guarantee: null,
        limit: null,
      },
      defaultUrl: null,
      events: true,
      extraAnnotations: {},
      extraContainers: [],
      extraEnv: {},
      extraLabels: {
        'hub.jupyter.org/network-access-hub': 'true',
      },
      extraNodeAffinity: {
        preferred: [],
        required: [],
      },
      extraPodAffinity: {
        preferred: [],
        required: [],
      },
      extraPodAntiAffinity: {
        preferred: [],
        required: [],
      },
      extraPodConfig: {},
      extraResource: {
        guarantees: {},
        limits: {},
      },
      extraTolerations: [],
      fsGid: 100,
      image: {
        name: 'jupyterhub/k8s-singleuser-sample',
        pullPolicy: 'IfNotPresent',
        tag: '0.9.0',
      },
      imagePullSecret: {
        email: null,
        enabled: false,
        registry: null,
        username: null,
      },
      initContainers: [],
      lifecycleHooks: {},
      memory: {
        guarantee: '1G',
        limit: null,
      },
      serviceAccountName: 'hub',
      startTimeout: 300,
      storage: {
        capacity: '1Gi',
        dynamic: {
          pvcNameTemplate: 'claim-{username}{servername}',
          storageAccessModes: [
            'ReadWriteOnce',
          ],
          storageClass: null,
          volumeNameTemplate: 'volume-{username}{servername}',
          extraLabels: {},
          extraVolumeMounts: [],
          extraVolumes: [],
          homeMountPath: '/home/jovyan',
        },
        homeMountPath: '/home/jovyan',
        static: {
          pvcName: null,
          subPath: '{username}',
        },
        type: 'dynamic',
      },
      uid: 1000,
    },
  },
}
