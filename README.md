<<<<<<< HEAD
## • Ejecución Local e Independiente

### Base de datos MongoDB
Para poder guardar los datos, utilizamos MongoDB. El cual recibira operaciones de ```GET```, ```POST``` y  ```DELETE```.
Esta imagen es descargada de Docker Hub: ```https://hub.docker.com/_/mongo```

Para poder ejecutar el contenedor y hacer pruebas con el api de Node, ejecuta el siguiente comando de Docker:

```
 docker run --name mongodb -dp 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=adminpassword -e MONGO_INITDB_DATABASE=blockstellart -v mongo-data:/data/db mongo:latest
```

## Apis

### Api .NET
El api de .net tiene como objetivo establecer comunicación con Amazon SES y realizar el envio de email.
Para poder establer comunicación entre .NET y Amazon se requiere la instalación de algunos paquetes:

install-package AWSSDK.Extensions.NETCore.Setup
install-package AWSSDK.SimpleEmail

Si estas en VS Community unicamente debes presionar el boton de ```iniciar``` si utilizas VS Code ejecuta el comando ```dotnet build```

**Nota**: En caso de querer realizar este proyecto con Python, utiliza Boto3

También se debe incluir las configuraciones necesarias en appsetting.json
```json
"AWS": {
    "Profile": "",
    "Region": "",
    "AccessKey": "",
    "SecretKey": ""
  },
"EmailVerificado": "" // Utilizado para el envio de correo
```
**Importante:** Si deseas ejecutar este proyecto de forma independiente (VS Community o VS Code o con el comando ```dotnet run```)  deberas ingresar los datos correspondiente mencionados anteriormente. Pero recuerda que es una buena practica **NO incluir los al hacer un commit en algun repositorio**
En caso contrario no es necesario asignar valores ya que serán enviados por medio de variables de entorno en los archivos .yaml

### Api Node
El api de Node tiene como objetivo mantener una comunicación con la BD de Mongo, en el cual se estaran realizando operaciones de ```GET```, ```POST``` y  ```DELETE```.
**Importante:** Si quieres ejecutar este proyecto en VS Code, primero debes crear un archivo ```.env``` para poder configurar las varaibles de entorno, las cuales son las siguientes:
```
PORT=3000 # puerto de api
MONGO_URI=mongodb://admin:adminpassword@localhost:27017/blockstellart?authSource=admin # Cadena de conexión a mongo DB
```

Para ejecutar lo en VS Code utiliza los siguientes comandos y **recuerda ejecutar primero la BD y tener instalado Node**

```npm install```
```npm start```

Una vez que se incie el servicio, podras ver los siguientes mensajes en consola:
```
Servidor corriendo en http://localhost:3000
🚀 Conexión exitosa a MongoDB
```
### WebApp (Angular)
El projecto de angular tiene como objetivo mostrar la información que se obtiene de la api de pokemon y realizar operaciones sobre la BD de mongo, además de la opción de enviar por email los pokemon que se tengan guardados en mongoDB

Si deseas ejecutar el proyecto en VS Code de manera independiente deberas considerar las siguientes configuraciones:
1. Instalación de Node
```
https://nodejs.org/en
```
2. Instala la version de angular correspondiente (si no lo tienes instalado):
```
npm install -g @angular/cli@15.0.0
```
3. Configura las variables de entorno para el proyecto
```
export const environment = {
    production: false,
    apiUrl: 'http://localhost:3000/api/', // Reemplaza con tu URL de la Api de Node
    apiUrlNet: 'http://localhost:8080/api/email/' // Remplaza con la URL de el api de .NET
};
```
Ejecuta los siguientes comandos para el proyecto
a. Instalamos los paquetes del proyecto
```
npm install
```
b.  Ejecutamos el proyecto
```
ng serve
```

## • Ejecución Local con Docker

### Base de datos MongoDB
Para poder ejecutar el contenedor, ejecuta el siguiente comando de Docker:

