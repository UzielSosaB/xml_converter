import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xml_converter/components/sidebar/sidebar.dart';
import 'package:xml_converter/screens/import_export_screen.dart';
import 'package:xml_converter/screens/factura_excel_screen.dart';
import 'package:xml_converter/screens/welcome_screen.dart';
import 'package:xml_converter/styles/app_theme.dart';
import 'package:xml_converter/components/resize_handler.dart';
import 'package:xml_converter/config/app_config.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with WindowListener {
  int _selectedIndex = -1; // Start with -1 to show welcome screen
  int _selectedSubScreen = -1; // For sub-screens like Factura a Excel
  Size _windowSize = const Size(1200, 800); // Track window size
  bool _isResizing = false; // Flag for resizing state

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _getWindowSize();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // Get current window size
  Future<void> _getWindowSize() async {
    final size = await windowManager.getSize();
    setState(() {
      _windowSize = size;
    });
  }

  void onWindowResizeStart() {
    setState(() {
      _isResizing = true;
    });
  }

  @override
  void onWindowResize() async {
    _getWindowSize();
  }

  void onWindowResizeEnd() {
    setState(() {
      _isResizing = false;
    });
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedSubScreen = -1; // Reset sub-screen when changing main screen
    });
  }

  void navigateToFacturaExcel() {
    setState(() {
      _selectedSubScreen = 0; // 0 means Factura a Excel
    });
  }

  Widget _getScreenForIndex(int index) {
    // First check if we're in a sub-screen
    if (_selectedSubScreen >= 0) {
      switch (_selectedSubScreen) {
        case 0:
          return const FacturaExcelScreen();
        default:
          return const WelcomeScreen();
      }
    }

    // If not in a sub-screen, show the main screen
    switch (index) {
      case -1:
        return const WelcomeScreen();
      case 0:
        return ImportExportScreen(
          onNavigateToFacturaExcel: navigateToFacturaExcel,
        );
      default:
        return const WelcomeScreen();
    }
  }

  String _getTitleForIndex(int index) {
    // If we're in a sub-screen, return its title
    if (_selectedSubScreen >= 0) {
      switch (_selectedSubScreen) {
        case 0:
          return AppConfig.facturaExcelTitle;
        default:
          return AppConfig.companyName;
      }
    }

    // Otherwise return the main screen title
    switch (index) {
      case -1:
        return AppConfig.companyName;
      case 0:
        return AppConfig.companyName;
      default:
        return AppConfig.companyName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResizeHandler(
      borderWidth: 4.0,
      hoverColor: Colors.grey.withValues(alpha: 0.2),
      child: Scaffold(
        body: Stack(
          children: [
            // Main content positioned below the title bar
            Padding(
              padding:
                  const EdgeInsets.only(top: 32), // Space for the title bar
              child: Row(
                children: [
                  // Sidebar
                  Sidebar(
                    selectedIndex: _selectedIndex,
                    onItemSelected: _onItemSelected,
                  ),

                  // Content area
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Stack(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              // Crear una animación compuesta para entrada y salida
                              final inAnimation = Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ));

                              final outAnimation = Tween<Offset>(
                                begin: const Offset(-0.05, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInCubic,
                              ));

                              // Añadir una animación de escala sutil
                              final scaleAnimation = Tween<double>(
                                begin: 0.98,
                                end: 1.0,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ));

                              if (child.key !=
                                  ValueKey(_selectedIndex.toString() +
                                      _selectedSubScreen.toString())) {
                                // Animación de salida
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: outAnimation,
                                    child: child,
                                  ),
                                );
                              }

                              // Animación de entrada con escala
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: inAnimation,
                                  child: ScaleTransition(
                                    scale: scaleAnimation,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: KeyedSubtree(
                              key: ValueKey(_selectedIndex.toString() +
                                  _selectedSubScreen.toString()),
                              child: _getScreenForIndex(_selectedIndex),
                            ),
                          ),

                          // Show dimensions when resizing
                          if (_isResizing)
                            Positioned(
                              right: 20,
                              bottom: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${_windowSize.width.round()} × ${_windowSize.height.round()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title bar positioned on top with increased elevation
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      offset: const Offset(0, 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: GestureDetector(
                  onPanStart: (details) {
                    windowManager.startDragging();
                  },
                  child: Container(
                    height: AppTheme.spacing48,
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        const SizedBox(width: AppTheme.spacing16),
                        // Logo and company name wrapped in clickable widget
                        InkWell(
                          onTap: () {
                            // Navigate to home screen
                            setState(() {
                              _selectedIndex = -1;
                              _selectedSubScreen = -1;
                            });
                          },
                          hoverColor: Colors.white.withValues(alpha: 0.1),
                          splashColor: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Logo icon - Using a more professional accounting/business icon
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.account_balance,
                                    color: AppTheme.primaryColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Company name with improved styling
                                Text(
                                  _getTitleForIndex(_selectedIndex),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Windows-style circular buttons in correct order
                        Row(
                          children: [
                            _buildCustomButton(
                              Colors.amber,
                              Icons.minimize,
                              () async {
                                await windowManager.minimize();
                              },
                              tooltip: AppConfig.minimizeTooltip,
                            ),
                            const SizedBox(width: 8),
                            _buildCustomButton(
                              Colors.green,
                              Icons.crop_square_outlined,
                              () async {
                                bool isMaximized =
                                    await windowManager.isMaximized();
                                if (isMaximized) {
                                  await windowManager.unmaximize();
                                } else {
                                  await windowManager.maximize();
                                }
                              },
                              tooltip: AppConfig.maximizeTooltip,
                            ),
                            const SizedBox(width: 8),
                            _buildCustomButton(
                              Colors.red,
                              Icons.close,
                              () async {
                                await windowManager.close();
                              },
                              tooltip: AppConfig.closeTooltip,
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton(Color color, IconData icon, VoidCallback onPressed,
      {String? tooltip}) {
    final button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 22, // Slightly larger
        height: 22, // Slightly larger
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );

    // If tooltip is provided, wrap the button with a Tooltip widget
    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        verticalOffset: 20,
        preferBelow: true,
        child: button,
      );
    }

    return button;
  }
}
