@echo off
setlocal EnableDelayedExpansion
title Instalador - InversionesEmanuel360
color 0A

echo ============================================================
echo   INVERSIONES EMANUEL 360 - Instalador local
echo   ReySystem - Los Reyes de la Tecnologia
echo ============================================================
echo.

REM ============================================================
REM 1) DETECTAR SISTEMA OPERATIVO
REM ============================================================
echo [1/6] Detectando sistema operativo...
ver | find "Windows" >nul
if errorlevel 1 (
    echo.
    echo   ERROR: Este instalador es para Windows.
    echo   En Linux use: bash install.sh
    echo.
    pause
    exit /b 1
)
echo   Windows detectado correctamente.
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set ARCH=x64) else (set ARCH=x86)
echo   Arquitectura: %ARCH%
echo.

REM ============================================================
REM 2) DETECTAR XAMPP O WAMP
REM ============================================================
echo [2/6] Buscando XAMPP o WAMP...
set XBEE=
set WAMP=

if exist "C:\xampp\php\php.exe" set XBEE=C:\xampp
if exist "C:\wamp64\bin\apache" set WAMP=C:\wamp64
if exist "C:\wamp\bin\apache" set WAMP=C:\wamp

if defined XBEE (
    echo   XAMPP encontrado en: %XBEE%
    set HTDOCS=%XBEE%\htdocs
    set MYSQL=%XBEE%\mysql\bin\mysql.exe
    set PHPBIN=%XBEE%\php\php.exe
) else if defined WAMP (
    echo   WAMP encontrado en: %WAMP%
    set HTDOCS=%WAMP%\www
    for /d %%D in ("%WAMP%\bin\mysql\mysql*") do set MYSQL=%%D\bin\mysql.exe
    for /d %%D in ("%WAMP%\bin\php\php*") do set PHPBIN=%%D\php.exe
    if not defined MYSQL set MYSQL=%WAMP%\bin\mysql\mysql8.0.40\bin\mysql.exe
    if not defined PHPBIN set PHPBIN=%WAMP%\bin\php\php8.3.14\php.exe
) else (
    echo   No se encontro XAMPP ni WAMP. Descargando XAMPP portable...
    echo   Esto puede tardar varios minutos segun la conexion.
    echo.
    powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://downloads.sourceforge.net/project/xampp/XAMPP%%20Windows/8.2.12/xampp-portable-win32-8.2.12-0-VS16.zip' -OutFile '%TEMP%\xampp-portable.zip' -UseBasicParsing"
    if errorlevel 1 (
        echo.
        echo   ERROR: No se pudo descargar XAMPP.
        echo   Descarguelo manualmente de https://www.apachefriends.org y
        echo   descomprimelo en C:\xampp , luego vuelva a ejecutar este instalador.
        pause
        exit /b 1
    )
    echo   Descargado. Extrayendo en C:\xampp ...
    powershell -NoProfile -Command "Expand-Archive -Path '%TEMP%\xampp-portable.zip' -DestinationPath 'C:\' -Force"
    if not exist "C:\xampp\php\php.exe" (
        echo.
        echo   ERROR: La extraccion fallo. Verifique que C:\xampp\php\php.exe exista.
        pause
        exit /b 1
    )
    set XBEE=C:\xampp
    set HTDOCS=%XBEE%\htdocs
    set MYSQL=%XBEE%\mysql\bin\mysql.exe
    set PHPBIN=%XBEE%\php\php.exe
    del "%TEMP%\xampp-portable.zip" >nul 2>&1
    echo   XAMPP portable instalado en C:\xampp
)
echo.

REM ============================================================
REM 3) OBTENER EL SISTEMA (local o desde GitHub)
REM ============================================================
echo [3/6] Obteniendo archivos del sistema...
set APPDIR=%HTDOCS%\InversionesEmanuel
set SRC=%~dp0
if not exist "%SRC%public\index.php" set SRC=

if defined SRC (
    echo   Copiando desde la carpeta del instalador: %SRC%
    if exist "%APPDIR%" rmdir /s /q "%APPDIR%"
    mkdir "%APPDIR%"
    xcopy "%SRC%*" "%APPDIR%\" /E /I /Q /EXCLUDE:"%~dp0install.exclude" >nul
    if exist "%~dp0install.exclude" goto :copydone
) else (
    echo   Descargando ultima version desde GitHub...
    powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/sashaalejandrar/InversionesEmanuel360/archive/refs/heads/main.zip' -OutFile '%TEMP%\ie360.zip' -UseBasicParsing"
    if errorlevel 1 (
        echo   Intentando rama master...
        powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/sashaalejandrar/InversionesEmanuel360/archive/refs/heads/master.zip' -OutFile '%TEMP%\ie360.zip' -UseBasicParsing"
    )
    powershell -NoProfile -Command "Expand-Archive -Path '%TEMP%\ie360.zip' -DestinationPath '%TEMP%\ie360src' -Force"
    for /d %%D in ("%TEMP%\ie360src\InversionesEmanuel360-*") do set SRCDIR=%%D
    if exist "%APPDIR%" rmdir /s /q "%APPDIR%"
    xcopy "%SRCDIR%\*" "%APPDIR%\" /E /I /Q >nul
    rmdir /s /q "%TEMP%\ie360src" >nul 2>&1
    del "%TEMP%\ie360.zip" >nul 2>&1
)
:copydone
echo   Sistema instalado en: %APPDIR%
echo.

