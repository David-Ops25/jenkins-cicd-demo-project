pipeline {
  agent any

  environment {
    IMAGE_NAME = "jenkins-cicd-demo-app"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build Docker Image') {
      steps {
        script {
          def img = load 'scripts/buildImage.groovy'
          img.buildAndPush(
            imageName: env.IMAGE_NAME,
            push: false
          )
        }
      }
    }

    stage('Smoke Test') {
      steps {
        sh '''
          docker rm -f demo-$BUILD_NUMBER >/dev/null 2>&1 || true
          docker run -d --name demo-$BUILD_NUMBER -p 3000:3000 $IMAGE_NAME:$BUILD_NUMBER
          sleep 2
          curl -s http://localhost:3000 | head -c 200
          docker rm -f demo-$BUILD_NUMBER
        '''
      }
    }
  }
}
