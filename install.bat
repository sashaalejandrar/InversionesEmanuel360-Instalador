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
    set MYSQLD=%XBEE%\mysql\bin\mysqld.exe
    set MYSQLINI=%XBEE%\mysql\bin\my.ini
    set PHPBIN=%XBEE%\php\php.exe
    set APACHECTL=%XBEE%\apache\bin\httpd.exe
) else if defined WAMP (
    echo   WAMP encontrado en: %WAMP%
    set HTDOCS=%WAMP%\www
    for /d %%D in ("%WAMP%\bin\mysql\mysql*") do if not defined MYSQL set MYSQL=%%D\bin\mysql.exe
    for /d %%D in ("%WAMP%\bin\mariadb\mariadb*") do if not defined MYSQL set MYSQL=%%D\bin\mysql.exe
    for /d %%D in ("%WAMP%\bin\php\php*") do if not defined PHPBIN set PHPBIN=%%D\php.exe
    if not defined MYSQL set MYSQL=%WAMP%\bin\mysql\mysql8.0.40\bin\mysql.exe
    if not defined PHPBIN set PHPBIN=%WAMP%\bin\php\php8.3.14\php.exe
) else (
    echo   No se encontro XAMPP ni WAMP. Descargando XAMPP portable...
    echo   Esto puede tardar varios minutos segun la conexion.
    echo.
    powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://downloads.sourceforge.net/project/xampp/XAMPP%%20Windows/8.2.12/xampp-portable-win32-8.2.12-0-VS16.zip' -OutFile '%TEMP%\xampp-portable.zip' -UseBasicParsing"
    if errorlevel 1 (
        echo   Reintentando con enlace directo de Apache Friends...
        powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.apachefriends.org/xampp-files/xampp-windows-x64-8.2.12-0-VS16.zip' -OutFile '%TEMP%\xampp-portable.zip' -UseBasicParsing"
    )
    if not exist "%TEMP%\xampp-portable.zip" (
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
    set MYSQLD=%XBEE%\mysql\bin\mysqld.exe
    set MYSQLINI=%XBEE%\mysql\bin\my.ini
    set PHPBIN=%XBEE%\php\php.exe
    set APACHECTL=%XBEE%\apache\bin\httpd.exe
    del "%TEMP%\xampp-portable.zip" >nul 2>&1
    echo   XAMPP portable instalado en C:\xampp
)
echo.

REM ============================================================
REM 3) OBTENER EL SISTEMA (local o desde GitHub Releases)
REM ============================================================
echo [3/6] Obteniendo archivos del sistema...
set APPDIR=%HTDOCS%\InversionesEmanuel
set SRC=%~dp0
if not exist "%~dp0public\index.php" set SRC=

if defined SRC (
    echo   Copiando desde la carpeta del instalador...
    if exist "%APPDIR%" rmdir /s /q "%APPDIR%"
    mkdir "%APPDIR%"
    xcopy "%~dp0*" "%APPDIR%\" /E /I /Q /EXCLUDE:"%~dp0install.exclude" >nul
) else (
    echo   Descargando ultima version desde GitHub Releases...
    powershell -NoProfile -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/sashaalejandrar/InversionesEmanuel360-Instalador/releases/latest/download/InversionesEmanuel360.zip' -OutFile '%TEMP%\ie360.zip' -UseBasicParsing"
    if errorlevel 1 (
        echo   ERROR: No se pudo descargar el sistema.
        echo   Verifique su conexion o descargue el ZIP manualmente.
        pause
        exit /b 1
    )
    powershell -NoProfile -Command "Expand-Archive -Path '%TEMP%\ie360.zip' -DestinationPath '%TEMP%\ie360src' -Force"
    for /d %%D in ("%TEMP%\ie360src\*") do (
        if exist "%%D\public\index.php" set SRCDIR=%%D
    )
    if not defined SRCDIR (
        echo   ERROR: El ZIP descargado no contiene el sistema.
        pause
        exit /b 1
    )
    if exist "%APPDIR%" rmdir /s /q "%APPDIR%"
    xcopy "%SRCDIR%\*" "%APPDIR%\" /E /I /Q >nul
    rmdir /s /q "%TEMP%\ie360src" >nul 2>&1
    del "%TEMP%\ie360.zip" >nul 2>&1
)
echo   Sistema instalado en: %APPDIR%
echo.

