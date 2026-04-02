pipeline {
    agent any

    environment {
        ACR_LOGIN_SERVER = "elizabethacr.azurecr.io"
        IMAGE_NAME = "literature-frontend"
        IMAGE_TAG = "${BUILD_NUMBER}"
        GIT_REPO = "https://github.com/ElizabethLauraHelvin/literature-frontend.git"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Build Image') {
            steps {
                sh """
                docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG .
                """
            }
        }

        stage('Login ACR') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'acr-creds',
                    usernameVariable: 'ACR_USER',
                    passwordVariable: 'ACR_PASS'
                )]) {
                    sh """
                    echo $ACR_PASS | docker login $ACR_LOGIN_SERVER -u $ACR_USER --password-stdin
                    """
                }
            }
        }

        stage('Push Image') {
            steps {
                sh """
                docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh """
                    kubectl set image deployment/literature-frontend \
                      literature-frontend=$ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG

                    kubectl rollout status deployment/literature-frontend
                    """
                }
            }
        }

        stage('Verify') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh """
                    kubectl get pods
                    kubectl get svc
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Deployment berhasil"
        }
        failure {
            echo "Deployment gagal"
        }
    }
}
