# Evidencias de la rúbrica

Esta matriz organiza la entrega de ITCA TIC Inventario conforme a los nueve
criterios proporcionados para la Certificación en Inteligencia Artificial.

## 1. Control de la evidencia

| Campo | Valor |
|---|---|
| Proyecto | ITCA TIC Inventario |
| Repositorio | <https://github.com/hjnarvaez/itca-tic-inventario> |
| Rama de preparación | `audit/revision-final` |
| Commit inspeccionado al redactar | `d9982c5` |
| Fecha de preparación | 2026-10-19 |
| Modalidad | APK debug en emulador + FastAPI/PostgreSQL locales |
| Commit final evaluado | **Pendiente** |
| URL del workflow final | **Pendiente** |

Los resultados se considerarán definitivos solo cuando la evidencia incluya
el commit exacto, la fecha, el comando y su salida. Una captura sin esos datos
es evidencia complementaria, no sustituye el resultado automatizado.

## 2. Antecedentes no definitivos

Se han reportado previamente:

- 205 pruebas backend aprobadas y cobertura de 95,33 %.
- 69 pruebas Flutter aprobadas antes de la corrección Android.
- 80 pruebas Flutter aprobadas durante la validación local de seguridad Android.
- Jobs backend y Flutter aprobados en el Pull Request 1.

Estos datos son antecedentes. No se incluyen como resultado final porque esta
matriz todavía no contiene los logs o enlaces de ejecución asociados al commit
que finalmente se entregará.

## 3. Matriz de los nueve criterios

| # | Criterio | Peso | Evidencia de implementación | Pruebas relacionadas | Evidencia final requerida | Estado documental |
|---:|---|---:|---|---|---|---|
| 1 | Persistencia remota o colaborativa | 20 % | [`backend/docker-compose.yml`](../backend/docker-compose.yml), [`app/models/equipo.py`](../backend/app/models/equipo.py), [`app/repositories/equipos.py`](../backend/app/repositories/equipos.py) | [`test_equipos_inventario.py`](../backend/tests/test_equipos_inventario.py) y suite de integración PostgreSQL | Compose saludable, CRUD desde Android y persistencia después de actualizar | Pendiente de captura final |
| 2 | Autenticación | 15 % | [`app/security.py`](../backend/app/security.py), [`app/dependencies.py`](../backend/app/dependencies.py), [`auth_service.dart`](../frontend/lib/services/auth_service.dart) | [`test_api_usuarios.py`](../backend/tests/test_api_usuarios.py), [`test_credencial_uid.py`](../backend/tests/test_credencial_uid.py), [`auth_service_test.dart`](../frontend/test/auth_service_test.dart) | Login, acceso autenticado, rechazo 401 y aislamiento entre dos usuarios ficticios | Pendiente de captura final |
| 3 | Datos reales o conjunto demostrativo suficiente | 15 % | [`app/scripts/cargar_equipos.py`](../backend/app/scripts/cargar_equipos.py) contiene 20 equipos ficticios y los asocia al usuario seleccionado | Validaciones del inventario y CRUD | Salida del script y pantalla con los 20 equipos, sin datos personales | Pendiente de ejecución final |
| 4 | Persistencia local | 10 % | [`favoritos_service.dart`](../frontend/lib/services/favoritos_service.dart) usa Hive por ID de usuario | [`favoritos_service_test.dart`](../frontend/test/favoritos_service_test.dart) y [`favoritos_controller_test.dart`](../frontend/test/favoritos_controller_test.dart) | Favorito visible antes y después de reiniciar la aplicación | Pendiente de captura final |
| 5 | Gestión de estado con GetX | 10 % | [`auth_controller.dart`](../frontend/lib/controllers/auth_controller.dart), [`equipos_controller.dart`](../frontend/lib/controllers/equipos_controller.dart), [`ia_controller.dart`](../frontend/lib/controllers/ia_controller.dart) | Pruebas de controladores, filtros y widgets | Pantallas reaccionando a carga, filtros, actualización y errores | Pendiente de captura final |
| 6 | Integración de IA sin exposición de secretos | 10 % | [`asistente_ia.py`](../backend/app/services/asistente_ia.py), [`routers/ia.py`](../backend/app/routers/ia.py), [`ia_service.dart`](../frontend/lib/services/ia_service.dart) | [`test_ia_inventario.py`](../backend/tests/test_ia_inventario.py), [`ia_service_test.dart`](../frontend/test/ia_service_test.dart), [`ia_controller_test.dart`](../frontend/test/ia_controller_test.dart) | Respuesta desde Flutter, error controlado y verificación de que la clave no está en Git/APK | Pendiente de captura y escaneo final |
| 7 | Manejo de errores y estados de interfaz | 10 % | [`home_screen.dart`](../frontend/lib/screens/home_screen.dart), [`dashboard_screen.dart`](../frontend/lib/screens/dashboard_screen.dart), controladores y manejador general de FastAPI | [`home_filtros_test.dart`](../frontend/test/home_filtros_test.dart), [`dashboard_contenido_test.dart`](../frontend/test/dashboard_contenido_test.dart), pruebas de errores HTTP | Inventario vacío, favoritos vacíos, cero coincidencias, sesión expirada y reintento | Pendiente de capturas seleccionadas |
| 8 | Arquitectura y organización del código | 5 % | Separación Flutter en modelos/controladores/repositorios/servicios/pantallas y backend en routers/servicios/repositorios/modelos | Ruff, `flutter analyze` y suites automatizadas | Diagrama revisado y salidas limpias de análisis | Documento creado; resultados pendientes |
| 9 | Documentación y entrega | 5 % | [`README.md`](../README.md), [`GUIA_DEMOSTRACION.md`](GUIA_DEMOSTRACION.md), [`ARQUITECTURA_Y_SEGURIDAD.md`](ARQUITECTURA_Y_SEGURIDAD.md), workflows y lockfiles | Validación de enlaces, comandos, CI y APK debug | Clonación limpia, CI verde, APK instalado y documentos incluidos en el commit final | Pendiente de validación final |

