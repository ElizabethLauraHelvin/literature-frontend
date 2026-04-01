pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: build-tools
    image: docker:24.0.5
    command: ["cat"]
    tty: true
    securityContext:
      privileged: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }

    environment {
        ACR_LOGIN_SERVER = "elizabethacr.azurecr.io"
        IMAGE_NAME       = "literature-frontend"
        IMAGE_TAG        = "v${env.BUILD_NUMBER}"
    }

    stages {
        stage('Build & Push ACR') {
            steps {
                container('build-tools') {
                    script {
                        // Build & Tag
                        sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                        sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

                        // Login & Push
                        withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                            sh "echo ${PASS} | docker login ${ACR_LOGIN_SERVER} -u ${USER} --password-stdin"
                            sh "docker push ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"
                        }
                    }
                }
            }
        }

        stage('Deploy to K8s') {
            steps {
                container('build-tools') {
                    script {
                        // INSTALL KUBECTL ULANG DI SINI (PASTIKAN URL BENAR)
                        sh '''
                        apk add --no-cache curl
                        curl -Lo /usr/local/bin/kubectl "https://k8s.io"
                        chmod +x /usr/local/bin/kubectl
                        '''

                        // UPDATE MANIFEST & APPLY
                        // Pastikan di deployment.yaml kamu ada teks: ${IMAGE_TAG}
                        sh """
                        sed -i "s|\\\${IMAGE_TAG}|${IMAGE_TAG}|g" deployment.yaml
                        kubectl apply -f deployment.yaml
                        kubectl apply -f service.yaml
                        
                        echo "DEPLOYMENT SUCCESSFUL: ${IMAGE_TAG}"
                        """
                    }
                }
            }
        }
    }
}
