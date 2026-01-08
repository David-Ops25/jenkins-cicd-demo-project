# Troubleshooting

These are the most common issues encountered when running Jenkins + Docker + kind locally (and why they happen).

## 1) NodePort not reachable on localhost (kind)

**Symptom**
```text
curl: (7) Failed to connect to localhost port 30080
```

**Cause**
kind runs Kubernetes nodes inside Docker containers. A NodePort may not be mapped to the host loopback (`localhost`) depending on your Docker/WSL networking.

**Fix**
Use port-forward (recommended):
```bash
kubectl port-forward svc/jenkins-cicd-demo-svc 8081:80
curl -i http://localhost:8081
```

If you want NodePort specifically, curl the kind node container IP:
```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' devops-lab-control-plane
curl -i http://<NODE_IP>:30080
```

## 2) ImagePullBackOff

**Cause**
Kubernetes can’t pull your image from a registry, or the image doesn’t exist on the node.

**Fix (local kind workflow)**
Load the image into kind:
```bash
kind load docker-image jenkins-cicd-demo-project:<TAG> --name devops-lab
```

## 3) Jenkins in Docker can’t run docker builds

**Cause**
Jenkins container needs access to the Docker daemon (socket) or a dedicated build strategy.

**Fix**
Mount the Docker socket into the Jenkins container:
```bash
-v /var/run/docker.sock:/var/run/docker.sock
```

## 4) kubectl context/kubeconfig not found in Jenkins

**Cause**
CI container doesn’t have kubeconfig or wrong context.

**Fix**
Mount kubeconfig or create a dedicated service account + kubeconfig for Jenkins (recommended in real environments).
At minimum, verify:
```bash
kubectl config current-context
kubectl get nodes
```
