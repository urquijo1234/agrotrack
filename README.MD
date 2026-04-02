# AgroTrack

AgroTrack es un proyecto para gestionar actividades agrícolas desde una app Flutter, con autenticación, manejo de predios/lotes y registro de eventos (siembra, insumos y cosecha), incluyendo soporte offline con cola de sincronización.

## Estructura del repositorio

- `mobile_app/`: aplicación principal en Flutter.
- `.github/workflows/ci.yml`: pipeline de CI para análisis, pruebas y build APK debug.

## Requisitos

- Flutter `3.38.7` (canal `stable`)
- Dart SDK `^3.10.7`
- Java 17 (para build Android)

## Configuración local

1. Entrar al proyecto Flutter:
   - `cd mobile_app`
2. Instalar dependencias:
   - `flutter pub get`
3. Ejecutar la app:
   - `flutter run`

## Comandos útiles

Desde `mobile_app/`:

- Análisis estático: `flutter analyze`
- Pruebas: `flutter test`
- Build APK debug: `flutter build apk --debug`

## CI

El flujo de GitHub Actions (`AgroTrack CI`) ejecuta:

1. `flutter clean`
2. `flutter pub get`
3. `flutter analyze`
4. `flutter test`
5. `flutter build apk --debug`

Además, en `main` genera un release automático con el APK debug como artefacto.

## Módulos funcionales actuales

- **Auth**: login, registro y puerta de autenticación.
- **Predios**: crear, listar, editar y ver detalle.
- **Lotes**: crear, editar y consultar detalle.
- **Eventos agrícolas**: registrar siembra, insumos y cosecha; historial por lote.
- **Dashboard**: resumen general del productor.
- **Sync offline**: cola para sincronizar eventos pendientes.

