import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/preferences_service.dart';

class KeyboardKey extends StatefulWidget {
  final String keyValue;
  final String? displayText;
  final IconData? icon;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final int flex;
  final bool isSpecial;
  final bool isSpacebar;
  final bool isPressed;

  const KeyboardKey({
    super.key,
    required this.keyValue,
    this.displayText,
    this.icon,
    required this.onPressed,
    this.onLongPress,
    this.flex = 1,
    this.isSpecial = false,
    this.isSpacebar = false,
    this.isPressed = false,
  });

  @override
  State<KeyboardKey> createState() => _KeyboardKeyState();
}

class _KeyboardKeyState extends State<KeyboardKey>
    with TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _scaleController.forward();
    _rippleController.forward();
    
    // Haptic feedback
    final prefs = PreferencesService.instance;
    if (prefs.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
    _rippleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Expanded(
      flex: widget.flex,
      child: Container(
        margin: const EdgeInsets.all(2),
        height: 48,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _rippleAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onLongPress: widget.onLongPress,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(colorScheme),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Ripple effect
                      if (_rippleAnimation.value > 0)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(
                                0.2 * _rippleAnimation.value,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      
                      // Key content
                      Center(
                        child: _buildKeyContent(colorScheme),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    if (widget.isPressed || _isPressed) {
      return colorScheme.primary.withOpacity(0.3);
    }
    
    if (widget.isSpecial) {
      return colorScheme.secondary.withOpacity(0.1);
    }
    
    if (widget.isSpacebar) {
      return colorScheme.surface;
    }
    
    return colorScheme.surface;
  }

  Widget _buildKeyContent(ColorScheme colorScheme) {
    if (widget.icon != null) {
      return Icon(
        widget.icon,
        color: _getTextColor(colorScheme),
        size: widget.isSpecial ? 18 : 16,
      );
    }

    if (widget.isSpacebar) {
      return const SizedBox.shrink();
    }

    final displayText = widget.displayText ?? widget.keyValue;
    
    return Text(
      displayText,
      style: TextStyle(
        color: _getTextColor(colorScheme),
        fontSize: _getFontSize(),
        fontWeight: widget.isSpecial ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  Color _getTextColor(ColorScheme colorScheme) {
    if (widget.isPressed || _isPressed) {
      return colorScheme.primary;
    }
    
    if (widget.isSpecial) {
      return colorScheme.primary;
    }
    
    return colorScheme.onSurface;
  }

  double _getFontSize() {
    if (widget.isSpecial) {
      final displayText = widget.displayText ?? widget.keyValue;
      return displayText.length > 3 ? 11 : 14;
    }
    
    return 16;
  }
}