REM ============================================================
REM 4) CONFIGURAR .ENV
REM ============================================================
echo [4/6] Configurando entorno...
if exist "%APPDIR%\.env" goto :envskip
set APPKEY=
for /f "delims=" %%K in ('powershell -NoProfile -Command "$k=[guid]::NewGuid().ToString(''N'')+[guid]::NewGuid().ToString(''N''); Write-Output $k"') do set APPKEY=%%K
if not defined APPKEY set APPKEY=ie360-local-key
(
echo APP_ENV=production
echo APP_DEBUG=false
echo APP_URL=http://localhost/InversionesEmanuel
echo APP_KEY=%APPKEY%
echo DB_HOST=127.0.0.1
echo DB_PORT=3306
echo DB_NAME=inversiones_emanuel
echo DB_USER=root
echo DB_PASS=
echo MAIL_HOST=localhost
echo MAIL_PORT=25
) > "%APPDIR%\.env"
:envskip
echo   Archivo .env listo.
echo.

REM ============================================================
REM 5) CREAR E IMPORTAR BASE DE DATOS + USUARIO ADMIN
REM ============================================================
echo [5/6] Creando base de datos e importando estructura...
"%MYSQL%" -u root -e "CREATE DATABASE IF NOT EXISTS inversiones_emanuel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
if errorlevel 1 (
    echo   NOTA: MySQL no respondio. Si WAMP/XAMPP aun no esta iniciado,
    echo   inicie el servicio MySQL e importe manualmente:
    echo   %MYSQL% -u root inversiones_emanuel ^< database\migrations\001_init.sql
    goto :dbskip
)
for %%F in ("%APPDIR%\database\migrations\*.sql") do (
    echo   Importando %%~nxF ...
    "%MYSQL%" -u root inversiones_emanuel < "%%F"
)
echo   Base de datos lista.

REM Generar clave de administrador aleatoria
set ADMINPASS=
for /f "delims=" %%P in ('powershell -NoProfile -Command "$p=[guid]::NewGuid().ToString(''N'').Substring(0,12); Write-Output $p"') do set ADMINPASS=%%P
if not defined ADMINPASS set ADMINPASS=Admin2026!

echo   Creando roles, permisos y usuario administrador...
"%PHPBIN%" "%APPDIR%\scripts\install_cli.php" admin "Administrador" "admin@local" "%ADMINPASS%"
if errorlevel 1 (
    echo   AVISO: no se pudo crear el usuario admin automaticamente.
    echo   Ejecutelo manualmente:
    echo   %PHPBIN% %APPDIR%\scripts\install_cli.php admin "Administrador" admin@local %ADMINPASS%
)
:dbskip
echo.

REM ============================================================
REM 6) ARRANCAR SERVICIOS Y VERIFICAR
REM ============================================================
echo [6/6] Arrancando servicios...
if defined XBEE (
    if exist "%XBEE%\xampp_start.exe" start "" "%XBEE%\xampp_start.exe"
    if exist "%XBEE%\apache_start.bat" start "" "%XBEE%\apache_start.bat"
    if exist "%XBEE%\mysql_start.bat" start "" "%XBEE%\mysql_start.bat"
) else (
    net start wampapache64 >nul 2>&1
    net start wampmysqld64 >nul 2>&1
    net start wampmariadb64 >nul 2>&1
)
timeout /t 5 /nobreak >nul
echo.
echo ============================================================
echo   INSTALACION COMPLETADA
echo ============================================================
echo.
echo   Abra en su navegador:
echo   http://localhost/InversionesEmanuel
echo.
echo   Si usa XAMPP portable y los servicios no arrancaron,
echo   abra xampp-control.exe y pulse Start en Apache y MySQL.
echo.
if defined ADMINPASS (
echo   Usuario administrador inicial: admin
echo   Contrasena: %ADMINPASS%
echo   (cambiela al entrar desde Mi perfil)
) else (
echo   Usuario administrador: ver salida del paso 5
echo   Si no se creo, ejecute: php scripts\install_cli.php admin Nombre Apellido correo clave12345
)
echo.
pause
endlocal
