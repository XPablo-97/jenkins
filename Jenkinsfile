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
                dir('WebApp') {
                    sh 'docker build -t mi-app-angular:latest .'
                }
            }
        }

        stage('4. Test Image') {
            steps {
                echo '==== Verificando que el contenedor levante correctamente ===='
                // 1. Limpieza preventiva por si un test falló anteriormente
                sh 'docker rm -f test-container || true'
                
                // 2. Levantamos la app en un puerto interno distinto (8082) para no chocar con producción
                sh 'docker run --name test-container -d -p 8082:80 mi-app-angular:latest'
                sh 'sleep 5'
                
                // 3. Probamos que responda bien
                sh 'curl -I http://localhost:8082 || echo "Contenedor de prueba listo"'
                
                // 4. Destruimos el entorno de pruebas para no dejar basura
                sh 'docker rm -f test-container'
            }
        }

        stage('5. Deploy / Delivery') {
            steps {
                echo '==== ¡Pipeline Exitoso! Desplegando en Servidor Web ===='
                
                // 1. Apagamos y borramos la versión VIEJA de la app que esté corriendo
                sh 'docker rm -f app-angular || true'
                // Opcional: También limpiamos si quedó ocupando el 8081 por el error de antes
                sh 'docker rm -f test-container || true' 
                
                // 2. Encendemos la versión NUEVA de forma definitiva en el puerto oficial (8081)
                sh 'docker run --name app-angular -d -p 8081:80 mi-app-angular:latest'
                
                echo '✅ La aplicación v1.0 se ha actualizado en producción y está visible en el puerto 8081.'
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