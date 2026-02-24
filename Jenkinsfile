def FAILED_STAGE = "UNKNOWN"

pipeline {
    agent any

    environment {
        IMAGE_NAME     = "elilaura/literature-frontend"
        CONTAINER_NAME = "literature-frontend"
        IMAGE_TAG      = "v.1.0.0"
    }

    stages {

        stage('Checkout Code') {
            steps {
                script {
                    try {
                        checkout scm
                        echo "✅ Stage Checkout Code: berhasil"
                    } catch (err) {
                        FAILED_STAGE = "Checkout Code"
                        echo "❌ Stage Checkout Code: gagal"
                        error("Stop pipeline")
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                        echo "✅ Stage Build Docker Image: berhasil"
                    } catch (err) {
                        FAILED_STAGE = "Build Docker Image"
                        echo "❌ Stage Build Docker Image: gagal"
                        error("Stop pipeline")
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(
                            credentialsId: 'docker-creds',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )]) {
                            sh """
                                echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
                                docker push ${IMAGE_NAME}:${IMAGE_TAG}
                            """
                        }
                        echo "✅ Stage Push Docker Image: berhasil"
                    } catch (err) {
                        FAILED_STAGE = "Push Docker Image"
                        echo "❌ Stage Push Docker Image: gagal"
                        error("Stop pipeline")
                    }
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    try {
                        sh """
                            docker rm -f ${CONTAINER_NAME} || true
                            docker run -d \
                              --name ${CONTAINER_NAME} \
                              -p 3030:3000 \
                              ${IMAGE_NAME}:${IMAGE_TAG}
                        """
                        echo "✅ Stage Deploy Container: berhasil"
                    } catch (err) {
                        FAILED_STAGE = "Deploy Container"
                        echo "❌ Stage Deploy Container: gagal"
                        error("Stop pipeline")
                    }
                }
            }
        }
    }

    post {
        success {
            echo "🎉 PIPELINE SUKSES"
        }
        failure {
            echo "🔥 PIPELINE GAGAL DI STAGE: ${FAILED_STAGE}"
        }
        always {
            sh "docker image prune -f || true"
        }
    }
}
