/**
 * Reusable helper to build and optionally push a Docker image from Jenkins Pipeline.
 *
 * Usage in Jenkinsfile:
 *   def img = load 'scripts/buildImage.groovy'
 *   img.buildAndPush(imageName: 'angyu84/jenkins-cicd-demo-app',
 *                    registryUrl: 'https://index.docker.io/v1/',
 *                    credsId: 'dockerhub-creds',
 *                    push: true)
 */

def buildAndPush(Map args = [:]) {
  String imageName   = args.imageName   ?: error("imageName is required")
  String registryUrl = args.registryUrl ?: ""
  String credsId     = args.credsId     ?: ""
  boolean push       = (args.push != null) ? args.push as boolean : false

  String tag = env.BUILD_NUMBER ?: "local"

  echo "Building Docker image: ${imageName}:${tag}"
  def app = docker.build("${imageName}:${tag}")

  if (push) {
    if (!registryUrl?.trim()) {
      error("registryUrl is required when push=true")
    }
    if (!credsId?.trim()) {
      error("credsId is required when push=true")
    }
    echo "Pushing Docker image to registry: ${registryUrl}"
    docker.withRegistry("${registryUrl}", "${credsId}") {
      app.push("${tag}")
      app.push("latest")
    }
  } else {
    echo "push=false, skipping registry push"
  }

  return app
}

return this
