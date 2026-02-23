pipeline {
    agent any

    environment {
        IMAGE_NAME = "elilaura/literature-frontend"
        IMAGE_TAG  = "v1.0.0"
    }

    stages {

        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/sinambela99/literature-frontend.git',
                    branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                sh """
                docker compose down
                docker compose up -d --build
                """
            }
        }
    }

    post {
        success {
            echo 'Deployment sukses: frontend + nginx sudah jalan'
        }
        failure {
            echo 'Deployment gagal, cek log Jenkins'
        }
    }
}
