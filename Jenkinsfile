pipeline {
  agent any
  triggers { pollSCM('H/5 * * * *') }
  options {
    buildDiscarder(logRotator(numToKeepStr: '3'))
    timeout(time: 1, unit: 'HOURS')
  }

  environment {
    // This is the git branch we consider 'latest'
    MAINLINE_BRANCH = "master"

    // Define the package name that gets built
    PACKAGE_NAME="tomcat-ecs"

    // Docker [ECR] registry for publishing images to
    PUBLISH_REGISTRY="https://200237713294.dkr.ecr.us-east-1.amazonaws.com"
    PUBLISH_NAME="200237713294.dkr.ecr.us-east-1.amazonaws.com"
    ECR_USER="awsecr"
    TARGET_VERSION="1.0"

    // ECS constants
    ECS_SERVICE_ROLE="app-ecs"
    EXECUTION_ROLE_RAW="arn:aws:iam::200237713294:role"
    CLUSTER_NAME="tf-ecs-cluster"
    FAMILY="app"
    SERVICE_NAME="tf-ecs-service"
    APP_PORT=8080
    MEMORY=512
    CPU=256
    AWS_REGION="us-east-1"
  }

  stages {
    stage('Build') {
      steps {
        sh """
        docker build \
          --build-arg BUILD_DATE="\$(date -u +%Y-%m-%dT%T%z)" \
          --build-arg VCS_REF="${env.GIT_COMMIT}" \
          --build-arg VCS_URL="${env.GIT_URL}" \
          --build-arg VERSION="${env.GIT_COMMIT}" \
          -t ${env.PACKAGE_NAME}:build-${env.BUILD_NUMBER} .
        """
      }
    }

    stage('Publish') {
      steps {
        script {
          docker.withRegistry(PUBLISH_REGISTRY, 'ecr:' + AWS_REGION + ':' + ECR_USER) {
          docker.image(PACKAGE_NAME + ':build-' + BUILD_NUMBER).push('latest')
          }
        }
      }
    }

    stage('Deploy to ECS') {
      steps {
        sh """
        ./ecs.sh
        """
      }
    }
  }

  post {
    // teardown
    always {
       cleanWs notFailBuild: true
    }
  }
}
