pipeline {
    agent any

    environment {
        IMAGE_NAME = "elilaura/literature-frontend"
        IMAGE_TAG  = "v1"
        CONTAINER_NAME = "literature-frontend"
    }

    stages {

        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "== Building Docker image =="
                docker build -t $IMAGE_NAME:$IMAGE_TAG .
                '''
            }
        }

        stage('Run Container') {
            steps {
                sh '''
                echo "== Stopping old container (if exists) =="
                docker stop $CONTAINER_NAME || true
                docker rm $CONTAINER_NAME || true

                echo "== Running new container =="
                docker run -d \
                  --name $CONTAINER_NAME \
                  -p 3000:3000 \
                  $IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Container berhasil dijalankan"
        }
        failure {
            echo "❌ Pipeline gagal — cek error di stage atas"
        }
    }
}
