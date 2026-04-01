pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  securityContext:
    fsGroup: 1000

  containers:
  - name: docker
    image: docker:24.0.5
    command:
    - sh
    args:
    - -c
    - sleep 999999
    tty: true
    securityContext:
      privileged: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock

  - name: kubectl
    image: bitnami/kubectl:1.28
    command:
    - sh
    args:
    - -c
    - sleep 999999
    tty: true
    volumeMounts:
    - name: kube-config
      mountPath: /root/.kube

  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock

  - name: kube-config
    secret:
      secretName: kubeconfig
"""
        }
    }

    environment {
        ACR_LOGIN_SERVER = "elizabethacr.azurecr.io"
        IMAGE_NAME = "literature-frontend"
        IMAGE_TAG = "v1"
        GIT_REPO = "https://github.com/ElizabethLauraHelvin/literature-frontend.git"
    }

    stages {

        stage('Clone') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Build Image') {
            steps {
                container('docker') {
                    sh '''
                    docker version
                    docker build -t $IMAGE_NAME:$IMAGE_TAG .
                    docker tag $IMAGE_NAME:$IMAGE_TAG $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Login ACR') {
            steps {
                container('docker') {
                    withCredentials([usernamePassword(
                        credentialsId: 'acr-credentials',
                        usernameVariable: 'USER',
                        passwordVariable: 'PASS'
                    )]) {
                        sh '''
                        echo $PASS | docker login $ACR_LOGIN_SERVER -u $USER --password-stdin
                        '''
                    }
                }
            }
        }

        stage('Push Image') {
            steps {
                container('docker') {
                    sh '''
                    docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                container('kubectl') {
                    sh '''
                    export KUBECONFIG=/root/.kube/config
        
                    echo "Test connection"
                    kubectl get nodes
        
                    echo "Apply deployment"
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                    '''
                }
            }
        }

        stage('Check') {
            steps {
                container('kubectl') {
                    sh '''
                    kubectl get pods -o wide
                    kubectl get svc
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Build & Deploy berhasil"
        }
        failure {
            echo "FAILED: Cek log stage yang error"
        }
    }
}
