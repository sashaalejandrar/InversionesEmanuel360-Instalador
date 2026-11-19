# InversionesEmanuel360 - Instalador y Descargas

Instalador local para **Inversiones Emanuel 360** (ReySystem).

## Uso

### Windows
1. Descargue  (o clone este repo).
2. Doble clic en .
3. El instalador:
   - Detecta Windows y arquitectura.
   - Busca XAMPP () o WAMP (); si no existe, descarga e instala **XAMPP portable** automaticamente.
   - Descarga el sistema desde el release mas reciente de este repo.
   - Detecta si MySQL pide clave y la solicita.
   - Crea la base de datos, importa la estructura y crea el usuario **admin** con clave aleatoria.
   - Arranca Apache y MySQL.

### Linux

Mismo flujo: detecta Linux, busca/instala LAMPP, descarga el sistema, crea la BD y el admin.

## Resultado
- Sistema en 
- Usuario:  + clave aleatoria (se muestra al final de la instalacion)

## Notas
- Si el repo del sistema es privado, el instalador usa el ZIP publicado en **Releases** de este repo (incluye  completo, no requiere Composer).
- WAMP: si MySQL tiene clave de root, el instalador la solicita.
