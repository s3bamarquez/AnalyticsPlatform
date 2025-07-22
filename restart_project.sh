#!/usr/bin/env bash
# Script para limpiar y reiniciar el proyecto desde cualquier ubicación (Linux/Mac)

cd "$(dirname "$0")"

echo "Deteniendo y eliminando contenedores..."
docker-compose down -v

echo "Eliminando imágenes huérfanas..."
docker image prune -f

echo "Iniciando el proyecto desde cero..."
docker-compose up --build
