#!/usr/bin/env bash
# Cargar variables del archivo .env
set -a
source .env
set +a

# Espera a que Metabase esté disponible
until curl -s http://metabase:3000/api/health | grep -q '"ok":true'; do
  echo "Esperando a que Metabase esté listo..."
  sleep 5
done

# Autenticación en Metabase
MB_SESSION=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"$MB_ADMIN_EMAIL\", \"password\": \"$MB_ADMIN_PASSWORD\"}" \
  http://metabase:3000/api/session | jq -r .id)

# Crear la conexión a la base de datos MyData
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "X-Metabase-Session: $MB_SESSION" \
  -d "{\n    \"name\": \"$MYDATA_DB_NAME\",\n    \"engine\": \"postgres\",\n    \"details\": {\n      \"host\": \"db\",\n      \"port\": 5432,\n      \"dbname\": \"$MYDATA_DB_NAME\",\n      \"user\": \"$MYDATA_DB_USER\",\n      \"password\": \"$MYDATA_DB_PASSWORD\"\n    }\n  }" \
  http://metabase:3000/api/database
