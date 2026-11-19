# InversionesEmanuel360 - Instalador y Descargas

Instalador local para **Inversiones Emanuel 360** (ReySystem - Los Reyes de la Tecnologia).

## Uso

### Windows

1. Descargue `install.bat` (o clone este repo).
2. Doble clic en `install.bat`.
3. El instalador:
   - Detecta Windows y la arquitectura (32/64 bits).
   - Busca XAMPP (`C:\xampp`) o WAMP (`C:\wamp64` / `C:\wamp`).
   - Si no existe ninguno, **descarga e instala XAMPP portable** automaticamente (no requiere administrador).
   - Descarga el sistema desde el release mas reciente de este repo.
   - Inicia MySQL y detecta si pide clave de root (WAMP); si es necesario, la solicita.
   - Crea la base de datos `inversiones_emanuel`, importa la estructura y crea el usuario **admin** con clave aleatoria.
   - Arranca Apache y MySQL.

### Linux

```bash
bash install.sh
```

Mismo flujo: detecta Linux, busca LAMPP/XAMPP (lo instala en `/opt/lampp` si falta), descarga el sistema, crea la BD y el usuario admin.

## Resultado

- Sistema en `http://localhost/InversionesEmanuel`
- Usuario: `admin` + clave aleatoria (se muestra al final de la instalacion; cambiela desde **Mi perfil**)

## Notas

- El ZIP del release incluye `vendor/` completo: **no requiere Composer**.
- Si ejecuta el instalador desde dentro de la carpeta del proyecto, copia los archivos locales en vez de descargar.
- MySQL de XAMPP fresco no tiene clave; WAMPP puede pedirla y el instalador la solicita.