```
 docker run --name mongodb -dp 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=adminpassword -e MONGO_INITDB_DATABASE=blockstellart -v mongo-data:/data/db mongo:latest
```

**Recuerda** que para la conexión entre contenedores debes crera una red
```
docker network create blockstellart-network
```
```
docker network connect blockstellart-network mongodb
```

## Apis

### Api .NET
Para ejecutar el contenedor del api de .NET, ejecuta el siguiente comando de Docker:
1. Construimos la imagen
```
docker build -t blockstellart.net .
```
2. Ejecutamos el contenedor
**Recuerda** remplazar los valores de ```ACCESS``` y ```SECRET```, así como el ```EMAIL``` que se utilizara
```
docker run -dp 8080:8080 --name blockstellart.apinet -e AWS_ACCESS_KEY_ID="" -e AWS_SECRET_ACCESS_KEY="" -e AWS_REGION="us-east-1" -e EMAILVERIFICADO="" blockstellart.net
```
3. Recuerda añadir lo a la red
```
docker network connect blockstellart-network blockstellart.apinet
```
### Api Node
Para ejecutar el contenedor del api de Node, ejecuta el siguiente comando de Docker:
1. Construimos la imagen
```
docker build -t blockstellart.node .
```
2. Ejecutamos el contenedor
Utilizamos el mismo archivo de .env o puedes enviarle los parametros de ```PORT``` y ```MONGO_URI``` utilizando ```-e```

3. Ejecutamos el contenedor
```
docker run -dp 3000:3000 --name blockstellart.apinode -e PORT=3000 -e MONGO_URI=mongodb://admin:adminpassword@mongodb:27017/blockstellart?authSource=admin  blockstellart.node
```
4. Recuerda añadir lo a la red
```
docker network connect blockstellart-network blockstellart.apinode
```

### Aplicacion Web (Angular)
1.Creamos o configuramos el archivo ```assets\config.json``` con los valores correspondientes
URL del API de Node
```
"apiUrl": "http://localhost:3000/api/",  
```
URL del API de .NET
```
"apiUrlNet": "http://localhost:8080/api/"
```

2. Construimos la imagen
```
docker build -t blockstellart.webapp .
```

3. Ejecutamos el contenedor
```
docker run -dp 85:80 --name blockstellart.webpokemon -e APIURL="http://localhost:3000/api/" -e APIURLNET="http://localhost:8080/api/" blockstellart.webapp
```

4. Recuerda añadir lo a la red
```
docker network connect blockstellart-network blockstellart.webpokemon
```

## • Ejecución de Kubernetes en Local

#### Instalación
```
https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download
```

#### Inicia Minikube
```
minikube start
```

