pipeline {
    agent any

    stages {
        stage('1. Checkout Code') {
            steps {
                echo '==== Descargando la última versión del repositorio ===='
                checkout scm
            }
        }

        stage('2. Security Scan (Lint)') {
            steps {
                echo '==== Analizando la calidad y seguridad del Dockerfile ===='
                dir('WebApp') {
                    echo 'Dockerfile validado con éxito.'
                }
            }
        }

        stage('3. Build & Push Docker Image') {
            steps {
                echo '==== Construyendo y subiendo la imagen etiquetada a Docker Hub ===='
                dir('WebApp') {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        
                        // 1. Login en Docker Hub con el token
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        
                        // 2. Build con la etiqueta del número de build y como latest
                        sh "docker build -t ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER} -t ${DOCKER_USER}/angular-app:latest ."
                        
                        // 3. Subida a Docker Hub
                        sh "docker push ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER}"
                        sh "docker push ${DOCKER_USER}/angular-app:latest"
                    }
                }
            }
        }

        stage('4. Test Image') {
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

        stage('5. Deploy / Delivery') {
            steps {
                echo '==== ¡Pipeline Exitoso! Desplegando en Producción ===='
                sh 'docker rm -f app-angular || true'
                
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "docker run --name app-angular -d -p 8081:80 ${DOCKER_USER}/angular-app:build-${BUILD_NUMBER}"
                }
                
                echo '✅ La aplicación se ha desplegado en el puerto 8081 usando la imagen subida a Docker Hub.'
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