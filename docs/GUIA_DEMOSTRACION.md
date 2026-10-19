# Guía de demostración local

Esta guía reproduce la demostración académica de ITCA TIC Inventario con un
emulador Android, FastAPI y PostgreSQL ejecutándose en la misma computadora.
El resultado es un APK debug; no es un despliegue de producción.

## 1. Requisitos

- Git.
- Docker Engine con Docker Compose v2.
- Flutter 3.47.5 estable y Dart compatible con `^3.13.4`.
- SDK Android y un emulador configurado.
- Java 17 o una versión aceptada por el SDK de Flutter instalado.
- Acceso a Internet si se demostrará Gemini.
- Una clave propia de Gemini almacenada solo en el backend.

Verificar las herramientas sin modificar el proyecto:

```bash
git --version
docker --version
docker compose version
flutter --version
flutter doctor -v
```

## 2. Clonar el repositorio

```bash
git clone https://github.com/hjnarvaez/itca-tic-inventario.git
cd itca-tic-inventario
```

Para una evidencia reproducible, registrar antes de comenzar:

```bash
git rev-parse --short HEAD
git status --short
```

La evidencia final debe señalar el commit realmente evaluado. No se deben usar
resultados de otro commit como si correspondieran al actual.

## 3. Configurar el backend

Crear el archivo local a partir de la plantilla:

```bash
cp backend/.env.example backend/.env
```

Editar `backend/.env` localmente. No copiar su contenido a capturas, documentos,
issues ni commits.

| Variable | Uso en la demostración |
|---|---|
| `SECRET_KEY` | Secreto aleatorio propio para firmar JWT. Obligatorio. |
| `POSTGRES_USER` | Usar `inventario` para mantener coherencia con el Compose de desarrollo. |
| `POSTGRES_PASSWORD` | Contraseña local propia. Obligatoria. |
| `POSTGRES_DB` | Usar `inventario` para el Compose de desarrollo. |
| `DATABASE_URL` | Compose la sustituye internamente por la conexión al servicio `db`. |
| `TEST_DATABASE_URL` | Dejar sin usar durante la demostración. Solo sirve para una base de pruebas aislada. |
| `GEMINI_API_KEY` | Clave propia; necesaria solo para demostrar el asistente. |
| `GEMINI_MODEL` | Modelo habilitado para la clave utilizada. |
| `SEED_USER_EMAIL` | Correo ficticio del usuario que recibirá los 20 equipos. |
| `MCP_DEMO_EMAIL` y `MCP_DEMO_PASSWORD` | Opcionales; no son necesarios para Flutter ni para FastAPI REST. |

No reutilizar credenciales institucionales o de producción. El correo de la
demostración también debe ser ficticio.

## 4. Iniciar PostgreSQL y FastAPI

Desde `backend/`:

```bash
cd backend
docker compose -p itca-inventario up -d --build
docker compose -p itca-inventario ps
```

El archivo utilizado es `backend/docker-compose.yml`. El flujo esperado es:

1. `db` inicia PostgreSQL 16 y supera su comprobación de salud.
2. `migrate` ejecuta `alembic upgrade head` y termina correctamente.
3. `backend` inicia Uvicorn y expone FastAPI en `127.0.0.1:8001`.

Verificar:

```bash
curl --fail http://127.0.0.1:8001/health
docker compose -p itca-inventario ps
```

Abrir Swagger UI:

```text
http://127.0.0.1:8001/docs
```

No es necesario exponer PostgreSQL al anfitrión para ejecutar la aplicación.

## 5. Crear el usuario demostrativo

1. Abrir Swagger UI.
2. Ejecutar `POST /usuarios/`.
3. Introducir el mismo correo ficticio configurado en `SEED_USER_EMAIL`.
4. Elegir una contraseña local de al menos ocho caracteres.
5. Guardar la contraseña fuera del repositorio y no incluirla en capturas.
6. Confirmar una respuesta HTTP 201.
7. Ejecutar `POST /usuarios/token` para confirmar el acceso.

No fotografiar ni copiar el `access_token`. Para las capturas de Swagger,
cerrar la respuesta del login o cubrir completamente el token.

## 6. Cargar los 20 equipos

El script de carga usa `SEED_USER_EMAIL`, busca ese usuario y agrega los equipos
que todavía no existan para él. No crea usuarios ni necesita conocer la
contraseña.

```bash
docker compose -p itca-inventario exec backend \
  uv run --no-sync python -m app.scripts.cargar_equipos
```

La salida debe revisarse, no suponerse. En una base nueva se espera que informe
20 equipos nuevos y 20 equipos totales. Si se repite la ejecución, los códigos
existentes se omiten.

Confirmar los datos iniciando sesión en Swagger y ejecutando `GET /equipos/`, o
desde Flutter después de completar los pasos siguientes.

## 7. Preparar el emulador Android

Desde `frontend/`:

```bash
cd ../frontend
flutter pub get --enforce-lockfile
flutter emulators
flutter devices
```

Si el emulador aún no está iniciado:

```bash
flutter emulators --launch <ID_DEL_EMULADOR>
```

Esperar hasta que aparezca en `flutter devices`.

## 8. Conexión con FastAPI

La configuración debug usa por defecto:

```text
http://10.0.2.2:8001
```

`10.0.2.2` es el alias con el que el emulador Android accede a la interfaz
local de la computadora anfitriona. No reemplazarlo por `127.0.0.1` dentro del
emulador, porque esa dirección representaría al propio dispositivo virtual.

