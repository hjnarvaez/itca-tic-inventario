# Frontend Flutter

Aplicación Android de ITCA TIC Inventario. La documentación principal, la
configuración del backend y las advertencias de seguridad están en el
[README del repositorio](../README.md).

## Desarrollo local

```bash
flutter pub get --enforce-lockfile
flutter analyze
flutter test --coverage
flutter run -d <ID_DEL_EMULADOR>
```

En debug, el valor predeterminado de `API_BASE_URL` es
`http://10.0.2.2:8001`, correspondiente al backend local visto desde el
emulador Android.

## APK de demostración

```bash
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Este APK es exclusivamente de demostración. No debe presentarse como release de
producción. Profile y release exigen una URL HTTPS explícita; release también
requiere una firma privada local no incluida en Git.

Consultar la [guía de demostración](../docs/GUIA_DEMOSTRACION.md) para preparar
Docker, PostgreSQL, FastAPI, el usuario ficticio y los 20 equipos.
