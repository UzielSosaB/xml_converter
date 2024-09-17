import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xml_converter/comprobante_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'XML Converter',
    windowButtonVisibility: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const Scaffold(
        body: Center(
          child: ComprobanteForm(),
        ),
      ),
    );
  }
}
