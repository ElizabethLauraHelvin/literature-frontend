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

        stage('Build & Push Image (Kaniko)') {
            steps {
                container('kaniko') {
                    withCredentials([usernamePassword(
                        credentialsId: 'acr-creds',
                        usernameVariable: 'ACR_USER',
                        passwordVariable: 'ACR_PASS'
                    )]) {

                        sh """
                        mkdir -p /kaniko/.docker

                        echo '{"auths":{"${ACR_LOGIN_SERVER}":{"username":"${ACR_USER}","password":"${ACR_PASS}"}}}' > /kaniko/.docker/config.json

                        /kaniko/executor \
                          --context `pwd` \
                          --dockerfile `pwd`/Dockerfile \
                          --destination=${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                    sh """
                    kubectl set image deployment/literature-frontend \
                      literature-frontend=${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}

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
