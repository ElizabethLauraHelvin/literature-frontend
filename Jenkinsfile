pipeline {
    agent any

    environment {
        IMAGE_NAME = "elilaura/literature-frontend"
        CONTAINER_NAME = "literature-frontend"
        IMAGE_TAG = "v.2.0.0"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'elilaura/credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Stop & remove container lama kalau ada
                    sh """
                        if [ \$(docker ps -q -f name=${CONTAINER_NAME}) ]; then
                          echo "Stopping existing container..."
                          docker stop ${CONTAINER_NAME}
                          docker rm ${CONTAINER_NAME}
                        fi
                        
                        # Jalankan container baru
                        docker run -d \\
                          --name ${CONTAINER_NAME} \\
                          -p 3000:3000 \\
                          ${IMAGE_NAME}:${IMAGE_TAG}
                    """
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
            // Bersihkan dangling images & container yang tidak dipakai
            sh "docker system prune -f"
        }
    }
}
