import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';
import 'package:xml_converter/types/comprobante.dart'; // Asegúrate de importar el archivo correcto
import 'package:archive/archive.dart';

Future<List<Comprobante>?> importXml() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xml', '7z', 'zip', 'rar'],
    allowMultiple: true,
  );

  if (result == null) return null;

  List<Comprobante> comprobantes = [];

  for (var file in result.files) {
    String? filePath = file.path;
    if (filePath == null) continue;

    File fileToProcess = File(filePath);
    String extension = filePath.split('.').last.toLowerCase();

    if (['7z', 'zip', 'rar'].contains(extension)) {
      // Procesar archivo comprimido
      try {
        List<int> bytes = await fileToProcess.readAsBytes();
        Archive archive = ZipDecoder().decodeBytes(bytes);
        
        for (ArchiveFile archiveFile in archive) {
          if (archiveFile.name.toLowerCase().endsWith('.xml')) {
            String xmlContent = String.fromCharCodes(archiveFile.content);
            await _procesarContenidoXml(xmlContent, comprobantes);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error al procesar archivo comprimido: $e');
        }
        continue;
      }
    } else if (extension == 'xml') {
      // Procesar archivo XML directamente
      try {
        String fileContent = await fileToProcess.readAsString();
        await _procesarContenidoXml(fileContent, comprobantes);
      } catch (e) {
        if (kDebugMode) {
          print('Error al procesar archivo XML: $e');
        }
        continue;
      }
    }
  }

  return comprobantes.isEmpty ? null : comprobantes;
}

Future<void> _procesarContenidoXml(String contenido, List<Comprobante> comprobantes) async {
  try {
    final XmlDocument document = XmlDocument.parse(contenido);
    Comprobante? comprobante = await _procesarXml(document);
    if (comprobante != null) {
      comprobantes.add(comprobante);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error al procesar contenido XML: $e');
    }
  }
}

Future<Comprobante?> _procesarXml(XmlDocument document) async {
  try {
    final XmlElement cfdiComprobante = document.findAllElements('cfdi:Comprobante').first;
    final XmlElement cfdiEmisor = document.findAllElements('cfdi:Emisor').first;
    final XmlElement cfdiReceptor = document.findAllElements('cfdi:Receptor').first;
    final XmlElement cfdiComplemento = document.findAllElements('cfdi:Complemento').first;
    final XmlElement timbreFiscal = cfdiComplemento.findAllElements('tfd:TimbreFiscalDigital').first;

    // Extraer datos básicos del comprobante
    String serie = cfdiComprobante.getAttribute('Serie') ?? '';
    String folio = cfdiComprobante.getAttribute('Folio') ?? '';
    DateTime fecha = DateTime.parse(cfdiComprobante.getAttribute('Fecha') ?? '');
    String moneda = cfdiComprobante.getAttribute('Moneda') ?? '';
    
    // Datos del emisor y receptor
    String rfcEmisor = cfdiEmisor.getAttribute('Rfc') ?? '';
    String nombreEmisor = cfdiEmisor.getAttribute('Nombre') ?? '';
    String rfcReceptor = cfdiReceptor.getAttribute('Rfc') ?? '';
    String nombreReceptor = cfdiReceptor.getAttribute('Nombre') ?? '';
    
    // UUID del timbre fiscal
    String uuid = timbreFiscal.getAttribute('UUID') ?? '';

    // Procesar conceptos
    List<Concepto> conceptos = [];
    for (var conceptoXml in document.findAllElements('cfdi:Concepto')) {
      List<TipoImpuesto> traslados = [];
      List<TipoImpuesto> retenciones = [];

      // Procesar impuestos del concepto
      var impuestosNode = conceptoXml.findElements('cfdi:Impuestos').firstOrNull;
      if (impuestosNode != null) {
        // Procesar traslados
        var trasladosNode = impuestosNode.findElements('cfdi:Traslados').firstOrNull;
        if (trasladosNode != null) {
          for (var traslado in trasladosNode.findElements('cfdi:Traslado')) {
            traslados.add(TipoImpuesto(
              base: double.parse(traslado.getAttribute('Base') ?? '0'),
              impuesto: traslado.getAttribute('Impuesto') ?? '',
              tipoFactor: traslado.getAttribute('TipoFactor') ?? '',
              tasaOCuota: double.parse(traslado.getAttribute('TasaOCuota') ?? '0'),
              importe: double.parse(traslado.getAttribute('Importe') ?? '0'),
            ));
          }
        }

        // Procesar retenciones
        var retencionesNode = impuestosNode.findElements('cfdi:Retenciones').firstOrNull;
        if (retencionesNode != null) {
          for (var retencion in retencionesNode.findElements('cfdi:Retencion')) {
            retenciones.add(TipoImpuesto(
              base: double.parse(retencion.getAttribute('Base') ?? '0'),
              impuesto: retencion.getAttribute('Impuesto') ?? '',
              tipoFactor: retencion.getAttribute('TipoFactor') ?? '',
              tasaOCuota: double.parse(retencion.getAttribute('TasaOCuota') ?? '0'),
              importe: double.parse(retencion.getAttribute('Importe') ?? '0'),
            ));
          }
        }
      }

      double subTotal = double.parse(conceptoXml.getAttribute('Importe') ?? '0');
      double descuento = double.parse(conceptoXml.getAttribute('Descuento') ?? '0');
      
      // Calcular totales de impuestos
      List<double> totalIVATrasladado = traslados
          .where((t) => t.impuesto == '002')
          .map((t) => t.importe)
          .toList();
      List<double> totalIEPSTrasladado = traslados
          .where((t) => t.impuesto == '003')
          .map((t) => t.importe)
          .toList();
      List<double> totalISRRetenido = retenciones
          .where((t) => t.impuesto == '001')
          .map((t) => t.importe)
          .toList();
      List<double> totalIVARetenido = retenciones
          .where((t) => t.impuesto == '002')
          .map((t) => t.importe)
          .toList();

      conceptos.add(Concepto(
        descripcion: conceptoXml.getAttribute('Descripcion') ?? '',
        subTotal: subTotal,
        descuento: descuento,
        total: subTotal - descuento + 
               (totalIVATrasladado.isEmpty ? 0 : totalIVATrasladado.reduce((a, b) => a + b)) +
               (totalIEPSTrasladado.isEmpty ? 0 : totalIEPSTrasladado.reduce((a, b) => a + b)) -
               (totalISRRetenido.isEmpty ? 0 : totalISRRetenido.reduce((a, b) => a + b)) -
               (totalIVARetenido.isEmpty ? 0 : totalIVARetenido.reduce((a, b) => a + b)),
        impuestos: Impuesto(
          traslado: traslados,
          retencion: retenciones,
        ),
        impuestosPorcentaje: traslados.map((t) => t.tasaOCuota).toList(),
        impuestosTotal: traslados.map((t) => t.importe).toList(),
        totalIVATrasladado: totalIVATrasladado,
        totalIEPSTrasladado: totalIEPSTrasladado,
        totalISRRetenido: totalISRRetenido,
        totalIVARetenido: totalIVARetenido,
      ));
    }

    return Comprobante(
      fecha: fecha,
      serie: serie,
      folio: folio,
      uuid: uuid,
      rfcReceptor: rfcReceptor,
      nombreReceptor: nombreReceptor,
      rfcEmisor: rfcEmisor,
      nombreEmisor: nombreEmisor,
      moneda: moneda,
      conceptos: conceptos,
    );

  } catch (e) {
    if (kDebugMode) {
      print('Error al procesar archivo XML: $e');
    }
    return null;
  }
}
