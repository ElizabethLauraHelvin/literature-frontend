pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker-client
    image: docker:24.0.5
    command: ["cat"]
    tty: true
    securityContext:
      privileged: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  - name: kubectl-client
    image: bitnami/kubectl:latest
    command: ["cat"]
    tty: true
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
                // Gunakan container 'docker-client' untuk proses build
                container('docker-client') {
                    script {
                        sh "docker build -t ${ACR_SERVER}/${APP_NAME}:${IMAGE_TAG} ."
                        
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
                // Pindah ke container 'kubectl-client' untuk proses deploy
                container('kubectl-client') {
                    script {
                        // Update tag di deployment.yaml
                        sh "sed -i 's|\\\${IMAGE_TAG}|${IMAGE_TAG}|g' deployment.yaml"
                        
                        // Jalankan apply
                        sh "kubectl apply -f deployment.yaml"
                        sh "kubectl apply -f service.yaml"
                        
                        echo "DEPLOYMENT BERHASIL: ${IMAGE_TAG}"
                    }
                }
            }
        }
    }
}
