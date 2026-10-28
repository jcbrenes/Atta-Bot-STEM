# Guía para instalar Atta-Bot en tabletas Android

Revisión: 22 de septiembre de 2026.

## 1. Qué necesitamos

- Tabletas **Android 7.0 o superior con Bluetooth Low Energy (BLE)** para el APK disponible. Un APK no se instala en iPad.
- El archivo `app-release.apk` y espacio libre para copiarlo e instalarlo; el archivo actual ocupa aproximadamente 52 MiB y la instalación necesita espacio adicional.
- Para instalar por USB: computadora, cable de **datos** y Android SDK Platform-Tools (`adb`).
- Para instalar manualmente: una forma de copiar el APK a cada tableta, como USB o una descarga desde una ubicación del equipo.
- Acceso a los ajustes de la tableta. Si tiene administración escolar, el administrador debe permitir la instalación.
- Un robot Atta-Bot encendido para comprobar la conexión y los controles.

No hace falta instalar Flutter ni Android Studio en las tabletas. Probar primero una tableta de cada modelo antes de distribuir al resto.

## 2. APK disponible y alcance de la revisión

Archivo encontrado en esta computadora, desde la raíz del repositorio:

```text
App/AttabotAndroidIOS/build/app/outputs/flutter-apk/app-release.apk
```

Metadatos leídos directamente con `aapt dump badging`:

| Dato | Valor |
| --- | --- |
| Nombre visible | Atta-Bot App |
| Paquete | `com.example.proyecto_tec` |
| Versión | `1.1.16` |
| Código de versión | `1` |
| Android mínimo del APK | API 24: Android 7.0 |
| Android objetivo del APK | API 36 |
| Arquitecturas incluidas | `armeabi-v7a`, `arm64-v8a`, `x86_64` |
| Fecha de modificación del archivo | 10 de septiembre de 2026 |

**El APK y la configuración fuente difieren:** el archivo `android/app/build.gradle` declara mínimo API 21 y compilación API 35, mientras el APK informa mínimo API 24 y compilación API 36. Para instalar este archivo manda el requisito del APK. No se ha confirmado que corresponda exactamente al código actual ni su funcionamiento con el firmware actual. La fecha del archivo no demuestra cómo se compiló.

## 3. Instalación manual, sin comandos

1. Copiar `app-release.apk` a la carpeta **Descargas** de la tableta.
2. Abrir **Archivos** o el administrador de archivos y tocar el APK.
3. Si Android solicita permiso para esa aplicación, entrar en **Ajustes → Aplicaciones → Acceso especial → Instalar aplicaciones desconocidas** y permitir esa fuente. Los nombres cambian según el fabricante; en Android 7 suele aparecer como **Seguridad → Orígenes desconocidos**.
4. Volver al archivo y tocar **Instalar**. Si ya existe la aplicación, puede aparecer **Actualizar**.
5. Abrir **Atta-Bot App** y realizar la prueba del apartado 5.
6. Al terminar, desactivar el permiso de instalación que se habilitó.

