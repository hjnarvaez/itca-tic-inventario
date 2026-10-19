# Convenciones para evidencias

Esta carpeta recibirá las capturas y resultados seleccionados para la entrega.
Actualmente no contiene evidencias visuales: no deben inventarse ni copiarse de
ejecuciones que no correspondan al commit final.

## Nombres de archivo

Usar el identificador definido en `../EVIDENCIAS_RUBRICA.md`, seguido de una
descripción breve:

```text
EV-01-commit-final.png
EV-02-github-actions.png
EV-06-inventario-20-equipos.png
EV-13-asistente-gemini.png
EV-16-pruebas-backend.txt
EV-17-pruebas-flutter.txt
```

Preferir PNG para capturas y texto UTF-8 para salidas de comandos. No guardar
videos o binarios grandes dentro del repositorio salvo que la consigna de
entrega lo exija expresamente.

## Metadatos requeridos

Cada evidencia debe quedar relacionada en `EVIDENCIAS_RUBRICA.md` con:

- Identificador EV.
- Fecha y zona horaria.
- Commit corto y rama.
- Entorno utilizado.
- Comando o secuencia que produjo el resultado.
- Resultado observado.
- Criterios de la rúbrica que respalda.

Las capturas de interfaz pueden acompañarse con una descripción breve cuando el
commit no resulte visible en la imagen.

## Información prohibida

No incorporar, aunque sea parcialmente visible:

- Contenido de archivos `.env`.
- Contraseñas de usuarios o PostgreSQL.
- JWT o encabezados `Authorization`.
- Claves de Gemini.
- `key.properties`, keystores o claves privadas.
- Correos, nombres u otros datos personales reales.
- URLs privadas que incluyan credenciales.

No basta con recortar una imagen si el secreto sigue presente en sus metadatos o
capas. Ante una exposición accidental, no versionar el archivo y revocar la
credencial afectada.

## Preparación segura de capturas

1. Usar usuarios y equipos ficticios.
2. Limpiar la terminal antes de ejecutar el comando que se fotografiará.
3. Evitar `env`, `printenv`, volcados de configuración y modos verbose que
   impriman encabezados.
4. En Swagger, cerrar u ocultar la respuesta de `/usuarios/token`.
5. Mostrar solo estados de contenedores, nombres de servicios y resultados
   necesarios.
6. Revisar visualmente cada archivo antes de añadirlo a Git.

## Resultados automatizados

Para conservar una salida de pruebas se recomienda registrar el comando y el
resumen final. La evidencia debe mostrar los fallos si existen; no editar una
salida para aparentar éxito.

Los reportes generados (`coverage.xml`, `lcov.info`, APK y carpetas `build/`)
están excluidos del repositorio. Si Moodle exige alguno, debe adjuntarse por el
canal de entrega correspondiente y asociarse al checksum y commit documentados,
sin cambiar las reglas de Git solo para incorporarlo.

## Revisión previa a Git

Antes de agregar evidencias:

```bash
git status --short
git diff --check
git check-ignore backend/.env frontend/android/key.properties
```

Revisar manualmente los archivos nuevos. No utilizar comandos que impriman el
contenido de secretos para demostrar que están excluidos.
