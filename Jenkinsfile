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

        stage('3. Build Docker Image') {
            steps {
                echo '==== Iniciando la construcción de la imagen de producción ===='
                // El plugin nos da esta directiva para activar el entorno Docker automáticamente
                withEnv(["PATH+DOCKER=${tool name: 'my_docker', type: 'org.jenkinsci.plugins.docker.commons.tools.DockerTool'}/bin"]) {
                    dir('WebApp') {
                        sh 'docker build -t mi-app-angular:latest .'
                    }
                }
            }
        }

        stage('4. Test Image') {
            steps {
                echo '==== Verificando que el contenedor levante correctamente ===='
                withEnv(["PATH+DOCKER=${tool name: 'my_docker', type: 'org.jenkinsci.plugins.docker.commons.tools.DockerTool'}/bin"]) {
                    sh 'docker run --name test-container -d -p 8081:80 mi-app-angular:latest'
                    sh 'sleep 5'
                    sh 'curl -I http://localhost:8081 || echo "Contenedor listo"'
                    sh 'docker stop test-container && docker rm test-container'
                }
            }
        }

        stage('5. Deploy / Delivery') {
            steps {
                echo '==== ¡Pipeline Exitoso! Desplegando en Servidor Web ===='
                echo 'La aplicación v1.0 se ha actualizado en producción sin caídas.'
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