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
      limits:
        cpu: "1000m"
        memory: "2Gi"
      requests:
        cpu: "500m"
        memory: "1Gi"
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
                        // FIX: URL Direct Download Kubectl yang benar
                        sh '''
                        apk add --no-cache curl
                        curl -LO "https://k8s.io"
                        chmod +x kubectl
                        mv kubectl /usr/local/bin/
                        '''

                        withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                            sh """
                            docker build -t ${ACR_SERVER}/${APP_NAME}:${IMAGE_TAG} .
                            echo "${PASS}" | docker login ${ACR_SERVER} -u ${USER} --password-stdin
                            docker push ${ACR_SERVER}/${APP_NAME}:${IMAGE_TAG}
                            """
                        }

                        sh """
                        # Pastikan file deployment.yaml ada di repo githubmu
                        sed -i "s|image:.*|image: ${ACR_SERVER}/${APP_NAME}:${IMAGE_TAG}|g" deployment.yaml
                        
                        kubectl apply -f deployment.yaml
                        kubectl apply -f service.yaml
                        
                        echo "Berhasil Deploy Versi: ${IMAGE_TAG}"
                        """
                    }
                }
            }
        }
    }
    
    post {
        success { echo "Pipeline Selesai dengan Sukses!" }
        failure { echo "Pipeline Gagal, periksa log di atas." }
    }
}
