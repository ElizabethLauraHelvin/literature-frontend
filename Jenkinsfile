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
        ACR_SERVER = "elizabethacr.azurecr.io"
        APP_NAME   = "literature-frontend"
        IMAGE_TAG  = "v${env.BUILD_NUMBER}"
    }

    stages {
        stage('Build & Push ACR') {
            steps {
                container('build-tools') {
                    script {
                        // 1. Build & Push (Ini sudah pernah sukses di build v32 kamu)
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
                container('build-tools') {
                    script {
                        // 2. INSTALL KUBECTL DENGAN URL YANG SUDAH DIPERBAIKI (DIRECT LINK)
                        // Perhatikan: Menggunakan URL googleapis agar lebih stabil dibanding dl.k8s.io
                        sh '''
                        apk add --no-cache curl
                        curl -Lo /usr/local/bin/kubectl "https://googleapis.com"
                        chmod +x /usr/local/bin/kubectl
                        
                        # Verifikasi apakah yang terdownload benar aplikasi (bukan HTML)
                        kubectl version --client
                        '''

                        // 3. UPDATE MANIFEST & APPLY
                        sh """
                        # Sed mencari teks ${IMAGE_TAG} di file deployment.yaml
                        sed -i "s|\\\${IMAGE_TAG}|${IMAGE_TAG}|g" deployment.yaml
                        
                        kubectl apply -f deployment.yaml
                        kubectl apply -f service.yaml
                        
                        echo "DEPLOYMENT SUKSES KE VERSI: ${IMAGE_TAG}"
                        """
                    }
                }
            }
        }
    }
}
