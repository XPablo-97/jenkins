#!/bin/sh

# Crear el directorio assets si no existe
mkdir -p /usr/share/nginx/html/assets

# Crear el archivo de configuración JSON
cat <<EOF > /usr/share/nginx/html/assets/config.json
{
  "apiNode": "${API_NODE}",
  "apiNet": "${API_NET}"
}
EOF

# Iniciar Nginx
nginx -g 'daemon off;'