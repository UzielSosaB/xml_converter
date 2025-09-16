import 'dart:io';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:open_file/open_file.dart';
import 'package:xml_converter/types/comprobante.dart';
import 'package:file_picker/file_picker.dart';

Future<String> createExcel(List<Comprobante> comprobantes,
    {bool todoEnUno = false}) async {
  final xlsio.Workbook workbook = xlsio.Workbook();
  final xlsio.Worksheet sheet = workbook.worksheets[0];

  // Título del documento
  sheet.getRangeByName('B2:S4').merge();
  sheet.getRangeByName('B2').setText('Registro de Comprobantes');
  sheet.getRangeByName('B2').cellStyle.fontSize = 16;
  sheet.getRangeByName('B2').cellStyle.bold = true;
  sheet.getRangeByName('B2').cellStyle.hAlign = xlsio.HAlignType.center;
  sheet.getRangeByName('B2').cellStyle.vAlign = xlsio.VAlignType.center;

  // Encabezados
  final headers = [
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
    'TASA IVA %',
    'TOTAL IVA TRASLADADO',
    'TOTAL IEPS TRASLADADO',
    'TOTAL ISR RETENIDO',
    'TOTAL IVA RETENIDO',
    'TOTAL',
  ];

  // Agregar encabezados
  for (var i = 0; i < headers.length; i++) {
    sheet.getRangeByIndex(5, i + 1).setText(headers[i]);
    sheet.getRangeByIndex(5, i + 1).cellStyle.bold = true;
    sheet.getRangeByIndex(5, i + 1).cellStyle.backColor = '#D3D3D3';
  }

  int currentRow = 7;

  for (var data in comprobantes) {
    if (data.conceptos.isNotEmpty) {
      bool isFirstRow = true;

      if (todoEnUno) {
        // Calculate totals
        double totalSubtotal = 0;
        double totalDescuento = 0;
        double totalIVA = 0;
        double totalIEPS = 0;
        double totalISR = 0;
        double totalIVARet = 0;
        double total = 0;
        String tasaIVAPromedio = '';

        // Concatenate all concepts with semicolon separator for compact display
        String allConcepts =
            data.conceptos.map((c) => c.descripcion).join('; ');

        // Calcular tasa de IVA promedio
        List<double> tasasIVA = [];
        for (var concepto in data.conceptos) {
          for (var traslado in concepto.impuestos.traslado) {
            if (traslado.impuesto == '002') {
              // IVA
              tasasIVA.add(traslado.tasaOCuota);
            }
          }
        }

        if (tasasIVA.isNotEmpty) {
          double tasaPromedio =
              tasasIVA.reduce((a, b) => a + b) / tasasIVA.length;
          tasaIVAPromedio = '${(tasaPromedio * 100).toStringAsFixed(0)}%';
        }

        for (var concepto in data.conceptos) {
          totalSubtotal += concepto.subTotal;
          totalDescuento += concepto.descuento;
          totalIVA += concepto.totalIVATrasladado.isNotEmpty
              ? concepto.totalIVATrasladado[0]
              : 0;
          totalIEPS += concepto.totalIEPSTrasladado.isNotEmpty
              ? concepto.totalIEPSTrasladado[0]
              : 0;
          totalISR += concepto.totalISRRetenido.isNotEmpty
              ? concepto.totalISRRetenido[0]
              : 0;
          totalIVARet += concepto.totalIVARetenido.isNotEmpty
              ? concepto.totalIVARetenido[0]
              : 0;
          total += concepto.total;
        }

        // Add single row with totals
        sheet
            .getRangeByIndex(currentRow, 2)
            .setText(DateFormat('yyyy-MM-dd').format(data.fecha));
        sheet.getRangeByIndex(currentRow, 3).setText(data.serie);
        sheet.getRangeByIndex(currentRow, 4).setText(data.folio);
        sheet.getRangeByIndex(currentRow, 5).setText(data.uuid);
        sheet.getRangeByIndex(currentRow, 6).setText(data.rfcEmisor);
        sheet.getRangeByIndex(currentRow, 7).setText(data.nombreEmisor);
        sheet.getRangeByIndex(currentRow, 8).setText(data.rfcReceptor);
        sheet.getRangeByIndex(currentRow, 9).setText(data.nombreReceptor);
        sheet.getRangeByIndex(currentRow, 10).setText(data.moneda);
        sheet.getRangeByIndex(currentRow, 11).setText(allConcepts);
        // Desactivar explícitamente el wrapText
        sheet.getRangeByIndex(currentRow, 11).cellStyle.wrapText = false;
        sheet.getRangeByIndex(currentRow, 12).setValue(totalSubtotal);
        sheet.getRangeByIndex(currentRow, 12).numberFormat = '#,##0.00';
        sheet.getRangeByIndex(currentRow, 13).setValue(totalDescuento);
        sheet.getRangeByIndex(currentRow, 13).numberFormat = '#,##0.00';
        sheet.getRangeByIndex(currentRow, 14).setValue(tasaIVAPromedio);
        sheet.getRangeByIndex(currentRow, 15).setValue(totalIVA);
        sheet.getRangeByIndex(currentRow, 15).numberFormat = '#,##0.00';
        sheet.getRangeByIndex(currentRow, 16).setValue(totalIEPS);
        sheet.getRangeByIndex(currentRow, 16).numberFormat = '#,##0.00';
        sheet.getRangeByIndex(currentRow, 17).setValue(totalISR);
        sheet.getRangeByIndex(currentRow, 17).numberFormat = '#,##0.00';
        sheet.getRangeByIndex(currentRow, 18).setValue(totalIVARet);
        sheet.getRangeByIndex(currentRow, 18).numberFormat = '#,##0.00';
        sheet.getRangeByIndex(currentRow, 19).setValue(total);
        sheet.getRangeByIndex(currentRow, 19).numberFormat = '#,##0.00';

        currentRow += 2;
      } else {
        for (var concepto in data.conceptos) {
          var descuento = concepto.descuento;

          // Buscar específicamente el IVA (impuesto 002) para mostrar su porcentaje
          var tasaIVA = '';
          var ivaTrasladado = 0.0;
          var iepsTrasladado = 0.0;
          var isrRetenido = 0.0;
          var ivaRetenido = 0.0;

          // Procesar traslados (IVA, IEPS, etc.)
          for (var traslado in concepto.impuestos.traslado) {
            if (traslado.impuesto == '002') {
              // IVA
              tasaIVA = '${(traslado.tasaOCuota * 100).toStringAsFixed(0)}%';
              ivaTrasladado = traslado.importe;
            } else if (traslado.impuesto == '003') {
              // IEPS
              iepsTrasladado = traslado.importe;
            }
          }

          // Procesar retenciones (ISR, IVA retenido, etc.)
          for (var retencion in concepto.impuestos.retencion) {
            if (retencion.impuesto == '001') {
              // ISR
              isrRetenido = retencion.importe;
            } else if (retencion.impuesto == '002') {
              // IVA retenido
              ivaRetenido = retencion.importe;
            }
          }

          // Agregar datos
          if (isFirstRow) {
            sheet
                .getRangeByIndex(currentRow, 2)
                .setText(DateFormat('yyyy-MM-dd').format(data.fecha));
            sheet.getRangeByIndex(currentRow, 3).setText(data.serie);
            sheet.getRangeByIndex(currentRow, 4).setText(data.folio);
            sheet.getRangeByIndex(currentRow, 5).setText(data.uuid);
            sheet.getRangeByIndex(currentRow, 6).setText(data.rfcEmisor);
            sheet.getRangeByIndex(currentRow, 7).setText(data.nombreEmisor);
            sheet.getRangeByIndex(currentRow, 8).setText(data.rfcReceptor);
            sheet.getRangeByIndex(currentRow, 9).setText(data.nombreReceptor);
            sheet.getRangeByIndex(currentRow, 10).setText(data.moneda);
          }

          // Agregar concepto
          sheet.getRangeByIndex(currentRow, 11).setText(concepto.descripcion);
          // Desactivar explícitamente el wrapText
          sheet.getRangeByIndex(currentRow, 11).cellStyle.wrapText = false;
          sheet.getRangeByIndex(currentRow, 12).setValue(concepto.subTotal);
          sheet.getRangeByIndex(currentRow, 12).numberFormat = '#,##0.00';
          sheet
              .getRangeByIndex(currentRow, 13)
              .setValue(descuento > 0 ? descuento : null);
          if (descuento > 0) {
            sheet.getRangeByIndex(currentRow, 13).numberFormat = '#,##0.00';
          }
          sheet.getRangeByIndex(currentRow, 14).setValue(tasaIVA);
          sheet
              .getRangeByIndex(currentRow, 15)
              .setValue(ivaTrasladado > 0 ? ivaTrasladado : null);
          if (ivaTrasladado > 0) {
            sheet.getRangeByIndex(currentRow, 15).numberFormat = '#,##0.00';
          }
          sheet
              .getRangeByIndex(currentRow, 16)
              .setValue(iepsTrasladado > 0 ? iepsTrasladado : null);
          if (iepsTrasladado > 0) {
            sheet.getRangeByIndex(currentRow, 16).numberFormat = '#,##0.00';
          }
          sheet
              .getRangeByIndex(currentRow, 17)
              .setValue(isrRetenido > 0 ? isrRetenido : null);
          if (isrRetenido > 0) {
            sheet.getRangeByIndex(currentRow, 17).numberFormat = '#,##0.00';
          }
          sheet
              .getRangeByIndex(currentRow, 18)
              .setValue(ivaRetenido > 0 ? ivaRetenido : null);
          if (ivaRetenido > 0) {
            sheet.getRangeByIndex(currentRow, 18).numberFormat = '#,##0.00';
          }
          sheet.getRangeByIndex(currentRow, 19).setValue(concepto.total);
          sheet.getRangeByIndex(currentRow, 19).numberFormat = '#,##0.00';

          isFirstRow = false;
          currentRow++;
        }

        // Agregar separador y línea divisoria
        currentRow += 1;
        sheet
            .getRangeByIndex(currentRow, 1, currentRow, headers.length)
            .cellStyle
            .borders
            .bottom
            .lineStyle = xlsio.LineStyle.thick;
        currentRow += 1;
      }
    }
  }

  // Configurar formato de columnas
  for (var i = 1; i <= headers.length; i++) {
    if (i == 11) {
      // Columna K (CONCEPTO) - ancho fijo de 18
      sheet.getRangeByIndex(1, 11, 1, 11).columnWidth = 18;
    } else {
      sheet.autoFitColumn(i);
    }
  }

  try {
    // Generar nombre de archivo sugerido
    DateTime now = DateTime.now();
    String interval = DateFormat('yyyyMMdd_HHmmss').format(now);
    String suggestedName = 'comprobantes_$interval.xlsx';

    // Solicitar al usuario que elija la ubicación de guardado
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar archivo Excel',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (outputFile == null) {
      return 'Operación cancelada por el usuario';
    }

    // Guardar archivo en la ubicación elegida
    final List<int> bytes = workbook.saveAsStream();
    File(outputFile).writeAsBytes(bytes);
    workbook.dispose();

    // Abrir archivo
    await OpenFile.open(outputFile,
        type:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

    return 'Archivo Excel guardado y abierto correctamente.';
  } catch (e) {
    return 'Error inesperado: $e';
  }
}
