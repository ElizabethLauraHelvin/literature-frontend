pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker-kubectl
    image: docker:24.0.5
    command: ["cat"]
    tty: true
    securityContext:
      privileged: true
    resources:
      requests:
        cpu: "500m"
        memory: "1Gi"
      limits:
        cpu: "1000m"
        memory: "2Gi"
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
    - name: kube-config
      mountPath: /root/.kube/config
      subPath: config
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
        ACR_SERVER = "elizabethacr.azurecr.io"
        APP_NAME   = "literature-frontend"
        IMAGE_TAG  = "v${env.BUILD_NUMBER}"
    }

    stages {
        stage('Build, Push & Deploy') {
            steps {
                container('docker-kubectl') {
                    script {
                        // 1. Install Kubectl di dalam container Docker (Cepat & Pasti Ada)
                        sh '''
                        apk add --no-cache curl
                        curl -LO "https://k8s.io(curl -L -s https://k8s.io)/bin/linux/amd64/kubectl"
                        chmod +x kubectl
                        mv kubectl /usr/local/bin/
                        '''

                        // 2. Build & Push
                        withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                            sh """
                            docker build -t ${ACR_SERVER}/${APP_NAME}:${IMAGE_TAG} .
                            echo "${PASS}" | docker login ${ACR_SERVER} -u ${USER} --password-stdin
                            docker push ${ACR_SERVER}/${APP_NAME}:${IMAGE_TAG}
                            """
                        }

                        // 3. Deploy
                        sh """
                        # Pastikan file manifest ada di repo
                        sed -i "s|image:.*|image: ${ACR_SERVER}/${APP_NAME}:${IMAGE_TAG}|g" deployment.yaml
                        
                        kubectl apply -f deployment.yaml
                        kubectl apply -f service.yaml
                        
                        echo "Deployment Success: ${IMAGE_TAG}"
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs() // Membersihkan workspace agar disk tidak penuh
        }
    }
}
