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
