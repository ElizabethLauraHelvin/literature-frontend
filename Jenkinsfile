pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: build-tools
    # Image ini berisi Docker, sehingga bisa build & push
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
        stage('Install Kubectl & Build') {
            steps {
                container('build-tools') {
                    script {
                        // 1. Install Kubectl di dalam container (hanya butuh 5 detik)
                        sh '''
                        apk add --no-cache curl
                        curl -Lo /usr/local/bin/kubectl "https://k8s.io"
                        chmod +x /usr/local/bin/kubectl
                        '''

                        // 2. Build & Tag
                        sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                        sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

                        // 3. Login & Push ACR
                        withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                            sh "echo ${PASS} | docker login ${ACR_LOGIN_SERVER} -u ${USER} --password-stdin"
                            sh "docker push ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                container('build-tools') {
                    script {
                        // Update manifest (sed mencari tulisan ${IMAGE_TAG} di yaml)
                        sh "sed -i 's|\\\${IMAGE_TAG}|${IMAGE_TAG}|g' deployment.yaml"
                        
                        // Deploy (Kubectl otomatis pakai ServiceAccount Jenkins untuk akses cluster)
                        sh "kubectl apply -f deployment.yaml"
                        sh "kubectl apply -f service.yaml"
                    }
                }
            }
        }
    }
}
