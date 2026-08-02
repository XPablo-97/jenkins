pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    environment {
        ECR_REGISTRY = "887540997584.dkr.ecr.eu-central-1.amazonaws.com"
        ECR_REPO     = "887540997584.dkr.ecr.eu-central-1.amazonaws.com/angular-app"
        AWS_REGION   = "eu-central-1"
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                echo '==== Descargando la última versión del repositorio ===='
                checkout scm
            }
        }

        stage('2. Code Quality Scan (SonarQube)') {
            steps {
                echo '==== Analizando calidad de código con SonarQube ===='
                dir('WebApp') {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
                        docker run --rm \
                            -v "$PWD:/usr/src" \
                            -w /usr/src \
                            -e SONAR_TOKEN=$SONAR_TOKEN \
                            sonarsource/sonar-scanner-cli \
                            -Dsonar.projectKey=angular-app \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=${SONAR_HOST_URL:-http://172.17.0.1:9000} \
                            -Dsonar.token=$SONAR_TOKEN \
                            -Dsonar.scm.disabled=true \
                            -Dsonar.exclusions=**/node_modules/**,**/dist/**
                        '''
                    }
                }
            }
        }

        stage('3. Build Docker Image') {
            steps {
                echo '==== Construyendo la imagen (Sin subirla aún) ===='
                dir('WebApp') {
                    sh "docker build -t ${ECR_REPO}:build-${BUILD_NUMBER} -t ${ECR_REPO}:latest ."
                }
            }
        }

        stage('4. Security Scan (Trivy)') {
            steps {
                echo '==== Escaneando vulnerabilidades de contenedor con Trivy ===='
                sh """
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image \
                    --no-progress \
                    --ignore-unfixed \
                    --exit-code 1 \
                    --severity HIGH,CRITICAL \
                    ${ECR_REPO}:build-${BUILD_NUMBER}
                """
            }
        }

        stage('5. Test Image') {
            steps {
                echo '==== Verificando que el contenedor levante correctamente ===='
                sh 'docker rm -f test-container || true'
                sh "docker run --name test-container -d -p 8082:80 ${ECR_REPO}:build-${BUILD_NUMBER}"
                sh 'curl -sf --retry 5 --retry-connrefused --retry-delay 2 http://172.17.0.1:8082'
                sh 'docker rm -f test-container'
            }
        }

        stage('6. Push to ECR') {
            steps {
                echo '==== Subiendo la imagen probada a ECR ===='
                sh """
                aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                docker push ${ECR_REPO}:build-${BUILD_NUMBER}
                docker push ${ECR_REPO}:latest
                """
            }
        }

        stage('7. Deploy to ECS') {
            when {
                expression { env.GIT_BRANCH == 'origin/main' }
            }
            steps {
                echo '==== Desplegando en ECS/Fargate ===='
                sh """
                aws ecs update-service \
                    --cluster angular-app-cluster \
                    --service angular-app-service \
                    --force-new-deployment \
                    --region ${AWS_REGION}
                """
            }
        }
    }

        post {
        always {
            echo '==== Limpiando espacio en disco de Docker ===='
            sh "docker rmi ${ECR_REPO}:build-${BUILD_NUMBER} || true"
            sh 'docker image prune -f'
        }
        success {
            echo '¡Felicidades! El pipeline terminó con éxito rotundo.'
            withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                sh """
                curl -s -X POST \
                    -H "Authorization: token ${GITHUB_TOKEN}" \
                    -H "Accept: application/vnd.github+json" \
                    https://api.github.com/repos/XPablo-97/jenkins/statuses/${GIT_COMMIT} \
                    -d '{"state":"success","context":"angular-app-test","target_url":"${BUILD_URL}","description":"Jenkins pipeline passed"}'
                """
            }
        }
        failure {
            echo 'El pipeline falló. Revisar los logs inmediatamente.'
            withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
                sh """
                curl -s -X POST \
                    -H "Authorization: token ${GITHUB_TOKEN}" \
                    -H "Accept: application/vnd.github+json" \
                    https://api.github.com/repos/XPablo-97/jenkins/statuses/${GIT_COMMIT} \
                    -d '{"state":"failure","context":"angular-app-test","target_url":"${BUILD_URL}","description":"Jenkins pipeline failed"}'
                """
            }
        }
    }
  }