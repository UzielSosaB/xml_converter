import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';
import 'package:xml_converter/types/comprobante.dart'; // Asegúrate de importar el archivo correcto

Future<Comprobante?> importXml() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xml'],
  );

  if (result == null) return null;

  String? filePath = result.files.single.path;
  if (filePath == null) return null;

  File file = File(filePath);
  String fileContent = await file.readAsString();
  final XmlDocument document = XmlDocument.parse(fileContent);

  // Encuentra el nodo 'cfdi:Comprobante'
  final XmlElement cfdiComprobante =
      document.findAllElements('cfdi:Comprobante').first;
  final XmlElement cfdiEmisor = document.findAllElements('cfdi:Emisor').first;
  final XmlElement cfdiReceptor =
      document.findAllElements('cfdi:Receptor').first;
  final XmlElement cfdiComplemento =
      cfdiComprobante.findAllElements('cfdi:Complemento').first;

  try {
    // Extrae los atributos del nodo 'cfdi:Comprobante'
    DateTime fecha =
        DateTime.parse(cfdiComprobante.getAttribute('Fecha') ?? '');
    String serie = cfdiComprobante.getAttribute('Serie') ?? '';
    String folio = cfdiComprobante.getAttribute('Folio') ?? '';
    String uuid = cfdiComplemento
            .findElements('tfd:TimbreFiscalDigital')
            .first
            .getAttribute('UUID') ??
        '';
    String rfcEmisor = cfdiEmisor.getAttribute('Rfc') ?? '';
    String nombreEmisor = cfdiEmisor.getAttribute('Nombre') ?? '';
    String rfcReceptor = cfdiReceptor.getAttribute('Rfc') ?? '';
    String nombreReceptor = cfdiReceptor.getAttribute('Nombre') ?? '';
    String moneda = cfdiComprobante.getAttribute('Moneda') ?? '';

    List<Concepto> conceptos = [];
    // Extrae los conceptos
    final XmlElement conceptosNodes =
        cfdiComprobante.findAllElements('cfdi:Conceptos').first;
    final conceptoNodes = conceptosNodes.findAllElements('cfdi:Concepto');
    for (var conceptoNode in conceptoNodes) {
      String descripcion = conceptoNode.getAttribute('Descripcion') ?? '';
      double subTotal =
          double.tryParse(conceptoNode.getAttribute('Importe') ?? '') ?? 0.0;
      double descuento =
          double.tryParse(conceptoNode.getAttribute('Descuento') ?? '') ?? 0.0;

      // Extrae impuestos de cada concepto
      Impuesto impuestos = _extractImpuestos(conceptoNode);

      double total = subTotal; 
      
      for (var traslado in impuestos.traslado) {
        total = total + traslado.importe;
      }

      for (var retencion in impuestos.retencion) {
        total = total - retencion.importe;
      }

      conceptos.add(Concepto(
        descripcion: descripcion,
        subTotal: subTotal,
        descuento: descuento,
        total: total,
        impuestos: impuestos,
        impuestosPorcentaje: [],
        impuestosTotal: [],
        totalIVATrasladado: [],
        totalISRRetenido: [],
        totalIVARetenido: [],
        totalIEPSTrasladado: [],
      ));
    }

    // Crea el objeto Comprobante con los datos extraídos
    return Comprobante(
      fecha: fecha,
      serie: serie,
      folio: folio,
      uuid: uuid,
      rfcEmisor: rfcEmisor,
      nombreEmisor: nombreEmisor,
      rfcReceptor: rfcReceptor,
      nombreReceptor: nombreReceptor,
      moneda: moneda,
      conceptos: conceptos,
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error al parsear el XML: $e');
    }
    return null;
  }
}

// Función auxiliar para extraer impuestos de un concepto
Impuesto _extractImpuestos(XmlElement conceptoNode) {
  List<TipoImpuesto> traslados = [];
  List<TipoImpuesto> retenciones = [];

  // Buscar el nodo cfdi:Impuestos
  final impuestosNode = conceptoNode.findElements('cfdi:Impuestos').isNotEmpty
      ? conceptoNode.findElements('cfdi:Impuestos').first
      : null;

  if (impuestosNode != null) {
    // Buscar y procesar los nodos cfdi:Traslados
    final trasladosNode =
        impuestosNode.findElements('cfdi:Traslados').isNotEmpty
            ? impuestosNode.findElements('cfdi:Traslados').first
            : null;

    if (trasladosNode != null) {
      final trasladosNodes = trasladosNode.findElements('cfdi:Traslado');
      for (var trasladoNode in trasladosNodes) {
        traslados.add(TipoImpuesto(
          base: double.tryParse(trasladoNode.getAttribute('Base') ?? '') ?? 0.0,
          impuesto: trasladoNode.getAttribute('Impuesto') ?? '',
          tipoFactor: trasladoNode.getAttribute('TipoFactor') ?? '',
          tasaOCuota:
              double.tryParse(trasladoNode.getAttribute('TasaOCuota') ?? '') ??
                  0.0,
          importe:
              double.tryParse(trasladoNode.getAttribute('Importe') ?? '') ??
                  0.0,
        ));
      }
    }

    // Buscar y procesar los nodos cfdi:Retenciones
    final retencionesNode =
        impuestosNode.findElements('cfdi:Retenciones').isNotEmpty
            ? impuestosNode.findElements('cfdi:Retenciones').first
            : null;

    if (retencionesNode != null) {
      final retencionesNodes = retencionesNode.findElements('cfdi:Retencion');
      for (var retencionNode in retencionesNodes) {
        retenciones.add(TipoImpuesto(
          base:
              double.tryParse(retencionNode.getAttribute('Base') ?? '') ?? 0.0,
          impuesto: retencionNode.getAttribute('Impuesto') ?? '',
          tipoFactor: retencionNode.getAttribute('TipoFactor') ?? '',
          tasaOCuota:
              double.tryParse(retencionNode.getAttribute('TasaOCuota') ?? '') ??
                  0.0,
          importe:
              double.tryParse(retencionNode.getAttribute('Importe') ?? '') ??
                  0.0,
        ));
      }
    }
  }

  return Impuesto(traslado: traslados, retencion: retenciones);
}
