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
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    echo "== Deploying container =="

                    # stop container lama (kalau ada)
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    # run container baru
                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      -p 3000:3000 \
                      ${IMAGE_NAME}:${IMAGE_TAG}
                '''
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
            echo "🧹 Cleaning unused Docker images (safe)"
            sh '''
                docker image prune -f || true
                docker builder prune -f || true
            '''
        }
    }
}
