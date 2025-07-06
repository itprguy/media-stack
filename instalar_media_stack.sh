#!/bin/bash

# Script para instalar automáticamente media stack con docker-compose
# Autor: Daniel Marte

# Preguntar al usuario dónde desea guardar los datos
read -rp "📂 ¿Dónde deseas guardar la estructura de datos? (por ejemplo: /opt/media) " BASE_PATH

# Validar input
if [ -z "$BASE_PATH" ]; then
  echo "❌ Ruta no válida. Cancelando instalación."
  exit 1
fi

# Crear directorio base si no existe
mkdir -p "$BASE_PATH"
cd "$BASE_PATH" || exit 1

# Verificar si Docker está instalado
if ! command -v docker &>/dev/null; then
  echo "🐳 Docker no está instalado. Instalando..."
  curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
  sudo usermod -aG docker "$USER"
  echo "🔁 Por favor cierra sesión y vuelve a entrar para aplicar cambios de grupo Docker."
fi

# Verificar si Docker Compose está instalado
if ! command -v docker-compose &>/dev/null && ! docker compose version &>/dev/null; then
  echo "⚙️ Instalando Docker Compose plugin..."
  sudo apt-get update && sudo apt-get install -y docker-compose-plugin
fi

# Crear estructura de carpetas
echo "📁 Creando estructura de carpetas en $BASE_PATH..."
DIRS=(
  "$BASE_PATH/tank/configs/bazarr"
  "$BASE_PATH/tank/configs/dozzle"
  "$BASE_PATH/tank/configs/flaresolverr"
  "$BASE_PATH/tank/configs/heimdall/www/app/storage"
  "$BASE_PATH/tank/configs/jackett"
  "$BASE_PATH/tank/configs/jellyfin"
  "$BASE_PATH/tank/configs/jellyseerr"
  "$BASE_PATH/tank/configs/nzbget"
  "$BASE_PATH/tank/configs/prowlarr"
  "$BASE_PATH/tank/configs/qbittorrent"
  "$BASE_PATH/tank/configs/radarr"
  "$BASE_PATH/tank/configs/recyclarr"
  "$BASE_PATH/tank/configs/sabnzbd"
  "$BASE_PATH/tank/configs/sonarr"
  "$BASE_PATH/tank/configs/tdarr"
  "$BASE_PATH/tank/configs/watchtower"
  "$BASE_PATH/tank/media/downloads/torrent"
  "$BASE_PATH/tank/media/movies"
  "$BASE_PATH/tank/media/tv"
)

for dir in "${DIRS[@]}"; do
  mkdir -p "$dir"
  chown "$USER:$USER" "$dir"
done

# Crear archivo bookmarks.json vacío si no existe
BOOKMARKS="$BASE_PATH/tank/configs/heimdall/www/app/storage/bookmarks.json"
if [ ! -f "$BOOKMARKS" ]; then
  echo "[]" > "$BOOKMARKS"
  chown "$USER:$USER" "$BOOKMARKS"
fi

# Crear archivo .env
cat <<EOF > "$BASE_PATH/.env"
PUID=1000
PGID=1000
TZ=America/Puerto_Rico
EOF
chown "$USER:$USER" "$BASE_PATH/.env"

# Descargar docker-compose.yml preconfigurado
COMPOSE_URL="https://raw.githubusercontent.com/danielmarte/media-stack/main/docker-compose.yml"
if curl -fsSL "$COMPOSE_URL" -o "$BASE_PATH/docker-compose.yml"; then
  echo "✅ docker-compose.yml descargado."
else
  echo "⚠️ No se pudo descargar docker-compose.yml desde $COMPOSE_URL"
  exit 1
fi

# Levantar contenedores
cd "$BASE_PATH" || exit

echo "🚀 Levantando contenedores..."
docker compose up -d

# Confirmación final
echo "✅ Instalación completada. Heimdall estará disponible pronto en http://localhost"
