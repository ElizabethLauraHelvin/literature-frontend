pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: build-tools
    # Image ini berisi Docker dan Kubectl sekaligus
    image: lachlanevenson/k8s-kubectl:v1.28.0
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
        IMAGE_NAME = "literature-frontend"
        IMAGE_TAG = "v${env.BUILD_NUMBER}" // Gunakan Build Number agar image selalu baru
        GIT_REPO = "https://github.com/ElizabethLauraHelvin/literature-frontend.git"
    }

    stages {
        stage('Build & Push Docker') {
            steps {
                container('build-tools') {
                    // Checkout otomatis sudah dilakukan Jenkins di awal
                    withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'ACR_USER', passwordVariable: 'ACR_PASS')]) {
                        sh """
                        # Build & Tag
                        docker build -t $IMAGE_NAME:$IMAGE_TAG .
                        docker tag $IMAGE_NAME:$IMAGE_TAG $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                        
                        # Login & Push
                        echo $ACR_PASS | docker login $ACR_LOGIN_SERVER -u $ACR_USER --password-stdin
                        docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('build-tools') {
                    withCredentials([usernamePassword(credentialsId: 'acr-credentials', usernameVariable: 'ACR_USER', passwordVariable: 'ACR_PASS')]) {
                        sh """
                        # Update manifest agar pakai image terbaru
                        sed -i "s|image:.*|image: $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG|g" deployment.yaml
                        
                        # Re-create Secret (jika diperlukan)
                        kubectl delete secret acr-secret --ignore-not-found
                        kubectl create secret docker-registry acr-secret \
                          --docker-server=$ACR_LOGIN_SERVER \
                          --docker-username=$ACR_USER \
                          --docker-password=$ACR_PASS
                        
                        # Apply Deployment
                        kubectl apply -f deployment.yaml
                        kubectl apply -f service.yaml
                        """
                    }
                }
            }
        }

        stage('Verify') {
            steps {
                container('build-tools') {
                    sh "kubectl get pods && kubectl get svc"
                }
            }
        }
    }

    post {
        success { echo "Deployment sukses" }
        failure { echo "Deployment gagal" }
    }
}
