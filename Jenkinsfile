pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker:24.0.5
    command: ["cat"]
    tty: true
    securityContext:
      privileged: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["cat"]
    tty: true
    volumeMounts:
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
        ACR_LOGIN_SERVER = "elizabethacr.azurecr.io"
        IMAGE_NAME       = "literature-frontend"
        IMAGE_TAG        = "v${env.BUILD_NUMBER}"
    }

    stages {
        stage('Build & Push') {
            steps {
                container('docker') {
                    // JANGAN panggil 'git branch...' di sini. 
                    // Kode sudah otomatis ada dari tahap 'Declarative: Checkout SCM'
                    withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh """
                        docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG .
                        echo \$PASS | docker login $ACR_LOGIN_SERVER -u \$USER --password-stdin
                        docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                        """
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                container('kubectl') {
                    sh """
                    # Gunakan double quote agar variable IMAGE_TAG terbaca
                    sed -i "s|image:.*|image: $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG|g" deployment.yaml
                    
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                    """
                }
            }
        }
    }
}
