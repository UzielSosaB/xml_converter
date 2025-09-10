import 'package:flutter/material.dart';
import 'package:xml_converter/styles/app_theme.dart';
import 'package:xml_converter/config/app_config.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
  // Default sidebar width
  double sidebarWidth = 200;
  // Min and max constraints
  static const double minWidth = 180;
  static const double maxWidth = 300;

  // Animation controller for press effect
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar content
        Container(
          width: sidebarWidth,
          color: AppTheme.primaryColor,
          child: Column(
            children: [
              // Add a small padding at the top for better spacing
              const SizedBox(height: 24),

              // Import/Export option
              GestureDetector(
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) {
                  _animationController.reverse();
                  widget.onItemSelected(0);
                },
                onTapCancel: () => _animationController.reverse(),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0.0,
                      end: widget.selectedIndex == 0 ? 1.0 : 0.0,
                    ),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: widget.selectedIndex == 0
                            ? 1.0
                            : _scaleAnimation.value,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacing16,
                            horizontal: AppTheme.spacing8,
                          ),
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              Colors.transparent,
                              AppTheme.highlightColor,
                              value,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1 * value),
                                blurRadius: 4 * value,
                                offset: Offset(0, 2 * value),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(width: 8),
                              Container(
                                width: 42,
                                height: 42,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color.lerp(
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.15),
                                    value,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Image.asset(
                                  'assets/icons/import_export.png',
                                  color: Color.lerp(
                                    Colors.white.withValues(alpha: 0.5),
                                    Colors.white,
                                    value,
                                  ),
                                  width: 26,
                                  height: 26,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.import_export,
                                      color: Color.lerp(
                                        Colors.white.withValues(alpha: 0.5),
                                        Colors.white,
                                        value,
                                      ),
                                      size: 26,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacing16),
                              Expanded(
                                child: Text(
                                  AppConfig.importExportTitle,
                                  style: TextStyle(
                                    color: Color.lerp(
                                      Colors.white.withValues(alpha: 0.5),
                                      Colors.white,
                                      value,
                                    ),
                                    fontSize: 13,
                                    fontWeight: value > 0.5
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Container(
                                width: 3 * value,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const Spacer(),

              // Version text at bottom
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                child: Text(
                  '${AppConfig.appName} ${AppConfig.appVersion}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                ),
              ),
            ],
          ),
        ),

        // Resizable handle
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              // Update width based on drag, respecting min/max constraints
              sidebarWidth =
                  (sidebarWidth + details.delta.dx).clamp(minWidth, maxWidth);
            });
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: Container(
              width: 4,
              color: Colors.grey.withValues(alpha: 0.3),
              height: double.infinity,
            ),
          ),
        ),
      ],
    );
  }
}
