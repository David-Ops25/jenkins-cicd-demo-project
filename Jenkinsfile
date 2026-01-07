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

    stage('Deploy to K8s') {
      steps {
        sh '''
          echo "=== Deploy ==="
          ls -la
          if [ -d k8s ]; then
            kubectl apply -f k8s/
          elif [ -d kubernetes ]; then
            kubectl apply -f kubernetes/
          else
            echo "No k8s/ or kubernetes/ folder found."
            exit 1
          fi

          echo "=== Status ==="
          kubectl get deploy,po,svc -A
        '''
      }
    }
  }
}
