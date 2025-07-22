# PowerShell script para limpiar y reiniciar el proyecto desde cualquier ubicación
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $scriptDir

# Actualiza el código del repositorio antes de continuar
Write-Host "Actualizando el código del repositorio..."
git pull

Write-Host "Deteniendo y eliminando contenedores..."
docker compose down -v

Write-Host "Eliminando imágenes huérfanas..."
docker image prune -f

Write-Host "Iniciando el proyecto desde cero..."
docker compose up --build
