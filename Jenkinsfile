pipeline {
    agent {
        kubernetes {
            yaml """
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: kaniko
                image: gcr.io/kaniko-project/executor:latest
                command:
                - cat
                tty: true
            """
        }  
    }

    environment {
        ACR_LOGIN_SERVER = "elizabethacr.azurecr.io"
        IMAGE_NAME = "literature-frontend"
        IMAGE_TAG = "v1.0.0"
        GIT_REPO = "https://github.com/ElizabethLauraHelvin/literature-frontend.git"
    }

    stages {

        stage('Pull Code') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Build & Push Image (Kaniko)') {
            steps {
                container('kaniko') {
                    withCredentials([usernamePassword(
                        credentialsId: 'acr-credentials',
                        usernameVariable: 'ACR_USER',
                        passwordVariable: 'ACR_PASS'
                    )]) {
                        sh '''
                        mkdir -p /kaniko/.docker
        
                        cat <<EOF > /kaniko/.docker/config.json
                        {
                          "auths": {
                            "$ACR_LOGIN_SERVER": {
                              "username": "$ACR_USER",
                              "password": "$ACR_PASS"
                            }
                          }
                        }
                        EOF
        
                        /kaniko/executor \
                          --dockerfile=Dockerfile \
                          --context=$(pwd) \
                          --destination=$ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG \
                          --insecure \
                          --skip-tls-verify
                        '''
                    }
                }
            }
        }

        stage('Login to ACR') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'acr-credentials',
                    usernameVariable: 'ACR_USER',
                    passwordVariable: 'ACR_PASS'
                )]) {
                    sh '''
                    echo $ACR_PASS | docker login $ACR_LOGIN_SERVER -u $ACR_USER --password-stdin
                    '''
                }
            }
        }

        stage('Push Image to ACR') {
            steps {
                sh '''
                docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

        stage('Create Image Pull Secret (K8s)') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'acr-credentials',
                    usernameVariable: 'ACR_USER',
                    passwordVariable: 'ACR_PASS'
                )]) {
                    sh '''
                    kubectl delete secret acr-secret || true

                    kubectl create secret docker-registry acr-secret \
                      --docker-server=$ACR_LOGIN_SERVER \
                      --docker-username=$ACR_USER \
                      --docker-password=$ACR_PASS \
                      --docker-email=test@test.com
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                kubectl get pods
                kubectl get svc
                '''
            }
        }
    }

     post {
        success { echo "Deployment sukses" }
        failure { echo "Deployment gagal" }
    }

}
