# Jenkins CI/CD Demo Project (Docker + Kubernetes/kind)

A recruiter-friendly, reproducible CI/CD demo that builds a Node.js app into a Docker image with **Jenkins**, deploys it to **Kubernetes** (via **kind**), and validates that the app is actually reachable.

> This repo is intentionally small, but the workflow mirrors the day-to-day problems teams solve: CI runners building containers, Kubernetes rollouts, service networking, and “pipeline green” vs “app works”.

---

## What this project demonstrates

### ✅ What works today
- **Pipeline**: Jenkins checks out code, builds a Docker image, loads it into a local kind cluster, applies Kubernetes manifests, updates the Deployment image, and waits for rollout completion.
- **Kubernetes**: A `Deployment` runs the app and a `Service` exposes it (NodePort + port-forward for reliable local access).
- **Verification**: A smoke test (HTTP 200) proves the app is reachable.

### Why this is realistic
Local Kubernetes in containers (kind) frequently surfaces real-world issues:
- Docker-in-Docker and permissions
- kubeconfig/context problems from CI containers
- ImagePullBackOff vs local images
- NodePort “works in YAML” but not from `localhost`

---

## Repository layout

```text
.
├── app/                 # Node.js demo API
├── k8s/                 # Kubernetes manifests (Deployment + Service)
├── scripts/             # Helper scripts
├── Dockerfile           # App image
├── Dockerfile.jenkins   # Jenkins image (tooling baked in)
├── Jenkinsfile          # CI/CD pipeline
└── docs/                # Professional documentation (added in this pack)
```

---

## Prerequisites

- Docker
- kubectl
- kind
- (Optional) Jenkins running in Docker, using the provided `Dockerfile.jenkins`

---

## Quick start (local, without Jenkins)

### 1) Build image
```bash
docker build -t jenkins-cicd-demo-project:local .
```

### 2) Create kind cluster (if you don't already have one)
```bash
kind create cluster --name devops-lab
kubectl config use-context kind-devops-lab
```

### 3) Load image into kind + deploy
```bash
kind load docker-image jenkins-cicd-demo-project:local --name devops-lab
kubectl apply -f k8s/
kubectl rollout status deploy/jenkins-cicd-demo --timeout=180s
```

### 4) Access the app (recommended)
**Port-forward (most reliable with kind):**
```bash
kubectl port-forward svc/jenkins-cicd-demo-svc 8081:80
curl -i http://localhost:8081
```

---

## Run with Jenkins (CI/CD)

### High-level pipeline stages
1. Checkout
2. Tooling debug (prints versions + contexts)
3. Build Docker image
4. Load image into kind
5. Deploy manifests
6. Update image + wait for rollout
7. (Optional) Smoke test

See: **docs/PIPELINE-WALKTHROUGH.md**

---

## Common commands used (audit trail)

All commands used while building/debugging this repo are captured in:
- **docs/COMMANDS.md**
- **docs/TROUBLESHOOTING.md**

This makes it easy for reviewers to understand what was run and why.

---

## Next improvements (roadmap)

These are the “production-style” upgrades that real teams care about:

1. **Health probes**: readiness/liveness probes (K8s)
2. **Resource limits**: CPU/memory requests & limits
3. **Security context**: runAsNonRoot, drop capabilities, read-only FS (where possible)
4. **Remove `kubectl set image`**: make Git the source of truth via Kustomize/Helm or manifest templating
5. **Push to a registry**: Docker Hub/GHCR with immutable tags (Git SHA)
6. **Automated quality gates**: lint/tests + vulnerability scanning (Trivy)

---

## License

MIT (see `LICENSE`)
