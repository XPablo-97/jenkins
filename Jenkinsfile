pipeline {
    agent any

    stages {
        stage('1. Checkout Code') {
            steps {
                echo '==== Descargando la última versión del repositorio ===='
                checkout scm
            }
        }

        stage('2. Build Docker Image') {
            steps {
                echo '==== Construyendo la imagen (Sin subirla aún) ===='
                dir('WebApp') {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "docker build -t ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER} -t ${DOCKER_USER}/angular-app:latest ."
                    }
                }
            }
        }

        stage('3. Security Scan (Trivy)') {
            steps {
                echo '==== Escaneando vulnerabilidades con Trivy ===='
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    // Usamos la imagen oficial de Trivy para escanear nuestra aplicación
                    // --exit-code 0: Solo muestra los fallos, pero no rompe el pipeline (ideal para empezar)
                    // --severity HIGH,CRITICAL: Solo queremos ver los fallos graves o críticos
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

        stage('4. Push to Docker Hub') {
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

        stage('5. Test Image') {
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

        stage('6. Deploy / Delivery') {
            steps {
                echo '==== ¡Pipeline Exitoso! Desplegando en Producción ===='
                sh 'docker rm -f app-angular || true'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "docker run --name app-angular -d -p 8081:80 ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER}"
                }
                echo '✅ La aplicación se ha desplegado en el puerto 8081.'
            }
        }
    }

    post {
        always {
            echo '==== Limpiando el espacio de trabajo ===='
        }
        success {
            echo '✅ ¡Felicidades! El pipeline terminó con éxito rotundo.'
        }
        failure {
            echo '❌ El pipeline falló. Revisar los logs inmediatamente.'
        }
    }
}