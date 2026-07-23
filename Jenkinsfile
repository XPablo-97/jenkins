pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
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
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "docker build -t ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER} -t ${DOCKER_USER}/angular-app:latest ."
                    }
                }
            }
        }

        stage('4. Security Scan (Trivy)') {
            steps {
                echo '==== Escaneando vulnerabilidades de contenedor con Trivy ===='
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh """
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image \
                        --no-progress \
                        --ignore-unfixed \
                        --exit-code 1 \
                        --severity HIGH,CRITICAL \
                        ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('5. Test Image') {
            steps {
                echo '==== Verificando que el contenedor levante correctamente ===='
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh 'docker rm -f test-container || true'
                    sh "docker run --name test-container -d -p 8082:80 ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER}"
                    sh 'curl -sf --retry 5 --retry-connrefused --retry-delay 2 http://172.17.0.1:8082'
                    sh 'docker rm -f test-container'
                }
            }
        }

        stage('6. Push to Docker Hub') {
            steps {
                echo '==== Subiendo la imagen probada a Docker Hub ===='
                dir('WebApp') {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh "docker push ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER}"
                        sh "docker push ${DOCKER_USER}/angular-app:latest"
                        sh 'docker logout'
                    }
                }
            }
        }

        stage('7. Deploy / Delivery') {
            when {
                expression { env.GIT_BRANCH == 'origin/main' }
            }
            steps {
                echo '==== ¡Pipeline Exitoso! Desplegando en Producción ===='
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh 'docker rm -f app-angular || true'
                    sh "docker run --name app-angular --restart always -d -p 8081:80 ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER}"
                }
                echo 'La aplicación se ha desplegado en el puerto 8081.'
            }
        }
    }

    post {
        always {
            echo '==== Limpiando espacio en disco de Docker ===='
            withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                sh "docker rmi ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER} || true"
            }
            sh 'docker image prune -f'
        }
        success {
            echo '¡Felicidades! El pipeline terminó con éxito rotundo.'
        }
        failure {
            echo 'El pipeline falló. Revisar los logs inmediatamente.'
        }
    }
}
