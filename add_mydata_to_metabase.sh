#!/usr/bin/env sh
set -e

# Directorio del script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Cargar variables del archivo .env
ENV_FILE="$SCRIPT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
  # Elimina retornos de carro por si el archivo usa formato Windows
  tr -d '\r' < "$ENV_FILE" > /tmp/.env && ENV_FILE=/tmp/.env
fi
set -a
. "$ENV_FILE"
set +a

# Espera a que Metabase esté disponible
until curl -s http://metabase:3000/api/health | jq -e '.status == "ok"' >/dev/null; do
  echo "Esperando a que Metabase esté listo..."
  sleep 5
done

# Verificar si la configuración inicial fue completada
SETUP_TOKEN=$(curl -s http://metabase:3000/api/session/properties | jq -r '."setup-token"')
if [ "$SETUP_TOKEN" != "null" ]; then
  echo "Realizando configuración inicial de Metabase..."
  curl -s -X POST \
    -H "Content-Type: application/json" \
    -d "{\"token\": \"$SETUP_TOKEN\", \"user\": {\"email\": \"$MB_ADMIN_EMAIL\", \"password\": \"$MB_ADMIN_PASSWORD\", \"first_name\": \"$MB_ADMIN_FIRST_NAME\", \"last_name\": \"$MB_ADMIN_LAST_NAME\"}, \"prefs\": {\"site_name\": \"Metabase\"}}" \
    http://metabase:3000/api/setup
fi

# Autenticación en Metabase
MB_SESSION=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"$MB_ADMIN_EMAIL\", \"password\": \"$MB_ADMIN_PASSWORD\"}" \
  http://metabase:3000/api/session | jq -r .id)

# Crear la conexión a la base de datos MyData si no existe
EXISTING_DB=$(curl -s -H "X-Metabase-Session: $MB_SESSION" \
  http://metabase:3000/api/database | jq -r --arg name "$MYDATA_DB_NAME" '.data[]? | select(.name == $name) | .id')
if [ -z "$EXISTING_DB" ]; then
  echo "Creando conexión a la base de datos $MYDATA_DB_NAME..."
  JSON_PAYLOAD=$(cat <<EOF
{
  "name": "$MYDATA_DB_NAME",
  "engine": "postgres",
  "details": {
    "host": "db",
    "port": 5432,
    "dbname": "$MYDATA_DB_NAME",
    "user": "$MYDATA_DB_USER",
    "password": "$MYDATA_DB_PASSWORD"
  }
}
EOF
  )
  curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "X-Metabase-Session: $MB_SESSION" \
    -d "$JSON_PAYLOAD" \
    http://metabase:3000/api/database
else
  echo "La conexión $MYDATA_DB_NAME ya existe (id $EXISTING_DB)"
fi
