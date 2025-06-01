import 'package:flutter/material.dart';
import 'dart:async';

class TopNotificationBanner extends StatefulWidget {
  final String message;
  final bool visible;
  final String status; // 'success', 'error', 'info'
  final VoidCallback? onDismiss;
  final Duration duration;

  const TopNotificationBanner({
    Key? key,
    required this.message,
    required this.visible,
    this.status = 'info',
    this.onDismiss,
    this.duration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<TopNotificationBanner> createState() => _TopNotificationBannerState();
}

class _TopNotificationBannerState extends State<TopNotificationBanner>
    with SingleTickerProviderStateMixin {
  bool _show = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    _show = widget.visible;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    if (_show) {
      _controller.forward();
      _startAutoHide();
    }
  }

  @override
  void didUpdateWidget(covariant TopNotificationBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !_show) {
      setState(() => _show = true);
      _controller.forward();
      _startAutoHide();
    } else if (!widget.visible && _show) {
      _controller.reverse();
      setState(() => _show = false);
    }
    if (widget.message != oldWidget.message && widget.visible) {
      _startAutoHide();
    }
  }

  void _startAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(widget.duration, () {
      if (mounted && _show) {
        _controller.reverse();
        setState(() => _show = false);
        if (widget.onDismiss != null) widget.onDismiss!();
      }
    });
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.status) {
      case 'success':
        return Colors.green.shade600;
      case 'error':
        return Colors.red.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  IconData get _icon {
    switch (widget.status) {
      case 'success':
        return Icons.check_circle_outline;
      case 'error':
        return Icons.error_outline;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return SizedBox.shrink();
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta != null && details.primaryDelta! < -10) {
              _controller.reverse();
              setState(() => _show = false);
              if (widget.onDismiss != null) widget.onDismiss!();
            }
          },
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_icon, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _controller.reverse();
                      setState(() => _show = false);
                      if (widget.onDismiss != null) widget.onDismiss!();
                    },
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
