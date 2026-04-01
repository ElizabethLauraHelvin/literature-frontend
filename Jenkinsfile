pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: build-tools
    image: docker:24.0.5  # Kita hanya pakai satu image ini saja yang sudah terbukti bisa di-pull
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

        stage('Setup & Build') {
            steps {
                container('build-tools') {
                    script {
                        // FIX: Gunakan URL download langsung (Direct Link)
                        sh '''
                        apk add --no-cache curl
                        # Download langsung ke file bernama 'kubectl'
                        curl -Lo kubectl "https://k8s.io"
                        chmod +x kubectl
                        mv kubectl /usr/local/bin/
                        
                        # Cek apakah sudah terinstal
                        kubectl version --client
                        '''

                        // Build & Push ke ACR
                        withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'ACR_USER', passwordVariable: 'ACR_PASS')]) {
                            sh """
                            docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG .
                            echo "$ACR_PASS" | docker login $ACR_LOGIN_SERVER -u $ACR_USER --password-stdin
                            docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                            """
                        }
                    }
                }
            }
        }


        stage('Deploy') {
            steps {
                container('build-tools') {
                    sh """
                    # Update manifest
                    sed -i "s|image:.*|image: $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG|g" deployment.yaml
                    
                    # Apply ke Kubernetes
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                    
                    echo "Deployment Sukses!"
                    """
                }
            }
        }
    }
}
