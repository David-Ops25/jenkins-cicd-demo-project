# Architecture

This project demonstrates a simple but realistic CI/CD flow from commit to running workload on Kubernetes.

## CI/CD flow

```mermaid
flowchart LR
  A[Developer pushes to GitHub] --> B[Jenkins Pipeline]
  B --> C[Build Docker image]
  C --> D[Load image into kind cluster]
  D --> E[Apply K8s manifests]
  E --> F[Rollout update]
  F --> G[Smoke test HTTP 200]
```

## Kubernetes resources

```mermaid
flowchart TB
  Svc[Service: NodePort/ClusterIP] --> Pod[Pod: Node.js app]
  Pod --> Dep[Deployment controller]
  Dep --> RS[ReplicaSet]
```

## Local networking note (kind)

With kind, the Kubernetes “node” runs as a Docker container. NodePorts may not bind to host `localhost` the way you expect.
For reliable access during demos and CI checks, prefer:

- `kubectl port-forward svc/<service> <local_port>:<service_port>`

See `docs/TROUBLESHOOTING.md`.
