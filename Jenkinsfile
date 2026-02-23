pipeline {
    agent any

    environment {
        IMAGE_NAME     = "elilaura/literature-frontend"
        CONTAINER_NAME = "literature-frontend"
        IMAGE_TAG      = "v2.0.0"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "== Build Docker Image =="
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Login & Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'elilaura/credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "== Login Docker Hub =="
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                        echo "== Push Image =="
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    echo "== Deploying Container =="

                    # stop & remove container lama (kalau ada)
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    # jalankan container baru
                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      -p 3000:3000 \
                      --restart unless-stopped \
                      ${IMAGE_NAME}:${IMAGE_TAG}

                    echo "== Container running =="
                    docker ps | grep ${CONTAINER_NAME} || true
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
            echo "🧹 Safe Docker cleanup"
            sh '''
                docker image prune -f || true
                docker builder prune -f || true
            '''
        }
    }
}
