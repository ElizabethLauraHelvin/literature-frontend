// Using Docker Compose
pipeline {
    agent any

    environment {
        IMAGE_NAME = "elilaura/compose-literature-frontend"
        IMAGE_TAG  = "v.1.0.0"
        DOCKER_HOST = "unix:///var/run/docker.sock"
        COMPOSE_DIR = "/literature-frontend"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push Image') {
            steps {
                dir("${COMPOSE_DIR}") {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
                withCredentials([usernamePassword(
                    credentialsId: 'docker-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }


        stage('Deploy with Docker Compose') {
            steps {
                dir("${COMPOSE_DIR}") {
                    sh """
                        docker compose down || true
                        docker compose pull
                        docker compose up -d --build --force-recreate
                    """
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "docker ps"
            }
        }
    }

    post {
        success { echo "✅ Deployment Berhasil" }
        failure { echo "❌ Deployment Gagal" }
        always { sh "docker system prune -f" }
    }
}


//Manual
// pipeline {
//     agent any

//     environment {
//         IMAGE_NAME     = "elilaura/literature-frontend"
//         IMAGE_TAG      = "v.1.0.0"
//         CONTAINER_NAME = "literature-frontend"
//     }

//     stages {

//         stage('Checkout') {
//             steps {
//                 echo "Checkout source code"
//                 checkout scm
//             }
//         }

//         stage('Build Image') {
//             steps {
//                 echo "Build Docker image ${IMAGE_NAME}:${IMAGE_TAG}"
//                 sh """
//                   docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
//                 """
//             }
//         }

//         stage('Push Image') {
//             steps {
//                 echo "Push image to Docker Hub"
//                 withCredentials([usernamePassword(
//                     credentialsId: 'docker-creds',
//                     usernameVariable: 'DOCKER_USER',
//                     passwordVariable: 'DOCKER_PASS'
//                 )]) {
//                     sh """
//                       echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
//                       docker push ${IMAGE_NAME}:${IMAGE_TAG}
//                     """
//                 }
//             }
//         }

//         stage('Deploy Container') {
//             steps {
//                 echo "Deploy container on port 3000"
//                 sh """
//                   docker rm -f ${CONTAINER_NAME} || true

//                   docker run -d \
//                     --name ${CONTAINER_NAME} \
//                     -p 3000:3000 \
//                     ${IMAGE_NAME}:${IMAGE_TAG}
//                 """
//             }
//         }
//     }

//     post {
//         success {
//             echo "Deployment sukses (v.1.0.0)"
//         }
//         failure {
//             echo "Deployment gagal"
//         }
//     }
// }
