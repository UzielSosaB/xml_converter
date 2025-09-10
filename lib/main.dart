import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xml_converter/components/main_layout.dart';
import 'package:xml_converter/styles/app_theme.dart';
import 'package:xml_converter/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: const Size(1200, 800),
    minimumSize: const Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: AppConfig.appName,
    windowButtonVisibility: false,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setResizable(true);
  });

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: AppTheme.getTheme(),
      home: const MainLayout(),
    );
  }
}
