pipeline {
    agent any

    environment {
        IMAGE_NAME = "elilaura/literature-frontend"
        IMAGE_TAG  = "v2"
        CONTAINER_NAME = "literature-frontend"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                docker stop $CONTAINER_NAME || true
                docker rm $CONTAINER_NAME || true

                docker run -d \
                  --name $CONTAINER_NAME \
                  -p 3000:3000 \
                  $IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }
    }
}
