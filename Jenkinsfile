pipeline {
  agent any

  options {
    timestamps()
    ansiColor('xterm')
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  environment {
    IMAGE_LOCAL     = "jenkins-cicd-demo-app"
    IMAGE_REMOTE    = "davidangyu/jenkins-cicd-demo-app"
    REGISTRY_URL    = "https://index.docker.io/v1/"
    DOCKER_CREDS    = "dockerhub-creds"
    KUBECONFIG_CRED = "kubeconfig-kind"   // Jenkins credential type: "Secret file"
    APP_PORT        = "3000"
    K8S_DIR         = "k8s"
    DEPLOYMENT_NAME = "jenkins-cicd-demo"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          set -e
          docker build -t "$IMAGE_LOCAL:$BUILD_NUMBER" .
        '''
      }
    }

    stage('Tag & Push (DockerHub)') {
      steps {
        script {
          docker.withRegistry(env.REGISTRY_URL, env.DOCKER_CREDS) {
            sh '''
              set -e
              docker tag "$IMAGE_LOCAL:$BUILD_NUMBER" "$IMAGE_REMOTE:$BUILD_NUMBER"
              docker tag "$IMAGE_LOCAL:$BUILD_NUMBER" "$IMAGE_REMOTE:latest"
              docker push "$IMAGE_REMOTE:$BUILD_NUMBER"
              docker push "$IMAGE_REMOTE:latest"
            '''
          }
        }
      }
    }

    stage('Smoke Test (local container)') {
      steps {
        sh '''
          set -e
          NAME="demo-$BUILD_NUMBER"
          docker rm -f "$NAME" >/dev/null 2>&1 || true
          docker run -d --name "$NAME" -p "$APP_PORT:$APP_PORT" "$IMAGE_LOCAL:$BUILD_NUMBER"
          sleep 2
          curl -s "http://localhost:$APP_PORT" | head -c 200 || (docker logs "$NAME" || true; exit 1)
          docker rm -f "$NAME"
        '''
      }
    }

    stage('Deploy to Kubernetes (KIND)') {
      steps {
        withCredentials([file(credentialsId: "${KUBECONFIG_CRED}", variable: 'KUBECONFIG')]) {
          sh '''
            set -e

            echo "== Kubeconfig being used =="
            grep -n "server:\\|insecure-skip-tls-verify" "$KUBECONFIG" || true

            echo "== Cluster connectivity check =="
            kubectl --kubeconfig "$KUBECONFIG" get nodes

            echo "== Apply manifests =="
            # --validate=false avoids OpenAPI fetch issues in KIND when API hostname differs (host.docker.internal vs localhost)
            kubectl --kubeconfig "$KUBECONFIG" apply --validate=false -f "$K8S_DIR/"

            echo "== Rollout status =="
            kubectl --kubeconfig "$KUBECONFIG" rollout status "deployment/$DEPLOYMENT_NAME" --timeout=180s

            echo "== Service/Pods snapshot =="
            kubectl --kubeconfig "$KUBECONFIG" get svc,pods -o wide
          '''
        }
      }
    }
  }

  post {
    always {
      sh '''
        set +e
        docker rm -f "demo-$BUILD_NUMBER" >/dev/null 2>&1 || true
      '''
    }
    success {
      echo "✅ Pipeline completed successfully."
    }
    failure {
      echo "❌ Pipeline failed. Check the stage logs above."
    }
  }
}
