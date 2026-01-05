pipeline {
  agent any

  environment {
    IMAGE_NAME = "jenkins-cicd-demo-app"
    IMAGE_TAG  = "${BUILD_NUMBER}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
      }
    }

    stage('Smoke Test') {
      steps {
        sh '''
          docker rm -f demo-$BUILD_NUMBER >/dev/null 2>&1 || true
          docker run -d --name demo-$BUILD_NUMBER -p 3000:3000 $IMAGE_NAME:$IMAGE_TAG
          sleep 2
          curl -s http://localhost:3000 | head -c 200
          docker rm -f demo-$BUILD_NUMBER
        '''
      }
    }
  }
}
