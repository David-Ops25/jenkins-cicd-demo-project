pipeline {
  agent any

  environment {
    // Kubeconfig inside Jenkins container
    KUBECONFIG = '/var/jenkins_home/.kube/config.jenkins'

    // App / image settings
    APP_NAME = 'jenkins-cicd-demo-project'
    IMAGE_TAG = "${BUILD_NUMBER}"

    // Kubernetes manifests directory
    K8S_DIR = 'k8s'

    // Set this ONLY if you want to push to Docker Hub later
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
        sh '''
          echo "Commit:"
          git log -1 --oneline
        '''
      }
    }

    stage('Tooling Debug') {
      steps {
        sh '''
          set -e
          echo "=== Jenkins runtime ==="
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
          echo "=== Build Docker image ==="
          docker build -t ${APP_NAME}:${IMAGE_TAG} .
          docker images | head -n 10
        '''
      }
    }

    stage('Load Image into kind') {
      steps {
        sh '''
          set -e
          echo "=== Load image into kind ==="

          if ! command -v kind >/dev/null 2>&1; then
            echo "Installing kind..."
            curl -L -o /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
            chmod +x /usr/local/bin/kind
          fi

          kind version
          kind load docker-image ${APP_NAME}:${IMAGE_TAG} --name devops-lab
        '''
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
          set -e
          echo "=== Deploy to Kubernetes ==="

          test -d "${K8S_DIR}" || (echo "Missing ${K8S_DIR}/ directory" && exit 1)

          kubectl apply -f "${K8S_DIR}/"

          DEPLOY_NAME=$(kubectl get deploy -o jsonpath='{.items[0].metadata.name}')
          CONTAINER_NAME=$(kubectl get deploy "$DEPLOY_NAME" -o jsonpath='{.spec.template.spec.containers[0].name}')

          echo "Deployment: $DEPLOY_NAME"
          echo "Container:  $CONTAINER_NAME"

          if [ -n "${DOCKERHUB_REPO}" ]; then
            NEW_IMAGE="${DOCKERHUB_REPO}:${IMAGE_TAG}"
          else
            NEW_IMAGE="${APP_NAME}:${IMAGE_TAG}"
          fi

          echo "Setting image to: $NEW_IMAGE"
          kubectl set image deployment/"$DEPLOY_NAME" "$CONTAINER_NAME"="$NEW_IMAGE"

          kubectl rollout status deployment/"$DEPLOY_NAME" --timeout=180s

          echo "=== Cluster resources ==="
          kubectl get deploy,po,svc -o wide
        '''
      }
    }
  }

  post {
    always {
      sh '''
        echo "=== Final cluster snapshot ==="
        kubectl get pods -o wide || true
        kubectl get svc -o wide || true
      '''
    }
  }
}
