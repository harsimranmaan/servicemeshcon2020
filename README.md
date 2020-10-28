# Used for the ServiceMeshCon NA 2020 demo

For more info on qbec:
[https://github.com/splunk/qbec](https://github.com/splunk/qbec)

Demo based on [https://medium.com/@harsimranmaan/running-jupyterhub-with-istio-service-mesh-on-kubernetes-a-troubleshooting-journey-707039f36a7b](https://medium.com/@harsimranmaan/running-jupyterhub-with-istio-service-mesh-on-kubernetes-a-troubleshooting-journey-707039f36a7b)

To see all components:
```bash
qbec show  default -O
```

Apply the components:

```bash
qbec apply default
```

Enable istio on namespace:
```bash
qbec diff default --vm:ext-str ISTIO=enabled -c namespace
qbec apply default --vm:ext-str ISTIO=enabled -c namespace
```

Diff with istio:

```bash
qbec diff default --vm:ext-str ISTIO=enabled
```

```bash
qbec apply default --vm:ext-str ISTIO=enabled
```
