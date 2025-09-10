import 'package:flutter/material.dart';
import 'package:xml_converter/func/xml_importer.dart';
import 'package:xml_converter/func/excel_creator.dart';
import 'package:xml_converter/styles/app_theme.dart';
import 'package:xml_converter/types/comprobante.dart';

class FacturaExcelScreen extends StatefulWidget {
  const FacturaExcelScreen({super.key});

  @override
  State<FacturaExcelScreen> createState() => _FacturaExcelScreenState();
}

class _FacturaExcelScreenState extends State<FacturaExcelScreen> {
  List<Comprobante> extractedData = [];
  int _currentStep = 0;
  bool _todoEnUno = false;
  bool _generatingExcel = false;

  Future<void> _selectFiles() async {
    List<Comprobante>? data = await importXml();
    if (data == null) return;

    setState(() {
      extractedData = data;
      _currentStep = 1;
    });
  }

  Future<void> _generateExcel() async {
    if (extractedData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero debes seleccionar archivos XML')),
      );
      return;
    }

    setState(() {
      _generatingExcel = true;
    });

    try {
      final String message =
          await createExcel(extractedData, todoEnUno: _todoEnUno);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      // Move to step 3 only if successful
      if (message.contains('correctamente')) {
        setState(() {
          _currentStep = 2;
        });
      }
    } finally {
      setState(() {
        _generatingExcel = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  'Convertir Factura a Excel',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Header content
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon with teal background
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF41C7BD),
                            borderRadius:
                                BorderRadius.circular(AppTheme.borderRadius8),
                          ),
                          child: const Icon(
                            Icons.file_present,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Convertir Factura a Excel',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppTheme.spacing8),
                              Text(
                                'Importa y exporta tus facturas XML a Excel de manera automática',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Step wizard content
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Step indicators
                          Padding(
                            padding: const EdgeInsets.all(AppTheme.spacing16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStepIndicator(1, 'Seleccionar archivos',
                                    _currentStep >= 0),
                                _buildStepSeparator(_currentStep >= 1),
                                _buildStepIndicator(
                                    2, 'Generar archivo', _currentStep >= 1),
                                _buildStepSeparator(_currentStep >= 2),
                                _buildStepIndicator(
                                    3, 'Revisar archivo', _currentStep >= 2),
                              ],
                            ),
                          ),

                          // Step content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(AppTheme.spacing16),
                              child: _buildCurrentStepContent(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        // Circle with number
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.accentColor : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black54,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),

        // Step label
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black87 : Colors.black54,
            fontWeight:
                _currentStep == step - 1 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepSeparator(bool isActive) {
    return Container(
      width: 60,
      height: 2,
      color: isActive ? AppTheme.accentColor : Colors.grey.shade300,
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Content();
      case 1:
        return _buildStep2Content();
      case 2:
        return _buildStep3Content();
      default:
        return Container();
    }
  }

  Widget _buildStep1Content() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Step 1 description
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adjunta uno o todos los archivos necesarios para generar el archivo Excel.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Soporta múltiples archivos .xml, .xml.gz',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),

        // File selection button
        Center(
          child: ElevatedButton(
            onPressed: _selectFiles,
            child: const Text('Seleccionar archivos'),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Content() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Step 2 description
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Archivos seleccionados: ${extractedData.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Da click en el botón de generar archivo para crear el archivo Excel con toda la información.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Todo en uno option
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: _todoEnUno,
              onChanged: (value) {
                setState(() {
                  _todoEnUno = value ?? false;
                });
              },
            ),
            const Text('Todo en Uno'),
          ],
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Back button
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                  extractedData = [];
                });
              },
              child: const Text('Seleccionar otros archivos'),
            ),
            const SizedBox(width: AppTheme.spacing16),

            // Generate button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
              ),
              onPressed: _generatingExcel ? null : _generateExcel,
              child: _generatingExcel
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Generar archivo'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3Content() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Step 3 description
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Revisa el archivo generado en la ruta.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Usuarios documentos',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),

        // Success icon
        Icon(
          Icons.check_circle_outline,
          size: 64,
          color: Colors.green,
        ),
        const SizedBox(height: AppTheme.spacing16),

        // Success message
        Text(
          '¡Archivo Excel generado correctamente!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
        ),
        const SizedBox(height: AppTheme.spacing24),

        // Button to start over
        ElevatedButton(
          onPressed: () {
            setState(() {
              _currentStep = 0;
              extractedData = [];
            });
          },
          child: const Text('Generar otro archivo'),
        ),
      ],
    );
  }
}
