pipeline {
  agent any

  options {
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('K8s Debug') {
      steps {
        sh '''
          echo "=== K8s Debug ==="
          whoami
          kubectl version --client
          kubectl config current-context
          kubectl get nodes
          kubectl get ns
        '''
      }
    }

    stage('Deploy to Kind') {
      steps {
        sh '''
          echo "=== Apply manifests ==="
          kubectl apply -f k8s/

          echo "=== Wait for rollout (auto-detect deployment) ==="
          DEPLOY_NAME=$(kubectl get deploy -o jsonpath='{.items[0].metadata.name}')
          echo "Deployment detected: $DEPLOY_NAME"
          kubectl rollout status deployment/$DEPLOY_NAME --timeout=180s

          echo "=== Resources ==="
          kubectl get deploy,po,svc -o wide
        '''
      }
    }
  }

  post {
    always {
      sh 'kubectl get pods -o wide || true'
    }
  }
}