REM ============================================================
REM 4) INICIAR MYSQL Y DETECTAR CLAVE
REM ============================================================
echo [4/6] Iniciando MySQL y verificando acceso...
if defined XBEE (
    REM XAMPP portable: arrancar mysqld directo si no responde
    "%MYSQL%" -u root -e "SELECT 1" >nul 2>&1
    if errorlevel 1 (
        echo   Arrancando mysqld de XAMPP...
        start "MySQL" /min "" "%MYSQLD%" --defaults-file="%MYSQLINI%"
        timeout /t 6 /nobreak >nul
    )
) else (
    net start wampapache64 >nul 2>&1
    net start wampmariadb64 >nul 2>&1
    net start wampmysqld64 >nul 2>&1
    timeout /t 3 /nobreak >nul
)

set DBPASS=
"%MYSQL%" -u root -e "SELECT 1" >nul 2>&1
if errorlevel 1 (
    echo   MySQL pide contrasena de root. Ingresela (vacio si no tiene):
    set /p DBPASS=   Clave root de MySQL: 
    if defined DBPASS (
        "%MYSQL%" -u root -p"%DBPASS%" -e "SELECT 1" >nul 2>&1
        if errorlevel 1 (
            echo   ERROR: La clave no funciona. Instale XAMPP portable para evitar esto.
            pause
            exit /b 1
        )
    ) else (
        echo   AVISO: MySQL no responde sin clave ni con la ingresada.
        echo   Si WAMPP/MySQL tiene otra clave, edite .env manualmente.
    )
) else (
    echo   MySQL responde sin clave (XAMPP default).
)
echo.

REM ============================================================
REM 5) CONFIGURAR .ENV + BASE DE DATOS + USUARIO ADMIN
REM ============================================================
echo [5/6] Configurando base de datos...
set APPKEY=
for /f "delims=" %%K in ('powershell -NoProfile -Command "$k=[guid]::NewGuid().ToString(''N'')+[guid]::NewGuid().ToString(''N''); Write-Output $k"') do set APPKEY=%%K
if not defined APPKEY set APPKEY=ie360-local-key
if exist "%APPDIR%\.env" del "%APPDIR%\.env"
(
echo APP_ENV=production
echo APP_DEBUG=false
echo APP_URL=http://localhost/InversionesEmanuel
echo APP_KEY=%APPKEY%
echo DB_HOST=127.0.0.1
echo DB_PORT=3306
echo DB_NAME=inversiones_emanuel
echo DB_USER=root
echo DB_PASS=%DBPASS%
echo MAIL_HOST=localhost
echo MAIL_PORT=25
) > "%APPDIR%\.env"
echo   Archivo .env listo.

set MYSQLROOT="%MYSQL%" -u root
if defined DBPASS set MYSQLROOT="%MYSQL%" -u root -p"%DBPASS%"

%MYSQLROOT% -e "CREATE DATABASE IF NOT EXISTS inversiones_emanuel CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >nul 2>&1
if errorlevel 1 (
    echo   AVISO: no se pudo crear la base de datos (MySQL puede no estar listo).
    echo   Reintente la importacion manualmente mas tarde.
    goto :dbdone
)
for %%F in ("%APPDIR%\database\migrations\*.sql") do (
    echo   Importando %%~nxF ...
    %MYSQLROOT% inversiones_emanuel < "%%F" >nul 2>&1
)
echo   Base de datos lista.

set ADMINPASS=
for /f "delims=" %%P in ('powershell -NoProfile -Command "$p=[guid]::NewGuid().ToString(''N'').Substring(0,12); Write-Output $p"') do set ADMINPASS=%%P
if not defined ADMINPASS set ADMINPASS=Admin2026!

echo   Creando roles, permisos y usuario administrador...
"%PHPBIN%" "%APPDIR%\scripts\install_cli.php" admin "Administrador" "admin@local" "%ADMINPASS%"
if errorlevel 1 (
    echo   AVISO: no se pudo crear el usuario admin automaticamente.
    echo   Ejecute manualmente:
    echo   %PHPBIN% %APPDIR%\scripts\install_cli.php admin Administrador admin@local %ADMINPASS%
)
:dbdone
echo.

REM ============================================================
REM 6) ARRANCAR APACHE Y VERIFICAR
REM ============================================================
echo [6/6] Arrancando Apache...
if defined XBEE (
    start "Apache IE360" /min "" "%APACHECTL%"
) else (
    net start wampapache64 >nul 2>&1
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
if defined XBEE (
echo   Si Apache no arranco, abra xampp-control.exe y pulse Start.
echo   MySQL quedo corriendo en segundo plano.
) else (
echo   Si WAMP no esta corriendo, abrala desde el icono de bandeja.
)
echo.
if defined ADMINPASS (
echo   Usuario administrador: admin
echo   Contrasena: %ADMINPASS%
echo   (cambiela al entrar desde Mi perfil)
) else (
echo   Si el admin no se creo, vea el paso 5 o ejecute install_cli.php.
)
echo.
pause
endlocal
