pipeline {
  agent any

  environment {
    IMAGE_LOCAL   = "jenkins-cicd-demo-app"
    IMAGE_REMOTE  = "davidangyu/jenkins-cicd-demo-app"
    REGISTRY_URL  = "https://index.docker.io/v1/"
    DOCKER_CREDS  = "dockerhub-creds"
  }

  stages {

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_LOCAL:$BUILD_NUMBER .'
      }
    }

    stage('Tag & Push (DockerHub)') {
      steps {
        script {
          docker.withRegistry(env.REGISTRY_URL, env.DOCKER_CREDS) {
            sh '''
              set -e
              docker tag $IMAGE_LOCAL:$BUILD_NUMBER $IMAGE_REMOTE:$BUILD_NUMBER
              docker tag $IMAGE_LOCAL:$BUILD_NUMBER $IMAGE_REMOTE:latest
              docker push $IMAGE_REMOTE:$BUILD_NUMBER
              docker push $IMAGE_REMOTE:latest
            '''
          }
        }
      }
    }

    stage('Smoke Test') {
      steps {
        sh '''
          set -e
          docker rm -f demo-$BUILD_NUMBER >/dev/null 2>&1 || true
          docker run -d --name demo-$BUILD_NUMBER -p 3000:3000 $IMAGE_LOCAL:$BUILD_NUMBER
          sleep 2
          curl -s http://localhost:3000 | head -c 200
          docker rm -f demo-$BUILD_NUMBER
        '''
      }
    }
  }
}