Ejecutar la aplicación:

```bash
flutter run -d <ID_DEL_EMULADOR>
```

También puede declararse la misma dirección de forma explícita:

```bash
flutter run -d <ID_DEL_EMULADOR> \
  --dart-define=API_BASE_URL=http://10.0.2.2:8001
```

HTTP solo está permitido en debug. Profile y release requieren HTTPS.

## 9. Compilar e instalar el APK debug

Compilar:

```bash
flutter build apk --debug
```

Artefacto esperado:

```text
frontend/build/app/outputs/flutter-apk/app-debug.apk
```

Instalarlo en el emulador conectado:

```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Si hay varios dispositivos, seleccionar uno:

```bash
adb -s <ID_DEL_EMULADOR> install -r \
  build/app/outputs/flutter-apk/app-debug.apk
```

Registrar el resultado real de compilación e instalación en
`docs/EVIDENCIAS_RUBRICA.md`. No entregar un `app-release.apk` antiguo que
pudiera existir localmente dentro de `build/`.

## 10. Guion de prueba manual

### Autenticación

- Iniciar sesión con el usuario ficticio.
- Cerrar y volver a abrir la aplicación para comprobar la restauración de
  sesión.
- Cerrar sesión desde la barra superior.
- Comprobar por separado que credenciales incorrectas producen un mensaje
  controlado.

### Inventario y CRUD

- Confirmar que aparecen los 20 equipos de demostración.
- Crear un equipo ficticio con un código no utilizado.
- Editar ese equipo.
- Eliminarlo y confirmar la eliminación.
- Actualizar la lista y verificar que los datos coinciden con el backend.

### Búsqueda y filtros

- Buscar por código, nombre y ubicación.
- Repetir una búsqueda cambiando mayúsculas o tildes.
- Combinar texto, estado, categoría y favoritos.
- Verificar el contador de resultados.
- Producir deliberadamente cero coincidencias.
- Usar **Limpiar filtros** y comprobar el restablecimiento completo.

### Favoritos

- Marcar un equipo como favorito.
- Activar el filtro de favoritos.
- Cerrar y volver a abrir la aplicación.
- Confirmar que el favorito continúa asociado al mismo usuario.

### Dashboard

- Abrir el dashboard.
- Comparar el total con el inventario visible sin filtros.
- Revisar los conteos por estado y las distribuciones por categoría y
  ubicación.
- Actualizar las estadísticas desde el backend.

### Gemini

- Abrir el asistente.
- Formular una pregunta que pueda responderse con los equipos del usuario.
- Confirmar que la respuesta se limita al inventario disponible.
- No escribir datos personales, secretos o instrucciones sensibles.

## 11. Pruebas automatizadas

Flutter no necesita una base real para su suite:

```bash
flutter analyze
flutter test --coverage
```

Las pruebas backend sí recrean tablas. Solo deben ejecutarse con una instancia
PostgreSQL desechable y una `TEST_DATABASE_URL` diferente de `DATABASE_URL`, con
nombre terminado en `_test`:

```bash
cd ../backend
uv lock --check
uv sync --frozen
uv run ruff check .
uv run pytest \
  --cov=app \
  --cov-report=term-missing \
  --cov-report=xml:coverage.xml \
  --cov-fail-under=80
```

El procedimiento completamente aislado está implementado en el job `backend`
de `.github/workflows/ci.yml`, que usa PostgreSQL 16 efímero. No apuntar estas
pruebas a la base `inventario`.

## 12. Solución de problemas

### FastAPI no inicia

- Revisar `docker compose -p itca-inventario ps`.
- Verificar que `POSTGRES_PASSWORD` y `SECRET_KEY` tengan valores locales.
- Revisar los logs sin copiarlos si contienen correos u otros datos:

  ```bash
  docker compose -p itca-inventario logs backend migrate db
  ```

### Flutter indica que no puede conectarse

- Confirmar que `http://127.0.0.1:8001/health` responde en el anfitrión.
- Confirmar que la aplicación es debug.
- Usar `10.0.2.2`, no `localhost`, desde el emulador Android.
- Comprobar que otro proceso no ocupa el puerto 8001.

### El script no encuentra al usuario

- Confirmar que `SEED_USER_EMAIL` coincide exactamente con el correo registrado.
- Recrear el contenedor `backend` solo si el archivo `.env` cambió después de
  levantar Compose y siguiendo el procedimiento aprobado para el entorno local.

### Gemini devuelve un error 503

- Verificar localmente que `GEMINI_API_KEY` esté configurada, sin imprimirla.
- Confirmar acceso a Internet.
- Confirmar que `GEMINI_MODEL` esté disponible para la clave utilizada.
- El resto del inventario debe seguir funcionando aunque Gemini no esté
  disponible.

### La compilación release falla por firma

Es el comportamiento esperado si no existe una firma release completa. Esta
entrega utiliza `flutter build apk --debug`; no se debe sustituir por release.

### Pytest rechaza la base

La protección es intencional. `TEST_DATABASE_URL` debe ser distinta de
`DATABASE_URL` y terminar en `_test`. No se debe desactivar esa comprobación.

## 13. Cierre de la demostración

Desde la raíz del repositorio, para detener los servicios sin borrar datos:

```bash
cd backend
docker compose -p itca-inventario stop
```

No usar opciones que eliminen volúmenes si se desea conservar la base local.
