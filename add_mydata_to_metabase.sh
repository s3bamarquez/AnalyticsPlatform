#!/usr/bin/env bash
set -eo pipefail

# Directorio del script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Cargar variables del archivo .env
set -a
source "$SCRIPT_DIR/.env"
set +a

# Espera a que Metabase esté disponible
until curl -s http://metabase:3000/api/health | grep -q '"ok":true'; do
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
  http://metabase:3000/api/database | jq -r --arg name "$MYDATA_DB_NAME" '.[] | select(.name == $name) | .id')
if [ -z "$EXISTING_DB" ]; then
  echo "Creando conexión a la base de datos $MYDATA_DB_NAME..."
  curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "X-Metabase-Session: $MB_SESSION" \
    -d "{\n    \"name\": \"$MYDATA_DB_NAME\",\n    \"engine\": \"postgres\",\n    \"details\": {\n      \"host\": \"db\",\n      \"port\": 5432,\n      \"dbname\": \"$MYDATA_DB_NAME\",\n      \"user\": \"$MYDATA_DB_USER\",\n      \"password\": \"$MYDATA_DB_PASSWORD\"\n    }\n  }" \
    http://metabase:3000/api/database
else
  echo "La conexión $MYDATA_DB_NAME ya existe (id $EXISTING_DB)"
fi
