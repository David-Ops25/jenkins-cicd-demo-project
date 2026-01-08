# Pipeline walkthrough

This doc explains the intent behind the Jenkins pipeline stages and what they prove.

## Stages

### 1) Checkout
Pulls repo source from GitHub.

### 2) Tooling Debug
Prints versions and context:
- `docker --version`
- `kubectl config current-context`
- `kubectl get nodes`

This is not “noise” — it makes CI failures diagnosable.

### 3) Build Docker Image
Builds the application image from `Dockerfile`.

### 4) Load image into kind
Loads the built image into the kind node so Kubernetes can run it without pulling from a registry.

### 5) Deploy to Kubernetes
- `kubectl apply -f k8s/`
- Update Deployment image (current implementation)
- Wait for rollout

### 6) Validate
A real pipeline should validate reachability. With kind, the most reliable check is via port-forward.

## Recommended improvements

- Replace `kubectl set image` with a Git-tracked mechanism (Kustomize/Helm or manifest rendering).
- Push images to a registry with immutable tags (Git SHA).
- Add probes + resource limits.
