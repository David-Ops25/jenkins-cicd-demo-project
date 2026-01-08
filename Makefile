SHELL := /bin/bash

KIND_CLUSTER ?= devops-lab
IMAGE ?= jenkins-cicd-demo-project:local
NAMESPACE ?= default

.PHONY: help kind-up kind-down build load deploy rollout port-forward smoke

help:
	@echo "Targets:"
	@echo "  build         Build Docker image"
	@echo "  kind-up       Create kind cluster"
	@echo "  kind-down     Delete kind cluster"
	@echo "  load          Load image into kind"
	@echo "  deploy        Apply Kubernetes manifests"
	@echo "  rollout       Wait for deployment rollout"
	@echo "  port-forward  Port-forward service to localhost:8081"
	@echo "  smoke         Curl the app through port-forward (requires port-forward running)"

kind-up:
	kind create cluster --name $(KIND_CLUSTER) || true
	kubectl config use-context kind-$(KIND_CLUSTER)

kind-down:
	kind delete cluster --name $(KIND_CLUSTER)

build:
	docker build -t $(IMAGE) .

load:
	kind load docker-image $(IMAGE) --name $(KIND_CLUSTER)

deploy:
	kubectl apply -f k8s/

rollout:
	kubectl rollout status deployment/jenkins-cicd-demo --timeout=180s

port-forward:
	kubectl port-forward svc/jenkins-cicd-demo-svc 8081:80

smoke:
	curl -i http://localhost:8081
