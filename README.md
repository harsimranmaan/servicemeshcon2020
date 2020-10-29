# Used for the ServiceMeshCon NA 2020 demo

For more info on qbec:
[https://github.com/splunk/qbec](https://github.com/splunk/qbec)

Demo based on [https://medium.com/@harsimranmaan/running-jupyterhub-with-istio-service-mesh-on-kubernetes-a-troubleshooting-journey-707039f36a7b](https://medium.com/@harsimranmaan/running-jupyterhub-with-istio-service-mesh-on-kubernetes-a-troubleshooting-journey-707039f36a7b)


## Demo flow
1. Do a stock deployment
2. Build the patched hub images from [Dockerfile](./jh-patch/Dockerfile)
3. Update the hub image tag in [base.libsonnet](./environment/base.libsonnet) L#32 as `tag: '0.9.0-patch',`
4. Deploy with istio enabled on the namespace


To see all components:
```bash
qbec show  default -O
```

Apply the components:

```bash
qbec apply default
```

Diff the changes to be applied when enabling istio:

```bash
qbec diff default --vm:ext-str ISTIO=enabled
```

```bash
qbec apply default --vm:ext-str ISTIO=enabled
```


## Enable/disable istio and PeerAuth

Enable istio on namespace(not needed if running ):
```bash
# Enable
qbec apply default --vm:ext-str ISTIO=enabled -c namespace
# Disable
qbec apply default -c namespace
```