Si una política de administración impide instalar, solicitar la habilitación al administrador. Referencia para la instalación desde otras fuentes: [ayuda de Google](https://support.google.com/pixelphone/answer/7391672).

## 4. Instalación por USB, práctica para varias tabletas

Instalar Platform-Tools en la computadora y hacer que `adb` esté disponible en la terminal. En Windows puede ser necesario el controlador USB del fabricante.

1. En la tableta, habilitar **Opciones de desarrollador** tocando siete veces **Número de compilación**, normalmente dentro de **Acerca de la tableta**.
2. Habilitar **Depuración USB**, conectar el cable y desbloquear la pantalla.
3. Aceptar en la tableta la autorización de depuración de esta computadora.
4. Desde la raíz del repositorio, ejecutar:

```bash
adb devices -l
```

El estado debe ser `device`. Con una sola tableta conectada:

```bash
adb install -r App/AttabotAndroidIOS/build/app/outputs/flutter-apk/app-release.apk
```

Con varias tabletas, sustituir `SERIAL_TABLETA` por el identificador de cada una y repetir:

```bash
adb -s SERIAL_TABLETA install -r App/AttabotAndroidIOS/build/app/outputs/flutter-apk/app-release.apk
```

Esperar `Success`, abrir la aplicación y probarla. `-r` permite reinstalar conservando los datos si la actualización es compatible. La autorización USB es distinta del permiso para instalar desde Archivos. Al terminar, desactivar la depuración USB. Referencia: [Android Debug Bridge](https://developer.android.com/tools/adb).

## 5. Primera apertura y prueba con el robot

1. Activar Bluetooth y encender el robot cerca de la tableta.
2. Aceptar **Dispositivos cercanos/Bluetooth** cuando se solicite. Conceder **Ubicación** mientras se usa la aplicación si la solicita; el código actual utiliza ubicación para el escaneo. Si no aparecen robots, comprobar también que la ubicación del sistema esté encendida. Android cambia estos permisos según versión y SDK objetivo: [permisos Bluetooth](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions).
3. Abrir **Dispositivos Bluetooth** dentro de Atta-Bot y seleccionar el robot. La conexión se inicia desde la aplicación.
4. El código actual filtra nombres por `Atta` y `DM`, y busca durante diez segundos. Si no aparece, revisar el nombre anunciado por el robot y salir y volver a entrar a esa pantalla.
5. En un espacio despejado, comprobar un movimiento corto, detención y un giro; verificar que responde el robot seleccionado.
6. Cerrar y abrir la aplicación, volver a conectar y repetir una orden.
7. Si se usará guardar/importar archivos, probar también esa función. El código solicita permisos de almacenamiento y acceso a todos los archivos; revisar esos permisos si falla esa función.

Instalar correctamente no confirma compatibilidad con el firmware: deben funcionar tanto la conexión BLE como las órdenes.

Registrar cada tableta:

| Identificador/modelo | Android | Versión APK | Abre | Conecta BLE | Movimiento/detención | Observaciones |
| --- | --- | --- | --- | --- | --- | --- |
| | | | | | | |

## 6. Si necesitamos generar un APK nuevo

En la computadora se necesitan Flutter, Android SDK y un JDK compatible con Gradle. La configuración fuente actual utiliza Android Gradle Plugin 8.3.2, Gradle 8.9 y SDK de compilación 35; validar el entorno antes de compilar. No asumir que instalar la versión más reciente de Flutter reproduce el APK existente.

```bash
cd App/AttabotAndroidIOS
flutter doctor -v
flutter pub get
flutter build apk --release
```

La salida esperada es `build/app/outputs/flutter-apk/app-release.apk`, relativa a esa carpeta. Para preparar una actualización, usar un código de versión superior al instalado; por ejemplo, **si el instalado es 1**:

```bash
flutter build apk --release --build-name=1.1.17 --build-number=2
```

Estos son pasos de preparación, no una compilación verificada en esta revisión. Volver a revisar los metadatos del nuevo APK y probarlo antes de distribuirlo. Referencia: [compilar y distribuir Android con Flutter](https://docs.flutter.dev/deployment/android).

## 7. Firma y futuras actualizaciones

El proyecto configura `release` con `signingConfigs.debug`. Para una distribución mantenida, configurar una clave de firma propia y guardar una copia segura fuera del repositorio antes del despliegue general. No se ha inspeccionado el certificado del APK existente.

Las actualizaciones deben conservar el identificador del paquete y una firma compatible. Compilar en otra computadora con otra clave de desarrollo puede impedir actualizar. Si se cambia la firma y hace falta desinstalar, respaldar primero los datos: **desinstalar puede borrar los datos locales**. Referencia: [firma de aplicaciones Android](https://developer.android.com/studio/publish/app-signing).

## 8. Problemas habituales

| Problema | Qué revisar |
| --- | --- |
| `unauthorized` en ADB | Desbloquear la tableta y aceptar la autorización USB. |
| No aparece en ADB | Cable de datos, puerto, depuración USB y controlador/permisos USB de la computadora. |
| Más de un dispositivo | Usar `adb -s SERIAL_TABLETA ...`. |
| `INSTALL_FAILED_OLDER_SDK` | El Android de la tableta es inferior al mínimo del APK; este APK exige Android 7.0. |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Revisar firma y paquete de la versión instalada; no desinstalar sin respaldar. |
| `INSTALL_FAILED_VERSION_DOWNGRADE` | Usar una compilación con código de versión adecuado. |
| Espacio insuficiente | Liberar espacio para el archivo y la aplicación instalada. |
| Instalación bloqueada | Revisar permiso de la fuente y políticas de administración. |
| No encuentra el robot | Revisar BLE, permisos, ubicación, nombre anunciado y que otra tableta no mantenga la conexión. |
| Conecta pero no se mueve | Revisar alimentación, firmware, UUID BLE y compatibilidad de órdenes. |

La distribución queda validada cuando cada tableta abre la aplicación, conecta con su robot y supera la prueba de movimiento y detención.
