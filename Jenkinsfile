pipeline {
    agent any

    environment {
        IMAGE_NAME     = "elilaura/literature-frontend"
        CONTAINER_NAME = "literature-frontend"
        IMAGE_TAG      = "v.2.0.0"
    }

    stages {

        stage('Checkout Code') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                    checkout scm
                }
                echo "ℹ️ Stage Checkout Code selesai"
            }
        }

        stage('Build Docker Image') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                    sh """
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    """
                }
                echo "ℹ️ Stage Build Docker Image selesai"
            }
        }

        stage('Push Docker Image') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        """
                    }
                }
                echo "ℹ️ Stage Push Docker Image selesai"
            }
        }

        stage('Deploy Container') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                    sh """
                        docker rm -f ${CONTAINER_NAME} || true
                        docker run -d \
                          --name ${CONTAINER_NAME} \
                          -p 3000:3000 \
                          ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
                echo "ℹ️ Stage Deploy Container selesai"
            }
        }
    }

    post {
        success {
            echo "✅ PIPELINE SELESAI (SUCCESS)"
        }
        unstable {
            echo "⚠️ PIPELINE SELESAI (UNSTABLE – ADA ERROR TAPI TIDAK FAIL)"
        }
        always {
            sh "docker image prune -f || true"
            echo "🧹 Cleanup selesai"
        }
    }
}
