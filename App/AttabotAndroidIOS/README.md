# Atta-Bot Educativo
El proyecto Attabot Educativo es un proyecto de código abierto que busca fomentar la educación en la programación y robótica en niños y jóvenes de una manera divertida y sencilla.

**Dentro de este proyecto se encuentra el código fuente de la aplicación móvil que se conecta con el robot Attabot**

## Requisitos
- Android Studio
- Dispositivo Android con versión 5.0 o superior
- Flutter SDK
- (Opcional) Extensiones de VSCode para Flutter y Dart

## Instalación
1. Clonar el repositorio
```bash
git clone
```

2. Abrir el proyecto en VSCode 
```bash
cd Atta-Bot-STEM/App/AttabotAndroidIOS
code .
```

3. Ejecutar el proyecto
```bash
flutter run
```

## Estructura del proyecto
El proyecto utiliza una estructura basada en Screaming Architecture y componentes, la cual se divide en tres capas principales:

- **Features**: Contiene las funcionalidades de la aplicación, cada funcionalidad se divide en componentes, enums, models y services.
```
    - feature1
        - components
        - enums
        - models
        - services
    - feature2
        - components
        - enums
        - models
        - services
```

- **Pages**: Contiene las páginas de la aplicación, cada página se divide en un archivo para la página y un archivo para cada componente de la página. Dentro de cada pagina se importan las funcionalidades necesarias.
```
    - page1
        - home.dart
        - page1.dart
        - page2.dart
```

- **Shared**: Contiene los componentesm servicios e interfaces compartidos entre diferentes funcionalidades, como botones, inputs, etc.

```
    - components
        - button.dart
        - input.dart
    - interfaces
        - bluetoothServiceInterface.dart
    - features
        - components
        - enums
        - models
        - services


```

## Contribuir
Para continuar contribuyendo al proyecto es necesario que el codigo este escrito en **INGLES** y seguir los siguientes pasos:

1. Crear una rama con el nombre de la nueva funcionalidad
```bash
git checkout -b feature/nombre-de-la-funcionalidad
```

2. Realizar los cambios necesarios

3. Hacer commit de los cambios con un mensaje descriptivo en ingles utilizando [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.4/)
```bash
git add .
git commit -m "feat: nueva funcionalidad" 
```

## Documentacion de referencia
Ya que el tiempo para documentar adecuadamente el proyecto fue limitado se recomienda revisar en profundidad la siguiente documentacion de referencia:

- [Flutter](https://flutter.dev/docs)
- [Dart](https://dart.dev/guides)
- [Provider](https://pub.dev/documentation/provider/latest/)
- [Flutter Blue Plus](https://pub.dev/documentation/flutter_blue_plus/latest/)

> **Nota:** Es posible que la documentacion de alguna de las dependencias no coincida con la version utilizada en este proyecto, para ello se recomienda revisar la documentacion de la version especifica en el archivo `pubspec.yaml`


