import 'package:flutter/material.dart';
import 'package:xml_converter/func/excel_creator.dart';
import 'package:xml_converter/func/xml_importer.dart';
import 'package:xml_converter/types/comprobante.dart';

class ComprobanteForm extends StatefulWidget {
  const ComprobanteForm({super.key});

  @override
  State<ComprobanteForm> createState() => _ComprobanteFormState();
}

class _ComprobanteFormState extends State<ComprobanteForm> {
  late Comprobante extractedData;
  String _xmlContent = 'No se ha seleccionado un archivo XML';

  Future<void> _importXml() async {
    Comprobante? data = await importXml();
    if (data == null) return;

    setState(() {
      extractedData = data;
      _xmlContent = '''
      Serie: ${data.serie}
      Fecha: ${data.fecha.toIso8601String()}
      Folio: ${data.folio}
      UUID: ${data.uuid}
      RFC Emisor: ${data.rfcEmisor}
      Nombre Emisor: ${data.nombreEmisor}
      RFC Receptor: ${data.rfcReceptor}
      Nombre Receptor: ${data.nombreReceptor}
      Moneda: ${data.moneda}
      
      Conceptos:
      ${data.conceptos.isNotEmpty ? data.conceptos.map((c) => '''
          Descripción: ${c.descripcion}
          SubTotal: ${c.subTotal}
          Descuento: ${c.descuento}
          Total: ${c.total}
          Impuestos:
          ${c.impuestos.traslado.isNotEmpty ? c.impuestos.traslado.map((i) => '''
              Base: ${i.base}
              Impuesto: ${i.impuesto}
              Tipo Factor: ${i.tipoFactor}
              Tasa o Cuota: ${i.tasaOCuota}
              Importe: ${i.importe}
              <--Fin de traslados-->
            ''').join('\n') : ''}
          ${c.impuestos.retencion.isNotEmpty ? c.impuestos.retencion.map((i) => '''
              Base: ${i.base}
              Impuesto: ${i.impuesto}
              Tipo Factor: ${i.tipoFactor}
              Tasa o Cuota: ${i.tasaOCuota}
              Importe: ${i.importe}
              <--Fin de Retenciones-->
            ''').join('\n')  : ''}
        ''').join('\n') : '<--Fin de Conceptos-->'}
        <--Fin de Conceptos-->
    ''';
    });
  }

  Future<void> _createExcel() async {
    final String message = await createExcel(extractedData);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        elevation: 4.0,
        shadowColor: Theme.of(context).colorScheme.shadow,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Registro de Comprobante',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                      ),
                      onPressed: _importXml,
                      child: const Row(
                        children: [
                          Text('Importar XML'),
                          SizedBox(width: 8.0),
                          Icon(Icons.file_upload_outlined),
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                      ),
                      onPressed: _createExcel,
                      child: const Row(
                        children: [
                          Text('Generar Excel'),
                          SizedBox(width: 8.0),
                          Icon(Icons.file_download_outlined),
                        ],
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Card(
                elevation: 5.0,
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    maxLines: null,
                    readOnly: true,
                    controller: TextEditingController(text: _xmlContent),
                    decoration: const InputDecoration.collapsed(hintText: ''),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