#### Configuraciones necesarias en deployment-mongodb.yml
1. La imagen de mongo se obtiene directamente del [sitio oficial](https://hub.docker.com/_/mongo) en DockerHub

2. Configura los siguientes datos:
```yaml
containers:
  - name: mongodb
    image: mongo:latest # imagen de DockerHub
    ports:
    - containerPort: 27017 # Puerto default
    env:
    - name: MONGO_INITDB_ROOT_USERNAME
      value: "admin" # Usuario
    - name: MONGO_INITDB_ROOT_PASSWORD
      value: "adminpassword" # password
    - name: MONGO_INITDB_DATABASE
      value: "blockstellart" # Nombre de la BD
    volumeMounts: # Monte un volumen para persistencia de datos
    - name: mongo-data
      mountPath: /data/db
```

#### Configuraciones necesarias en deployment-api-net.yml
1. Despliega tu imagene en Amazon ECR siguiendo las instrucciones proporcionadas
**Nota:** El API de .NET se encarga de la comunicación con el servicio de Amazon SES para el envío de email
2. Configura los siguientes datos:

```yaml
containers:
  image: <url de Amazon ECR>
  ports:
  - containerPort: 8080 # Puerto Http
  env:
  - name: AWS_ACCESS_KEY_ID
    value: "<tu access key>"
  - name: AWS_SECRET_ACCESS_KEY
    value: "<tu secret access>"
  - name: AWS_REGION
    value: "us-east-1"
  - name: EMAILVERIFICADO
    value: "<email a utilizar>"
```

#### Configuraciones necesarias en deployment-node-net.yml
1. Despliega tu imagene en Amazon ECR siguiendo las instrucciones proporcionadas
**Nota:** El API de node se encarga de las operaciones ```GET```, ```POST``` y ```DELETE``` en MongoDB
2. Configura los siguientes datos:
```yaml
containers:
  - name: apinode
    image: <url de Amazon ECR>
    ports:
    - containerPort: 3000 # Puerto Http
    env:
    - name: PORT
      value: "3000" # Puerto del servicio
    - name: MONGO_URI
      value: "mongodb://admin:adminpassword@mongodb:27017/blockstellart?authSource=admin" # cadena de conexión a MongoDB
```
En la siguiente tabla se puede observar más detalles de cada parámetro para la conexión a mongoDB
| **Parámetro**           | **Configurabilidad**                        |
|--------------------------|---------------------------------------------|
| `mongodb://`             | Fijo (protocolo).                          |
| `admin`                  | Configurable (nombre de usuario).          |
| `adminpassword`          | Configurable (contraseña).                 |
| `mongodb`                | Configurable (host o IP del servidor).     |
| `27017`                  | Configurable (puerto).                     |
| `blockstellart`          | Configurable (nombre de la base de datos). |
| `?authSource=admin`      | Configurable (base de datos de autenticación). |


Si quieres más detalles sobre la imagen de mongodb consulta la información en: [MongoDB DockerHub](https://hub.docker.com/_/mongo)

#### Configuraciones necesarias en deployment-webapp.yml
1. Despliega tu imagene en Amazon ECR siguiendo las instrucciones proporcionadas
**Nota:** La aplicación web muestra al usuario las operaciones que se puede realizar y mantiene comunicación con las apis (Node, .NET y PokemonAPI) 
2. Configura los siguientes datos:
```yaml
containers:
  - name: webapp
    image: <url de Amazon ECR>
    ports:
    - containerPort: 80
    env:
    - name: API_NODE
      value: "http://127.0.0.1:90/api/" # Url de Api de Node
    - name: API_NET
      value: "http://localhost:8080/api/" # Url de Api de .NET
```

En un entorno local, los parámetros que recibe la aplicación debería ser:
```yaml
-name: API_NODE
  value: "http://127.0.0.1:90/api/"
-name: API_NET
  value: "http://127.0.0.1:8080/api/"
```


## • Despliegue local en kubernetes
Una vez que tengas las configuraciones aplicadas aplica los siguientes comandos:
Ejecuta los siguientes comandos después de haber ejecutado ```minikube start```

1. Ejecutamos los comandos para la BD, servicios y la aplicación web

```
kubectl apply -f .\MongoDB\deployment-mongodb.yml
kubectl apply -f .\MongoDB\service-mongodb.yml

kubectl apply -f .\APINode\deployment-api-node.yml
kubectl apply -f .\APINode\service-api-node.yml

kubectl apply -f .\APINet\deployment-api-net.yml
kubectl apply -f .\APINet\service-api-net.yml

kubectl apply -f .\WebApp\deployment-webapp.yml
kubectl apply -f .\WebApp\service-webapp.yml
```
2. Confirmamos con los siguientes comandos:
```
kubectl get pods
kubectl get services
```
**Nota:** Al ver la lista de servicios la columna de EXTERNAL-IP contendra el siguiente valor: ```<pending>```

Para poder acceder a ellos desde un navegador es necesario ejecutar el siguiente comando:
```
minikube tunnel
```
**importante:** La linea de comando (cmd) dónde se ejecuta el tunnel no debe ser cerrada, ya que de hacer lo perderan la ip.

3. Confirmamos la asignación de ip 
```
kubectl get services
```

De esta forma se les asignara una ip (127.0.0.1) pero con el puerto configurado en los archivos .yaml

4. Accedemos con algun navegador a la direccion ```http://localhost:85``` para poder acceder a la pagina web

#### Eliminación de servicios y pods
```
kubectl delete -f .\MongoDB\deployment-mongodb.yml
kubectl delete -f .\MongoDB\service-mongodb.yml

kubectl delete -f .\APINode\deployment-api-node.yml
kubectl delete -f .\APINode\service-api-node.yml

kubectl delete -f .\APINet\deployment-api-net.yml
kubectl delete -f .\APINet\service-api-net.yml

kubectl delete -f .\WebApp\deployment-webapp.yml
kubectl delete -f .\WebApp\service-webapp.yml
```


#### Ver  los nodos del cluster
```
kubectl get nodes
```

#### Ver en qué nodo están los Pods
```
kubectl get pods -o wide
```

## • Ejecución de Kubernetes en AWS


#### Requisitos para poder ejecutar los comandos
1. Instala [eksctl](https://eksctl.io/installation/)

#### Crear cluster
Una vez instalado, crea un cluster
```
eksctl create cluster --name blockstellart-cluster --region us-east-1 --nodes 2 --node-type t3.medium
```

Nota: Para que el cluster pueda operar correctamente considera cambiar a un t3.medium o algun otro, ya que pueden surgir errores por falta de recursos

##### En caso de que no quieras utilizar un tipo de instancia diferente puedes utilizar el siguiente comando para poder escalar con una instancia básica
```
eksctl create nodegroup --cluster blockstellart-cluster --nodes-min 1 --nodes-max 5 --nodes 2 --name autoscaling-nodegroup --node-type t3.micro  --region us-east-1 
```

#### Cambia al entorno de AWS para despliega tus manifiestos en aws
```
aws eks update-kubeconfig --region us-east-1 --name mi-cluster
```

#### Configuraciones necesarias en deployment-webapp.yml
1. Considera ejecutar primero la BD y los servicios (Node y .NET)
```
kubectl apply -f .\MongoDB\deployment-mongodb.yml
kubectl apply -f .\MongoDB\service-mongodb.yml

kubectl apply -f .\APINode\deployment-api-node.yml
kubectl apply -f .\APINode\service-api-node.yml

kubectl apply -f .\APINet\deployment-api-net.yml
kubectl apply -f .\APINet\service-api-net.yml
```

2. Una vez que la ejecución se realice correctamente, copia las url y actualiza las variables de entorno del archivo ```deployment-web-app.yml```
```yaml
-name: APIURL
  value: "http://<url.aws>.us-east-1.elb.amazonaws.com:90"
-name: APIURLNET
  value: "http://<url.aws>.us-east-1.elb.amazonaws.com:90"
```

3. Una vez aplicado el cambio, ejecuta el comando

```
kubectl apply -f .\WebApp\deployment-webapp.yml
kubectl apply -f .\WebApp\service-webapp.yml
```

#### Eliminación de servicios y pods
```
kubectl delete -f .\MongoDB\deployment-mongodb.yml
kubectl delete -f .\MongoDB\service-mongodb.yml

kubectl delete -f .\APINode\deployment-api-node.yml
kubectl delete -f .\APINode\service-api-node.yml

kubectl delete -f .\APINet\deployment-api-net.yml
kubectl delete -f .\APINet\service-api-net.yml

kubectl delete -f .\WebApp\deployment-webapp.yml
kubectl delete -f .\WebApp\service-webapp.yml
```

#### Eliminar cluster
```
eksctl delete cluster --name blockstellart-cluster --region us-east-1
```

## • Otros comandos
Si quieres regresar a tu entorno local utiliza el siguiente comando
```
kubectl config use-context minikube
```
Si quieres cambiar al entorno de aws utiliza el siguiente comando
```
aws eks update-kubeconfig --region us-east-1 --name mi-cluster
```
=======
# jenkins
practicing jenkins
>>>>>>> aa809459c53479daa13033fa81a98ed05238cecf
