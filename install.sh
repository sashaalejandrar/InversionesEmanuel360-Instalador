#!/usr/bin/env bash
# ============================================================
#  InversionesEmanuel360 - Instalador local (Linux)
#  Detecta SO, busca LAMPP/XAMPP, lo instala si falta,
#  copia el sistema, crea la BD y el usuario admin.
#  Uso: bash install.sh
# ============================================================
set -e

echo "============================================================"
echo "  INVERSIONES EMANUEL 360 - Instalador local"
echo "  ReySystem - Los Reyes de la Tecnologia"
echo "============================================================"
echo

# ---------- 1) Detectar SO ----------
echo "[1/6] Detectando sistema operativo..."
OS="$(uname -s)"
case "$OS" in
  Linux*)  ;; 
  *) echo "  ERROR: Este instalador es para Linux. En Windows use install.bat"; exit 1 ;;
esac
echo "  Linux detectado."

# ---------- 2) Localizar LAMPP/XAMPP ----------
echo "[2/6] Buscando LAMPP/XAMPP..."
LAMPP=""
for d in /opt/lampp /opt/xampp /usr/local/lampp "$HOME/lampp"; do
  [ -x "$d/bin/php" ] && LAMPP="$d" && break
done

if [ -z "$LAMPP" ]; then
  echo "  No se encontro LAMPP/XAMPP. Descargando e instalando XAMPP..."
  VER="8.2.12"
  FILE="xampp-linux-x64-$VER-0-installer.run"
  URL="https://downloads.sourceforge.net/project/xampp/XAMPP%20Linux/$VER/$FILE"
  TMP="$(mktemp -d)"
  echo "  Descargando $FILE (puede tardar)..."
  if command -v curl >/dev/null; then
    curl -fL "$URL" -o "$TMP/$FILE"
  else
    wget -O "$TMP/$FILE" "$URL"
  fi
  chmod +x "$TMP/$FILE"
  echo "  Instalando en /opt/lampp (requiere sudo)..."
  sudo "$TMP/$FILE" --mode unattended --prefix /opt/lampp || sudo "$TMP/$FILE"
  rm -rf "$TMP"
  LAMPP=/opt/lampp
fi

echo "  LAMPP/XAMPP en: $LAMPP"
PHPBIN="$LAMPP/bin/php"
MYSQL="$LAMPP/bin/mysql"
HTDOCS="$LAMPP/htdocs"
[ -x "$PHPBIN" ] || PHPBIN="$(command -v php)"
[ -x "$MYSQL" ] || MYSQL="$(command -v mysql)"
echo

# ---------- 3) Obtener el sistema ----------
echo "[3/6] Obteniendo archivos del sistema..."
APPDIR="$HTDOCS/InversionesEmanuel"
SRC="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SRC/public/index.php" ]; then
  echo "  Copiando desde: $SRC"
  mkdir -p "$APPDIR"
  tar cf - --exclude=.git --exclude=.env --exclude=node_modules . | tar xf - -C "$APPDIR"
else
  echo "  Descargando desde GitHub..."
  TMP="$(mktemp -d)"
  curl -fL "https://github.com/sashaalejandrar/InversionesEmanuel360/archive/refs/heads/main.zip" -o "$TMP/app.zip" || \
  curl -fL "https://github.com/sashaalejandrar/InversionesEmanuel360/archive/refs/heads/master.zip" -o "$TMP/app.zip"
  unzip -q "$TMP/app.zip" -d "$TMP"
  rm -rf "$APPDIR"
  mv "$TMP"/InversionesEmanuel360-* "$APPDIR"
  rm -rf "$TMP"
fi
echo "  Sistema en: $APPDIR"
echo

# ---------- 4) .env ----------
echo "[4/6] Configurando entorno..."
if [ ! -f "$APPDIR/.env" ]; then
cat > "$APPDIR/.env" <<'ENV'
APP_ENV=production
APP_DEBUG=false
APP_URL=http://localhost/InversionesEmanuel
APP_KEY=
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=inversiones_emanuel
DB_USER=root
DB_PASS=
MAIL_HOST=localhost
MAIL_PORT=25
ENV
fi
echo "  .env listo."
echo

# ---------- 5) BD + admin ----------
echo "[5/6] Creando base de datos e importando..."
sudo "$LAMPP/lampp" startmysql >/dev/null 2>&1 || sudo service mysql start >/dev/null 2>&1 || true
sleep 2
"$MYSQL" -u root -e "CREATE DATABASE IF NOT EXISTS inversiones_emanuel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || \
  sudo "$MYSQL" -u root -e "CREATE DATABASE IF NOT EXISTS inversiones_emanuel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
for f in "$APPDIR"/database/migrations/*.sql; do
  echo "  Importando $(basename "$f")..."
  "$MYSQL" -u root inversiones_emanuel < "$f" 2>/dev/null || \
    sudo "$MYSQL" -u root inversiones_emanuel < "$f"
done

ADMINPASS="$(head -c 200 /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 12)"
[ ${#ADMINPASS} -lt 8 ] && ADMINPASS="Admin2026!"
echo "  Creando usuario administrador..."
"$PHPBIN" "$APPDIR/scripts/install_cli.php" admin "Administrador" "admin@local" "$ADMINPASS" || \
  sudo -u "$(whoami)" "$PHPBIN" "$APPDIR/scripts/install_cli.php" admin "Administrador" "admin@local" "$ADMINPASS"
echo

# ---------- 6) Arranque ----------
echo "[6/6] Arrancando servicios..."
sudo "$LAMPP/lampp" startapache >/dev/null 2>&1 || sudo service apache2 start >/dev/null 2>&1 || true
sleep 3
echo
echo "============================================================"
echo "  INSTALACION COMPLETADA"
echo "============================================================"
echo
echo "  Abra en su navegador:"
echo "  http://localhost/InversionesEmanuel"
echo
echo "  Usuario administrador: admin"
echo "  Contrasena: $ADMINPASS"
echo "  (cambiela al entrar desde Mi perfil)"
echo
