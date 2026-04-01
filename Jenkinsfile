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
                    sh '''
                    apk add --no-cache curl
        
                    curl -LO "https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl"
                    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        
                    kubectl version --client
                    '''
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
                        sh '''
                        export KUBECONFIG=/root/.kube/config
                        kubectl get nodes
                        kubectl apply -f deployment.yaml
                        kubectl apply -f service.yaml
                        '''
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
