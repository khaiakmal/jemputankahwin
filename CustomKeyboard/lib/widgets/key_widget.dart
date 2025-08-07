import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyWidget extends StatefulWidget {
  final String keyValue;
  final String? displayText;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSpecialKey;
  final double fontSize;

  const KeyWidget({
    super.key,
    required this.keyValue,
    this.displayText,
    this.onPressed,
    this.width,
    this.height = 50,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isSpecialKey = false,
    this.fontSize = 16,
  });

  @override
  State<KeyWidget> createState() => _KeyWidgetState();
}

class _KeyWidgetState extends State<KeyWidget> with TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  Color _getBackgroundColor(BuildContext context) {
    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }
    
    if (widget.isSpecialKey) {
      return _isPressed
          ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
          : Theme.of(context).colorScheme.secondary.withOpacity(0.1);
    }
    
    return _isPressed
        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
        : Theme.of(context).colorScheme.surface;
  }

  Color _getTextColor(BuildContext context) {
    if (widget.textColor != null) {
      return widget.textColor!;
    }
    
    if (widget.isSpecialKey) {
      return Theme.of(context).colorScheme.primary;
    }
    
    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: const EdgeInsets.all(2),
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: Container(
                decoration: BoxDecoration(
                  color: _getBackgroundColor(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: widget.icon != null
                      ? Icon(
                          widget.icon,
                          color: _getTextColor(context),
                          size: 20,
                        )
                      : Text(
                          widget.displayText ?? widget.keyValue,
                          style: TextStyle(
                            fontSize: widget.fontSize,
                            fontWeight: widget.isSpecialKey 
                                ? FontWeight.w600 
                                : FontWeight.w500,
                            color: _getTextColor(context),
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SpacebarWidget extends StatefulWidget {
  final VoidCallback? onPressed;
  final double? height;

  const SpacebarWidget({
    super.key,
    this.onPressed,
    this.height = 50,
  });

  @override
  State<SpacebarWidget> createState() => _SpacebarWidgetState();
}

class _SpacebarWidgetState extends State<SpacebarWidget> 
    with TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds:100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: widget.height,
            margin: const EdgeInsets.all(2),
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: Container(
                decoration: BoxDecoration(
                  color: _isPressed
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Space',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}