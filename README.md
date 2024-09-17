# XML Converter

XML Converter es una aplicación Flutter diseñada para convertir archivos XML a formato Excel. Esta herramienta es especialmente útil para procesar comprobantes fiscales digitales (CFDI) en México.

## Características

- Importación de archivos XML
- Conversión de datos XML a formato Excel
- Interfaz de usuario intuitiva
- Soporte para múltiples plataformas (Windows, macOS, Linux)

## Requisitos del sistema

- Flutter SDK
- Dart SDK
- Dependencias especificadas en el archivo `pubspec.yaml`

## Instalación

1. Clona este repositorio:
   ```
   git clone https://github.com/tu-usuario/xml_converter.git
   ```

2. Navega al directorio del proyecto:
   ```
   cd xml_converter
   ```

3. Instala las dependencias:
   ```
   flutter pub get
   ```

## Uso

1. Ejecuta la aplicación:
   ```
   flutter run
   ```

2. En la interfaz de la aplicación, haz clic en "Importar XML" para seleccionar un archivo XML.

3. Una vez importado el archivo, haz clic en "Generar Excel" para convertir los datos a formato Excel.

4. El archivo Excel generado se abrirá automáticamente con la aplicación predeterminada de tu sistema.

## Estructura del proyecto

- `lib/main.dart`: Punto de entrada de la aplicación
- `lib/comprobante_form.dart`: Formulario principal para la importación y conversión
- `lib/func/excel_creator.dart`: Lógica para la creación de archivos Excel
- `lib/func/xml_importer.dart`: Lógica para la importación de archivos XML
- `lib/types/comprobante.dart`: Definición de tipos de datos para los comprobantes

## Contribución

Las contribuciones son bienvenidas. Por favor, abre un issue para discutir los cambios propuestos antes de realizar un pull request.

## Licencia

[Incluye aquí la información de la licencia de tu proyecto]
