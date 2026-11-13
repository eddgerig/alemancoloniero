# Alemán Coloniero - Flutter App

Aplicación móvil para la enseñanza del dialecto Alemán Coloniero, integrada con Firebase Authentication y backend Django REST Framework.

## Configuración y Ejecución

### 1. Firebase Authentication (FlutterFire)
La aplicación utiliza `firebase_core` y `firebase_auth` configurados mediante la CLI de FlutterFire.
Las credenciales del proyecto `aleman-coloniero` se encuentran en [`lib/firebase_options.dart`](lib/firebase_options.dart) e inicializadas en [`lib/main.dart`](lib/main.dart) mediante `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.

Si requieres reconfigurar el proyecto de Firebase en cualquier momento:
```bash
flutterfire configure --project=aleman-coloniero
```

### 2. Ejecutar la Aplicación con la URL del Backend
La URL base del backend Django REST se lee dinámicamente mediante `String.fromEnvironment('API_URL')` en [`lib/services/api_service.dart`](lib/services/api_service.dart).

#### Servidor Remoto de Desarrollo (por defecto `http://77.112.240.202/api`):
```bash
flutter run
```

#### Especificar URL del Backend mediante `--dart-define`:
```bash
# Servidor remoto activo
flutter run --dart-define=API_URL=http://77.112.240.202/api

# Servidor local en emulador
flutter run --dart-define=API_URL=http://10.0.2.2:8000/api
```

#### Compilación para Producción (HTTPS):
```bash
flutter build apk --dart-define=API_URL=https://tu-servidor-produccion.com/api
```
