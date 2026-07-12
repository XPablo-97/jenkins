# 1) Build Angular
FROM node:22-slim AS build-stage
ENV NG_CLI_ANALYTICS=false
WORKDIR /app

# Copia solo manifests y config necesarios para instalar deps
COPY package*.json angular.json tsconfig*.json ./

# Instala deps
RUN npm install

# Copia el resto del código y construye
COPY . .
RUN npm run build -- --configuration=production

# 2) Nginx
FROM nginx:stable-alpine AS production-stage

# Copia la carpeta de build (según tu angular.json - Angular 17+ genera browser/)
COPY --from=build-stage /app/dist/WebApp/browser /usr/share/nginx/html

# Config SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Script de arranque
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
RUN apk add --no-cache dos2unix && dos2unix /usr/local/bin/start.sh

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/start.sh"]
