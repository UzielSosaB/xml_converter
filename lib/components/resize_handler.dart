import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// A component that adds resize handlers to the edges of the window
class ResizeHandler extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final Color? hoverColor;

  const ResizeHandler({
    super.key,
    required this.child,
    this.borderWidth = 5.0,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        child,

        // Right edge
        Positioned(
          right: 0,
          top: borderWidth,
          bottom: borderWidth,
          child: _buildResizeHandler(
            cursor: SystemMouseCursors.resizeLeftRight,
            onPanStart: (_) => windowManager.startResizing(ResizeEdge.right),
            width: borderWidth,
            height: double.infinity,
          ),
        ),

        // Bottom edge
        Positioned(
          bottom: 0,
          left: borderWidth,
          right: borderWidth,
          child: _buildResizeHandler(
            cursor: SystemMouseCursors.resizeUpDown,
            onPanStart: (_) => windowManager.startResizing(ResizeEdge.bottom),
            width: double.infinity,
            height: borderWidth,
          ),
        ),

        // Left edge
        Positioned(
          left: 0,
          top: borderWidth,
          bottom: borderWidth,
          child: _buildResizeHandler(
            cursor: SystemMouseCursors.resizeLeftRight,
            onPanStart: (_) => windowManager.startResizing(ResizeEdge.left),
            width: borderWidth,
            height: double.infinity,
          ),
        ),

        // Top edge
        Positioned(
          top: 0,
          left: borderWidth,
          right: borderWidth,
          child: _buildResizeHandler(
            cursor: SystemMouseCursors.resizeUpDown,
            onPanStart: (_) => windowManager.startResizing(ResizeEdge.top),
            width: double.infinity,
            height: borderWidth,
          ),
        ),

        // Top-left corner
        Positioned(
          top: 0,
          left: 0,
          child: _buildResizeHandler(
            cursor: SystemMouseCursors.resizeUpLeftDownRight,
            onPanStart: (_) => windowManager.startResizing(ResizeEdge.topLeft),
            width: borderWidth,
            height: borderWidth,
          ),
        ),

        // Top-right corner
        Positioned(
          top: 0,
          right: 0,
          child: _buildResizeHandler(
            cursor: SystemMouseCursors.resizeUpRightDownLeft,
            onPanStart: (_) => windowManager.startResizing(ResizeEdge.topRight),
            width: borderWidth,
            height: borderWidth,
          ),
        ),

        // Bottom-left corner
        Positioned(
          bottom: 0,
          left: 0,
          child: _buildResizeHandler(
            cursor: SystemMouseCursors.resizeUpRightDownLeft,
            onPanStart: (_) =>
                windowManager.startResizing(ResizeEdge.bottomLeft),
            width: borderWidth,
            height: borderWidth,
          ),
        ),

        // Bottom-right corner
        Positioned(
          bottom: 0,
          right: 0,
          child: _buildResizeHandler(
            cursor: SystemMouseCursors.resizeUpLeftDownRight,
            onPanStart: (_) =>
                windowManager.startResizing(ResizeEdge.bottomRight),
            width: borderWidth,
            height: borderWidth,
          ),
        ),
      ],
    );
  }

  Widget _buildResizeHandler({
    required MouseCursor cursor,
    required Function(DragStartDetails) onPanStart,
    required double width,
    required double height,
  }) {
    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        onPanStart: onPanStart,
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: width,
          height: height,
          color: Colors.transparent,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              hoverColor: hoverColor ?? Colors.grey.withValues(alpha: 0.1),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {},
            ),
          ),
        ),
      ),
    );
  }
}
