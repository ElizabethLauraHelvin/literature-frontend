pipeline {
    agent any

    environment {
        ACR_LOGIN_SERVER = "elizabethacr.azurecr.io"
        IMAGE_NAME       = "literature-frontend"
        IMAGE_TAG        = "v${env.BUILD_NUMBER}"
    }

    stages {
        stage('Build & Push') {
            steps {
                // Langsung jalankan sh, jangan pakai container('docker')
                git branch: 'main', url: "https://github.com/ElizabethLauraHelvin/literature-frontend.git"
                withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                    docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG .
                    echo $PASS | docker login $ACR_LOGIN_SERVER -u $USER --password-stdin
                    docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                // Langsung jalankan sh, jangan pakai container('kubectl')
                sh """
                sed -i "s|image:.*|image: $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG|g" deployment.yaml
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml
                """
            }
        }
    }
}
