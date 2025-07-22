# PowerShell script para limpiar y reiniciar el proyecto desde cero
Write-Host "Deteniendo y eliminando contenedores..."
docker-compose down -v

Write-Host "Eliminando imágenes huérfanas..."
docker image prune -f

Write-Host "Iniciando el proyecto desde cero..."
docker-compose up --build
