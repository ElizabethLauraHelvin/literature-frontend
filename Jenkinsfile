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
    tty: true

  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["sleep"]
    args: ["999999"]
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
                          --destination=$ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh '''
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                container('kubectl') {
                    sh '''
                    kubectl get pods
                    kubectl get svc
                    '''
                }
            }
        }
    }

    post {
        success { echo "Deployment sukses" }
        failure { echo "Deployment gagal" }
    }
}