## 4. Registro de pruebas finales

Completar esta tabla sin borrar el comando ni ocultar fallos. Si un resultado no
se ejecutó, debe permanecer como **Pendiente**.

| Validación | Comando o fuente | Commit | Fecha | Resultado |
|---|---|---|---|---|
| Lockfile backend | `uv lock --check` | Pendiente | Pendiente | Pendiente |
| Ruff | `uv run ruff check .` | Pendiente | Pendiente | Pendiente |
| Backend completo | `uv run pytest --cov=app --cov-report=term-missing --cov-report=xml:coverage.xml --cov-fail-under=80` | Pendiente | Pendiente | Pendiente |
| Docker backend | `docker build --tag itca-tic-inventario-backend:evidence .` desde `backend/` | Pendiente | Pendiente | Pendiente |
| Lockfile Flutter | `flutter pub get --enforce-lockfile` y comprobación de que `pubspec.lock` no cambia | Pendiente | Pendiente | Pendiente |
| Análisis Flutter | `flutter analyze` | Pendiente | Pendiente | Pendiente |
| Pruebas Flutter | `flutter test --coverage` | Pendiente | Pendiente | Pendiente |
| APK debug | `flutter build apk --debug` | Pendiente | Pendiente | Pendiente |
| Instalación | `adb install -r build/app/outputs/flutter-apk/app-debug.apk` | Pendiente | Pendiente | Pendiente |
| CI | Jobs `Backend FastAPI` y `Frontend Flutter` | Pendiente | Pendiente | Pendiente |

La prueba backend debe utilizar PostgreSQL efímero. La protección de
`tests/conftest.py` exige que `TEST_DATABASE_URL` sea distinta de
`DATABASE_URL` y que la base termine en `_test`.

## 5. Evidencias visuales por recopilar

