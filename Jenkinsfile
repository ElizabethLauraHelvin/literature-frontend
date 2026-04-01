pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: build-tools
    # Image resmi docker yang ringan dan stabil
    image: docker:24.0.5
    command: ["cat"]
    tty: true
    securityContext:
      privileged: true
    # Memberi RAM 2GB agar npm install tidak pingsan (OOM)
    resources:
      limits:
        memory: "2Gi"
        cpu: "1000m"
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
        IMAGE_TAG  = "v${env.BUILD_NUMBER}" // Label versi otomatis (v1, v2, dst)
    }

    stages {
        stage('Setup Tools') {
            steps {
                container('build-tools') {
                    script {
                        // Install kubectl secara instan di dalam pod agent
                        sh '''
                        apk add --no-cache curl
                        curl -Lo /usr/local/bin/kubectl "https://googleapis.com"
                        chmod +x /usr/local/bin/kubectl
                        '''
                    }
                }
            }
        }

        stage('Build & Push to ACR') {
            steps {
                container('build-tools') {
                    script {
                        // Login ke Azure Container Registry
                        withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                            sh """
                            docker build -t ${ACR_SERVER}/${APP_NAME}:${IMAGE_TAG} .
                            echo "${PASS}" | docker login ${ACR_SERVER} -u ${USER} --password-stdin
                            docker push ${ACR_SERVER}/${APP_NAME}:${IMAGE_TAG}
                            """
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('build-tools') {
                    script {
                        // 1. Ganti tulisan ${IMAGE_TAG} di file yaml dengan versi build terbaru
                        sh "sed -i 's|\\\${IMAGE_TAG}|${IMAGE_TAG}|g' deployment.yaml"
                        
                        // 2. Terapkan perubahan ke Cluster
                        sh "kubectl apply -f deployment.yaml"
                        sh "kubectl apply -f service.yaml"
                        
                        echo "MANTAP! Aplikasi sudah terdeploy dengan tag: ${IMAGE_TAG}"
                    }
                }
            }
        }
    }

    post {
        success { echo "Pipeline Berhasil!" }
        failure { echo "Pipeline Gagal, cek log di atas." }
    }
}
