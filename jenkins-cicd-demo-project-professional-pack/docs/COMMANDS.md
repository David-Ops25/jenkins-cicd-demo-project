# Command log (what I actually ran)

This file is an audit trail of common commands used while building and verifying this repo.

## Repo
```bash
cd ~/jenkins-cicd-demo-project
ls
```

## Docker build
```bash
docker build -t jenkins-cicd-demo-project:<TAG> .
docker images | head
```

## kind cluster
```bash
kind create cluster --name devops-lab
kubectl config use-context kind-devops-lab
kubectl get nodes
```

## Load image into kind
```bash
kind load docker-image jenkins-cicd-demo-project:<TAG> --name devops-lab
```

## Deploy to Kubernetes
```bash
kubectl apply -f k8s/
kubectl rollout status deployment/jenkins-cicd-demo --timeout=180s
kubectl get deploy,po,svc -o wide
```

## Service wiring checks
```bash
kubectl get svc jenkins-cicd-demo-svc -o yaml
kubectl get endpoints jenkins-cicd-demo-svc -o yaml
```

## Access the app (recommended)
```bash
kubectl port-forward svc/jenkins-cicd-demo-svc 8081:80
curl -i http://localhost:8081
```

## Debugging pods
```bash
kubectl logs deploy/jenkins-cicd-demo --tail=100
kubectl describe pod <pod-name>
kubectl exec -it deploy/jenkins-cicd-demo -- sh
```

## Pipeline tooling debug (example)
```bash
whoami
uname -a
docker --version
kubectl version --client
kubectl config current-context
```