| ID | Evidencia | Criterios | Estado |
|---|---|---|---|
| EV-01 | Commit final y estado limpio del repositorio | 9 | Pendiente |
| EV-02 | GitHub Actions: ambos jobs aprobados para el commit final | 8, 9 | Pendiente |
| EV-03 | `docker compose ps` con PostgreSQL y backend saludables | 1, 9 | Pendiente |
| EV-04 | `/health` y Swagger del backend | 1, 8 | Pendiente |
| EV-05 | Login Android sin contraseña ni JWT visibles | 2, 7 | Pendiente |
| EV-06 | Inventario con los 20 equipos demostrativos | 1, 3 | Pendiente |
| EV-07 | Creación y edición de un equipo ficticio | 1, 7 | Pendiente |
| EV-08 | Confirmación de eliminación | 1, 7 | Pendiente |
| EV-09 | Búsqueda y filtros combinados con contador | 5, 7 | Pendiente |
| EV-10 | Mensaje de búsqueda sin coincidencias | 7 | Pendiente |
| EV-11 | Favorito persistente tras reiniciar | 4, 5 | Pendiente |
| EV-12 | Dashboard con totales y distribuciones | 3, 5 | Pendiente |
| EV-13 | Consulta de Gemini desde Flutter | 6 | Pendiente |
| EV-14 | Rechazo HTTP 401 sin mostrar el token | 2, 7 | Pendiente |
| EV-15 | Dos usuarios ficticios con inventarios aislados | 1, 2 | Pendiente |
| EV-16 | Ruff, pytest y cobertura backend | 1, 2, 6, 8 | Pendiente |
| EV-17 | `flutter analyze` y pruebas Flutter | 4, 5, 7, 8 | Pendiente |
| EV-18 | Compilación e instalación del APK debug | 9 | Pendiente |

## 6. Evidencia de aislamiento por usuario

Esta verificación requiere dos usuarios ficticios distintos:

1. Crear un equipo con el usuario A.
2. Confirmar que el usuario A puede consultarlo.
3. Iniciar sesión con el usuario B.
4. Confirmar que el equipo del usuario A no aparece.
5. Intentar consultar el ID desde B y registrar la respuesta sin mostrar JWT.

No reutilizar correos personales. Las capturas deben permitir distinguir A y B
mediante alias ficticios, pero no deben mostrar contraseñas o tokens.

## 7. Evidencia de secretos ausentes

Antes de entregar se debe comprobar y registrar, mostrando solo el resultado:

- Ningún `.env` está rastreado.
- No hay `key.properties`, keystores o claves privadas rastreados.
- El APK no contiene una clave de Gemini ni un JWT real.
- Las capturas no muestran valores de `Authorization`, contraseñas o claves.
- La URL de Gemini y el nombre de la variable pueden documentarse; su valor
  secreto no.

Si una comprobación encuentra un secreto, no tomar una captura: revocar la
credencial, retirarla del artefacto y repetir la validación.

## 8. Criterio de entrega del APK

El archivo que se evaluará es `app-debug.apk`. La evidencia y cualquier texto
de entrega deben incluir esta declaración:

> APK debug para demostración académica en emulador Android, conectado a
> FastAPI y PostgreSQL locales mediante `10.0.2.2:8001`. No es una versión
> release de producción.

No adjuntar ni enlazar un `app-release.apk` local antiguo.

## 9. SDD y Spec-Kit

Durante la inspección de `d9982c5` no se localizaron `.specify/`, `specs/`,
`spec.md`, `plan.md`, `tasks.md` ni una constitución Spec-Kit.

La rúbrica de nueve criterios proporcionada no establece por sí sola que esos
artefactos sean obligatorios. Este punto permanece **No verificable** hasta
revisar la consigna oficial de Moodle. No deben generarse documentos
retroactivos presentándolos como evidencia histórica.

## 10. Cierre pendiente

Antes de declarar la entrega completa:

1. Ejecutar todas las pruebas sobre el commit final.
2. Guardar los resultados sin secretos.
3. Completar las tablas de este documento.
4. Incorporar las capturas siguiendo `docs/evidencias/README.md`.
5. Verificar enlaces desde un clon limpio.
6. Confirmar el formato exacto exigido por Moodle.
7. Confirmar que solo se adjunta el APK debug acordado.
