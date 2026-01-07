pipeline {
  agent any

  environment {
    KUBECONFIG = '/var/jenkins_home/.kube/config.jenkins'
    APP_NAME  = 'jenkins-cicd-demo-project'
    IMAGE_TAG = "${BUILD_NUMBER}"
    K8S_DIR   = 'k8s'
    DOCKERHUB_REPO = ''
  }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        sh 'git log -1 --oneline'
      }
    }

    stage('Tooling Debug') {
      steps {
        sh '''
          set -e
          echo "=== Runtime ==="
          whoami
          uname -a

          echo "=== Docker ==="
          docker --version
          docker ps

          echo "=== Kubernetes ==="
          kubectl version --client
          kubectl config current-context
          kubectl get nodes
          kubectl get ns
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          set -e
          docker build -t ${APP_NAME}:${IMAGE_TAG} .
        '''
      }
    }

    stage('Load Image into kind') {
      steps {
        sh '''
          set -e
          echo "=== Load image into kind ==="
          KIND_BIN="/tmp/kind"

          if [ ! -x "$KIND_BIN" ]; then
            echo "Installing kind to $KIND_BIN ..."
            curl -L -o "$KIND_BIN" https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
            chmod +x "$KIND_BIN"
          fi

          "$KIND_BIN" version
          "$KIND_BIN" load docker-image ${APP_NAME}:${IMAGE_TAG} --name devops-lab
        '''
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
          set -e
          echo "=== Deploy ==="

          kubectl apply -f "${K8S_DIR}/"

          DEPLOY=$(kubectl get deploy -o jsonpath='{.items[0].metadata.name}')
          CONTAINER=$(kubectl get deploy "$DEPLOY" -o jsonpath='{.spec.template.spec.containers[0].name}')

          echo "Deployment: $DEPLOY"
          echo "Container:  $CONTAINER"

          kubectl set image deployment/"$DEPLOY" "$CONTAINER"="${APP_NAME}:${IMAGE_TAG}"
          kubectl rollout status deployment/"$DEPLOY" --timeout=180s

          kubectl get deploy,po,svc -o wide
        '''
      }
    }
  }

  post {
    always {
      sh '''
        echo "=== Final snapshot ==="
        kubectl get pods -o wide || true
        kubectl get svc -o wide || true
      '''
    }
  }
}
