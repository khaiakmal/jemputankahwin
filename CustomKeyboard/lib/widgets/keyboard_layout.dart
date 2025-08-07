import 'package:flutter/material.dart';
import 'key_widget.dart';

class KeyboardLayout extends StatefulWidget {
  final Function(String) onKeyPressed;

  const KeyboardLayout({
    super.key,
    required this.onKeyPressed,
  });

  @override
  State<KeyboardLayout> createState() => _KeyboardLayoutState();
}

class _KeyboardLayoutState extends State<KeyboardLayout> {
  bool _isShiftPressed = false;
  bool _isCapsLockOn = false;

  // Keyboard layout definitions
  final List<List<String>> _qwertyLayout = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
  ];

  final List<String> _numberRow = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

  final Map<String, String> _symbolMap = {
    '1': '!',
    '2': '@',
    '3': '#',
    '4': '\$',
    '5': '%',
    '6': '^',
    '7': '&',
    '8': '*',
    '9': '(',
    '0': ')',
  };

  final List<String> _specialSymbols = [',', '.', '?', '!', ';', ':'];

  void _handleKeyPress(String key) {
    String outputKey = key;

    if (key == 'SHIFT') {
      setState(() {
        _isShiftPressed = !_isShiftPressed;
      });
      return;
    }

    if (key == 'CAPS') {
      setState(() {
        _isCapsLockOn = !_isCapsLockOn;
      });
      return;
    }

    // Handle special keys
    if (key == 'BACKSPACE' || key == 'SPACE') {
      widget.onKeyPressed(key);
      return;
    }

    // Apply shift/caps logic
    if (_isLetter(key)) {
      if (_isShiftPressed || _isCapsLockOn) {
        outputKey = key.toUpperCase();
      } else {
        outputKey = key.toLowerCase();
      }
    } else if (_symbolMap.containsKey(key) && _isShiftPressed) {
      outputKey = _symbolMap[key]!;
    }

    widget.onKeyPressed(outputKey);

    // Reset shift after key press (but not caps lock)
    if (_isShiftPressed) {
      setState(() {
        _isShiftPressed = false;
      });
    }
  }

  bool _isLetter(String key) {
    return RegExp(r'^[a-zA-Z]$').hasMatch(key);
  }

  Widget _buildKeyRow(List<String> keys, {double? keyWidth}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        return Expanded(
          child: KeyWidget(
            keyValue: key,
            displayText: _getDisplayText(key),
            onPressed: () => _handleKeyPress(key),
            height: 50,
          ),
        );
      }).toList(),
    );
  }

  String _getDisplayText(String key) {
    if (_isLetter(key)) {
      return (_isShiftPressed || _isCapsLockOn) ? key.toUpperCase() : key.toLowerCase();
    } else if (_symbolMap.containsKey(key) && _isShiftPressed) {
      return _symbolMap[key]!;
    }
    return key;
  }

  Widget _buildNumberRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _numberRow.map((number) {
        return Expanded(
          child: KeyWidget(
            keyValue: number,
            displayText: _isShiftPressed && _symbolMap.containsKey(number)
                ? _symbolMap[number]!
                : number,
            onPressed: () => _handleKeyPress(number),
            height: 45,
            fontSize: 14,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopRow() {
    return _buildKeyRow(_qwertyLayout[0]);
  }

  Widget _buildMiddleRow() {
    return Row(
      children: [
        // Small padding on left
        const SizedBox(width: 20),
        // Keys
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _qwertyLayout[1].map((key) {
              return Expanded(
                child: KeyWidget(
                  keyValue: key,
                  displayText: _getDisplayText(key),
                  onPressed: () => _handleKeyPress(key),
                  height: 50,
                ),
              );
            }).toList(),
          ),
        ),
        // Small padding on right
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        // Shift key
        KeyWidget(
          keyValue: 'SHIFT',
          displayText: 'Shift',
          onPressed: () => _handleKeyPress('SHIFT'),
          width: 60,
          height: 50,
          isSpecialKey: true,
          backgroundColor: _isShiftPressed 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : null,
          fontSize: 12,
        ),
        // Letter keys
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _qwertyLayout[2].map((key) {
              return Expanded(
                child: KeyWidget(
                  keyValue: key,
                  displayText: _getDisplayText(key),
                  onPressed: () => _handleKeyPress(key),
                  height: 50,
                ),
              );
            }).toList(),
          ),
        ),
        // Backspace key
        KeyWidget(
          keyValue: 'BACKSPACE',
          icon: Icons.backspace_outlined,
          onPressed: () => _handleKeyPress('BACKSPACE'),
          width: 60,
          height: 50,
          isSpecialKey: true,
        ),
      ],
    );
  }

  Widget _buildSpaceRow() {
    return Row(
      children: [
        // Numbers/Symbols key (placeholder for future expansion)
        KeyWidget(
          keyValue: '123',
          displayText: '123',
          onPressed: () {
            // Placeholder for number mode toggle
          },
          width: 60,
          height: 45,
          isSpecialKey: true,
          fontSize: 12,
        ),
        const SizedBox(width: 8),
        // Comma
        KeyWidget(
          keyValue: ',',
          onPressed: () => _handleKeyPress(','),
          width: 40,
          height: 45,
        ),
        const SizedBox(width: 8),
        // Spacebar
        Expanded(
          flex: 3,
          child: SpacebarWidget(
            onPressed: () => _handleKeyPress('SPACE'),
            height: 45,
          ),
        ),
        const SizedBox(width: 8),
        // Period
        KeyWidget(
          keyValue: '.',
          onPressed: () => _handleKeyPress('.'),
          width: 40,
          height: 45,
        ),
        const SizedBox(width: 8),
        // Enter/Return key
        KeyWidget(
          keyValue: 'ENTER',
          icon: Icons.keyboard_return,
          onPressed: () => _handleKeyPress('\n'),
          width: 60,
          height: 45,
          isSpecialKey: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Number row
          _buildNumberRow(),
          const SizedBox(height: 6),
          
          // First letter row (QWERTY)
          _buildTopRow(),
          const SizedBox(height: 6),
          
          // Second letter row (ASDF)
          _buildMiddleRow(),
          const SizedBox(height: 6),
          
          // Third letter row (ZXCV) with Shift and Backspace
          _buildBottomRow(),
          const SizedBox(height: 6),
          
          // Space bar row with special keys
          _buildSpaceRow(),
          
          // Extra padding at bottom
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}