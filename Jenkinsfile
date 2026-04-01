pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: build-tools
    # Image ini SUDAH BERISI docker dan kubectl secara bawaan.
    image: google/cloud-sdk:alpine
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
        ACR_SERVER = "elizabethacr.azurecr.io"
        APP_NAME   = "literature-frontend"
        IMAGE_TAG  = "v${env.BUILD_NUMBER}"
    }

    stages {
        stage('Build & Push ACR') {
            steps {
                container('build-tools') {
                    script {
                        // 1. Build Image (Docker sudah ada di image ini)
                        sh "docker build -t ${ACR_SERVER}/${APP_NAME}:${IMAGE_TAG} ."
                        
                        // 2. Login & Push
                        withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                            sh "echo ${PASS} | docker login ${ACR_SERVER} -u ${USER} --password-stdin"
                            sh "docker push ${ACR_SERVER}/${APP_NAME}:${IMAGE_TAG}"
                        }
                    }
                }
            }
        }

        stage('Deploy to K8s') {
            steps {
                container('build-tools') {
                    script {
                        // 3. Update Manifest (sed mencari tulisan ${IMAGE_TAG} di yaml kamu)
                        sh "sed -i 's|\\\${IMAGE_TAG}|${IMAGE_TAG}|g' deployment.yaml"
                        
                        // 4. Jalankan kubectl (Sudah ada di image, tidak perlu install lagi)
                        sh "kubectl apply -f deployment.yaml"
                        sh "kubectl apply -f service.yaml"
                        
                        echo "DEPLOYMENT BERHASIL: ${IMAGE_TAG}"
                    }
                }
            }
        }
    }
}
