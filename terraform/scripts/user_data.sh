#!/bin/bash
# Este script documenta y automatiza la instalacion manual que se hizo
# originalmente en la instancia "jenkins": Docker + contenedores de
# Jenkins, SonarQube y la app Angular.
#
# Solo corre UNA VEZ, la primera vez que arranca una instancia nueva
# creada a partir de esta configuracion. No se ejecuta sobre instancias
# ya existentes.

set -euxo pipefail

# --- Instalar Docker Engine (Ubuntu) ---
apt-get update -y
apt-get install -y ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

# --- Jenkins ---
docker volume create jenkins_home

docker run -d \
  --name jenkins \
  --restart always \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Darle CLI de Docker al contenedor de Jenkins (Docker outside of Docker),
# para que los pipelines puedan correr "docker build" / "docker run".
sleep 15
docker exec -u root jenkins bash -c "apt-get update && apt-get install -y docker.io"

# --- SonarQube ---
docker run -d \
  --name sonarqube \
  --restart always \
  -p 9000:9000 \
  sonarqube:lts-community

# --- Angular App ---
docker run -d \
  --name app-angular \
  --restart always \
  -p 8081:80 \
  pablo097/angular-app:latest
