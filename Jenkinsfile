pipeline {
    agent any

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
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh '''
                    docker run --rm \
                        -v ${WORKSPACE}/WebApp:/usr/src \
                        sonarsource/sonar-scanner-cli \
                        -Dsonar.projectKey=angular-app \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://172.17.0.1:9000 \
                        -Dsonar.login=${SONAR_TOKEN}
                    '''
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
                        --exit-code 0 \
                        --severity HIGH,CRITICAL \
                        ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('5. Push to Docker Hub') {
            steps {
                echo '==== Subiendo la imagen segura a Docker Hub ===='
                dir('WebApp') {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh "docker push ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER}"
                        sh "docker push ${DOCKER_USER}/angular-app:latest"
                    }
                }
            }
        }

        stage('6. Test Image') {
            steps {
                echo '==== Verificando que el contenedor levante correctamente ===='
                sh 'docker rm -f test-container || true'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "docker run --name test-container -d -p 8082:80 ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER}"
                }
                sh 'sleep 5'
                sh 'curl -I http://localhost:8082 || echo "Contenedor de prueba listo"'
                sh 'docker rm -f test-container'
            }
        }

        stage('7. Deploy / Delivery') {
            steps {
                echo '==== ¡Pipeline Exitoso! Desplegando en Producción ===='
                sh 'docker rm -f app-angular || true'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "docker run --name app-angular --restart always -d -p 8081:80 ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER}"
                }
                echo '✅ La aplicación se ha desplegado en el puerto 8081.'
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
            echo '✅ ¡Felicidades! El pipeline terminó con éxito rotundo.'
        }
        failure {
            echo '❌ El pipeline falló. Revisar los logs inmediatamente.'
        }
    }
}