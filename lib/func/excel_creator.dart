import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:xml_converter/styles/cell_styles.dart';
import 'package:xml_converter/types/comprobante.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';


Future<String> createExcel(Comprobante data) async {
  // Crear el archivo Excel
  Excel excel = Excel.createExcel();
  CellStyles cellStyles = CellStyles();
  Sheet sheetObject = excel['Sheet1'];

  // Título del documento
  sheetObject.merge(
    CellIndex.indexByString('B2'),
    CellIndex.indexByString('S4'),
    customValue: TextCellValue('Registro de Comprobantes'),
  );
  sheetObject.cell(CellIndex.indexByString('B2')).cellStyle =
      cellStyles.cellStyleTitle;

  // Encabezados de las columnas
  const headers = [
    '',
    'FECHA',
    'SERIE',
    'FOLIO',
    'UUID',
    'RFC EMISOR',
    'NOMBRE EMISOR',
    'RFC RECEPTOR',
    'NOMBRE RECEPTOR',
    'MONEDA',
    'CONCEPTO',
    'SUBTOTAL',
    'DESCUENTO',
    'TASA',
    'TOTAL IVA TRASLADADO',
    'TOTAL IEPS TRASLADADO',
    'TOTAL ISR RETENIDO',
    'TOTAL IVA RETENIDO',
    'TOTAL',
  ];

  sheetObject.cell(CellIndex.indexByString('B5'));
  sheetObject.appendRow(headers.map((header) => TextCellValue(header)).toList());

  // Aplicar estilo a los encabezados
  for (var i = 1; i <= headers.length; i++) {
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 5))
        .cellStyle = cellStyles.cellStyleHeader;
  }

  // Añadir los datos del comprobante
 sheetObject.appendRow([
    TextCellValue(''),
    TextCellValue(DateFormat('yyyy-MM-dd').format(data.fecha)),
    TextCellValue(data.serie),
    TextCellValue(data.folio),
    TextCellValue(data.uuid),
    TextCellValue(data.rfcEmisor),
    TextCellValue(data.nombreEmisor),
    TextCellValue(data.rfcReceptor),
    TextCellValue(data.nombreReceptor),
    TextCellValue(data.moneda),
  ]);

  // Index para marcar inicio de agregado de datos
  sheetObject.cell(CellIndex.indexByString('K7'));
  
  // Variables para almacenar los totales
  double totalIVATrasladado = 0.0;
  double totalISRRetenido = 0.0;
  double totalIVARetenido = 0.0;
  double totalIEPSTrasladado = 0.0;

  // Añadir los datos de los conceptos
  for (var concepto in data.conceptos) {
    final impuestos = concepto.impuestos;

    // Procesar traslados
    for (var traslado in impuestos.traslado) {
      double tasa = traslado.tasaOCuota;
      double importe = traslado.importe;
      switch (traslado.impuesto) {
        case '002': // IVA Trasladado
          totalIVATrasladado += importe;
          sheetObject.appendRow([
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            const DoubleCellValue(0.0),
            const DoubleCellValue(0.0),
            DoubleCellValue(tasa),
            DoubleCellValue(importe),
            const DoubleCellValue(0.0),
            const DoubleCellValue(0.0),
            const DoubleCellValue(0.0),
            const DoubleCellValue(0.0),
          ]);
          break;
        case '003': // IEPS Trasladado
          totalIEPSTrasladado += importe;
          sheetObject.appendRow([
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            const DoubleCellValue(0.0),
            const DoubleCellValue(0.0),
            DoubleCellValue(tasa),
            const DoubleCellValue(0.0),
            DoubleCellValue(importe),
            const DoubleCellValue(0.0),
            const DoubleCellValue(0.0),
            const DoubleCellValue(0.0),
          ]);
          break;
      }
    }

    // Procesar retenciones
    for (var retencion in impuestos.retencion) {
      double tasa = retencion.tasaOCuota;
      double importe = retencion.importe;
      switch (retencion.impuesto) {
        case '001': // ISR Retenido
          totalISRRetenido += importe;
          sheetObject.appendRow([
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            const DoubleCellValue(0.0),
            const DoubleCellValue(0.0),
            DoubleCellValue(tasa),
            const DoubleCellValue(0.0),
            const DoubleCellValue(0.0),
            DoubleCellValue(importe),
            const DoubleCellValue(0.0),
            const DoubleCellValue(0.0),
          ]);
          break;
        case '002': // IVA Retenido
          totalIVARetenido += importe;
          sheetObject.appendRow([
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            TextCellValue(''),
            const DoubleCellValue(0.0),
            const DoubleCellValue(0.0),
            DoubleCellValue(tasa),
            const DoubleCellValue(0.0),
            const DoubleCellValue(0.0),
            const DoubleCellValue(0.0),
            DoubleCellValue(importe),
            const DoubleCellValue(0.0),
          ]);
          break;
      }
    }

    // Agregar la fila resumen con los totales de los impuestos
    sheetObject.appendRow([
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(concepto.subTotal),
      DoubleCellValue(concepto.descuento),
      TextCellValue(''),
      DoubleCellValue(totalIVATrasladado), // totalIVATrasladado
      TextCellValue(''), // totalIEPSTrasladado
      TextCellValue(''), // totalISRRetenido
      TextCellValue(''), // totalIVARetenido
      DoubleCellValue(concepto.total),
    ]);

    // Reiniciar los totales para el siguiente concepto
    totalIVATrasladado = 0.0;
    totalIEPSTrasladado = 0.0;
    totalISRRetenido = 0.0;
    totalIVARetenido = 0.0;
  }

  // Aplicar estilos a las celdas del cuerpo
  List<List<Data?>?> cellsSelected = sheetObject.selectRange(
    CellIndex.indexByString('B7'),
    end: CellIndex.indexByString('Z50'),
  );
  for (var cells in cellsSelected) {
    cells?.forEach((cell) {
      if (cell != null) {
        cell.cellStyle = cellStyles.cellStyleBody;
      }
    });
  }

  // Ajuste automático del ancho de columnas
  for (var i = 1; i <= sheetObject.maxColumns; i++) {
    sheetObject.setColumnAutoFit(i);
  }

  try {
    // Generar un nombre de archivo temporal
    DateTime now = DateTime.now();
    String interval = DateFormat('yyyyMMdd_HHmmss').format(now);
    String fileName = 'comprobantes_$interval.xlsx';

    // Obtener el directorio temporal
    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/$fileName';

    // Guardar el archivo en memoria
    List<int>? fileBytes = excel.encode();
    if (fileBytes != null) {
      // Crear un archivo temporal en memoria
      File tempFile = File(filePath);
      await tempFile.writeAsBytes(fileBytes);

      // Abrir el archivo con la aplicación predeterminada sin guardarlo
      await OpenFile.open(filePath, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

      return 'Archivo Excel abierto para edición. Recuerde guardarlo manualmente.';
    } else {
      return 'Error: No se pudo generar el contenido del archivo Excel';
    }
  } catch (e) {
    return 'Error inesperado: $e';
  }
}
