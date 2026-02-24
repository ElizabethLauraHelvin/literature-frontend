pipeline {
    agent any

    environment {
        IMAGE_NAME = "elilaura/literature-frontend"
        CONTAINER_NAME = "literature-frontend"
        IMAGE_TAG = "v.1.0.0"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
            post {
                success {
                    echo "✅ Stage Checkout Code: berhasil"
                }
                failure {
                    echo "❌ Stage Checkout Code: gagal"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
            post {
                success {
                    echo "✅ Stage Build Docker Image: berhasil"
                }
                failure {
                    echo "❌ Stage Build Docker Image: gagal"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
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
            post {
                success {
                    echo "✅ Stage Push Docker Image: berhasil"
                }
                failure {
                    echo "❌ Stage Push Docker Image: gagal"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh """
                docker rm -f ${CONTAINER_NAME} || true

                docker run -d \
                  --name ${CONTAINER_NAME} \
                  -p 3030:3000 \
                  ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
            post {
                success {
                    echo "✅ Stage Deploy Container: berhasil"
                }
                failure {
                    echo "❌ Stage Deploy Container: gagal"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment berhasil"
        }
        failure {
            echo "❌ Deployment gagal"
        }
        always {
            sh "docker image prune -f"
        }
    }
}
