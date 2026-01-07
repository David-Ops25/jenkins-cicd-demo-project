// Jenkinsfile (Declarative)
// Works for: Jenkins running in Docker with ports mapped (-p 8080:8080)
// and kubeconfig patched to: /var/jenkins_home/.kube/config.jenkins
//
// IMPORTANT (one-time setup you already started):
// 1) Mount ~/.kube into Jenkins: -v ~/.kube:/var/jenkins_home/.kube
// 2) Create /var/jenkins_home/.kube/config.jenkins inside the container by replacing 127.0.0.1 -> host.docker.internal
// 3) Ensure kubectl exists in the Jenkins container
//
// Optional (if you want Docker push):
// - Add Jenkins credential (Username/Password) with ID = dockerhub-creds
// - Set DOCKERHUB_REPO env below to something like "yourdockerhubuser/jenkins-cicd-demo-project"

pipeline {
  agent any

  environment {
    // This is the “add-on” that fixes kind access from inside Jenkins container
    KUBECONFIG = '/var/jenkins_home/.kube/config.jenkins'

    // --- App / Image settings (edit to match your repo/manifests) ---
    APP_NAME = 'jenkins-cicd-demo-project'
    IMAGE_TAG = "${env.BUILD_NUMBER}"

    // If you want to push to Docker Hub (recommended for real clusters):
    // DOCKERHUB_REPO = 'yourdockerhubuser/jenkins-cicd-demo-project'
    // If DOCKERHUB_REPO is empty, pipeline will NOT push.
    DOCKERHUB_REPO = ''
    DOCKERHUB_CREDS_ID = 'dockerhub-creds'

    // Kubernetes manifests folder
    K8S_DIR = 'k8s'
  }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        sh 'echo "Branch: $(git rev-parse --abbrev-ref HEAD)"; git log -1 --oneline'
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
          docker version || true
          docker info || true

          echo "=== Kubectl / Kubeconfig ==="
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
          echo "=== Build image ==="
          ls -la

          # Build from repo Dockerfile
          docker build -t ${APP_NAME}:${IMAGE_TAG} .

          echo "Built: ${APP_NAME}:${IMAGE_TAG}"
          docker images | head -n 20
        '''
      }
    }

    stage('Push Image (optional)') {
      when {
        expression { return env.DOCKERHUB_REPO?.trim() }
      }
      steps {
        withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDS_ID}", usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
          sh '''
            set -e
            echo "=== Docker login ==="
            echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin

            echo "=== Tag & push ==="
            docker tag ${APP_NAME}:${IMAGE_TAG} ${DOCKERHUB_REPO}:${IMAGE_TAG}
            docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}

            echo "Pushed: ${DOCKERHUB_REPO}:${IMAGE_TAG}"
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
          set -e
          echo "=== Deploy ==="
          test -d "${K8S_DIR}" || (echo "Missing ${K8S_DIR}/ directory" && exit 1)

          echo "Manifests:"
          ls -la "${K8S_DIR}"

          # If you pushed an image, patch the deployment image to the pushed tag.
          # If you did NOT push, your deployment.yaml must already reference an image your cluster can pull.
          if [ -n "${DOCKERHUB_REPO}" ]; then
            echo "Patching deployment to use image: ${DOCKERHUB_REPO}:${IMAGE_TAG}"

            # Apply first to ensure the Deployment exists, then set image
            kubectl apply -f "${K8S_DIR}/"

            DEPLOY_NAME=$(kubectl get deploy -o jsonpath='{.items[0].metadata.name}')
            CONTAINER_NAME=$(kubectl get deploy "$DEPLOY_NAME" -o jsonpath='{.spec.template.spec.containers[0].name}')

            echo "Detected deployment: $DEPLOY_NAME"
            echo "Detected container:  $CONTAINER_NAME"

            kubectl set image deployment/"$DEPLOY_NAME" "$CONTAINER_NAME"="${DOCKERHUB_REPO}:${IMAGE_TAG}" --record
          else
            echo "DOCKERHUB_REPO is empty, so no image patching will be done."
            echo "Your k8s/deployment.yaml must reference an image the cluster can pull."
            kubectl apply -f "${K8S_DIR}/"
          fi

          echo "=== Rollout status (auto-detect) ==="
          DEPLOY_NAME=$(kubectl get deploy -o jsonpath='{.items[0].metadata.name}')
          kubectl rollout status deployment/"$DEPLOY_NAME" --timeout=180s

          echo "=== Current resources ==="
          kubectl get deploy,po,svc -o wide
        '''
      }
    }
  }

  post {
    always {
      sh '''
        echo "=== Post: cluster snapshot ==="
        kubectl get pods -o wide || true
        kubectl get svc -o wide || true
      '''
    }
  }
}
