# Etapa 1: Instalar dependencias y construir la aplicación
FROM node:18 AS build

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos de dependencias
COPY package*.json ./

# Instala las dependencias
RUN npm install --production

# Copia el resto del código
COPY . .

# Etapa 2: Crear el contenedor final
FROM node:18-alpine

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos desde la etapa de build
COPY --from=build /app /app

# Expone el puerto
EXPOSE 3000

# Comando por defecto
CMD ["node", "index.js"]
