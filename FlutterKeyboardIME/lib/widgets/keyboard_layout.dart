import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/keyboard_state.dart';
import 'keyboard_key.dart';

class KeyboardLayout extends StatelessWidget {
  final Function(String) onKeyPressed;

  const KeyboardLayout({
    super.key,
    required this.onKeyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<KeyboardStateModel>(
      builder: (context, keyboardState, child) {
        switch (keyboardState.currentMode) {
          case KeyboardMode.letters:
            return _buildLetterLayout(context, keyboardState);
          case KeyboardMode.numbers:
            return _buildNumberLayout(context, keyboardState);
          case KeyboardMode.symbols:
            return _buildSymbolLayout(context, keyboardState);
        }
      },
    );
  }

  Widget _buildLetterLayout(BuildContext context, KeyboardStateModel state) {
    final languageConfig = LanguageConfig.getConfig(state.currentLanguage);
    
    return Column(
      children: [
        // First row: Q W E R T Y U I O P
        Expanded(
          child: _buildKeyRow(
            context,
            languageConfig.layout[0],
            state,
          ),
        ),
        
        // Second row: A S D F G H J K L
        Expanded(
          child: _buildKeyRow(
            context,
            languageConfig.layout[1],
            state,
            leftPadding: 24,
            rightPadding: 24,
          ),
        ),
        
        // Third row: Shift Z X C V B N M Backspace
        Expanded(
          child: Row(
            children: [
              // Shift key
              KeyboardKey(
                keyValue: 'SHIFT',
                displayText: state.isCapsLockOn ? 'CAPS' : '⇧',
                onPressed: () => onKeyPressed('SHIFT'),
                flex: 2,
                isSpecial: true,
                isPressed: state.isShiftPressed || state.isCapsLockOn,
                onLongPress: () => onKeyPressed('CAPS_LOCK'),
              ),
              
              // Letter keys
              ...languageConfig.layout[2].map((key) {
                final displayKey = state.processKey(key);
                return KeyboardKey(
                  keyValue: key,
                  displayText: displayKey,
                  onPressed: () => onKeyPressed(key),
                  flex: 1,
                );
              }),
              
              // Backspace key
              KeyboardKey(
                keyValue: 'BACKSPACE',
                icon: Icons.backspace_outlined,
                onPressed: () => onKeyPressed('BACKSPACE'),
                flex: 2,
                isSpecial: true,
              ),
            ],
          ),
        ),
        
        // Fourth row: Numbers, comma, space, period, enter
        Expanded(
          child: Row(
            children: [
              // Switch to numbers
              KeyboardKey(
                keyValue: 'SWITCH_TO_NUMBERS',
                displayText: '123',
                onPressed: () => onKeyPressed('SWITCH_TO_NUMBERS'),
                flex: 2,
                isSpecial: true,
              ),
              
              // Comma
              KeyboardKey(
                keyValue: ',',
                onPressed: () => onKeyPressed(','),
                flex: 1,
              ),
              
              // Space bar
              KeyboardKey(
                keyValue: 'SPACE',
                displayText: '',
                onPressed: () => onKeyPressed('SPACE'),
                flex: 5,
                isSpacebar: true,
              ),
              
              // Period
              KeyboardKey(
                keyValue: '.',
                onPressed: () => onKeyPressed('.'),
                flex: 1,
              ),
              
              // Enter key
              KeyboardKey(
                keyValue: 'ENTER',
                icon: Icons.keyboard_return,
                onPressed: () => onKeyPressed('ENTER'),
                flex: 2,
                isSpecial: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberLayout(BuildContext context, KeyboardStateModel state) {
    final numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    final symbols1 = ['-', '/', ':', ';', '(', ')', '\$', '&', '@', '"'];
    final symbols2 = ['.', ',', '?', '!', "'", '"', '-', '_', ';', '+'];
    
    return Column(
      children: [
        // First row: 1 2 3 4 5 6 7 8 9 0
        Expanded(
          child: _buildKeyRow(context, numbers, state),
        ),
        
        // Second row: - / : ; ( ) $ & @ "
        Expanded(
          child: _buildKeyRow(context, symbols1, state),
        ),
        
        // Third row: Shift . , ? ! ' " - _ ; +
        Expanded(
          child: Row(
            children: [
              // Symbols switch
              KeyboardKey(
                keyValue: 'SWITCH_TO_SYMBOLS',
                displayText: '#+',
                onPressed: () => onKeyPressed('SWITCH_TO_SYMBOLS'),
                flex: 2,
                isSpecial: true,
              ),
              
              // Symbol keys
              ...symbols2.take(7).map((key) {
                return KeyboardKey(
                  keyValue: key,
                  onPressed: () => onKeyPressed(key),
                  flex: 1,
                );
              }),
              
              // Backspace
              KeyboardKey(
                keyValue: 'BACKSPACE',
                icon: Icons.backspace_outlined,
                onPressed: () => onKeyPressed('BACKSPACE'),
                flex: 2,
                isSpecial: true,
              ),
            ],
          ),
        ),
        
        // Fourth row: ABC, comma, space, period, enter
        Expanded(
          child: Row(
            children: [
              // Switch to letters
              KeyboardKey(
                keyValue: 'SWITCH_TO_LETTERS',
                displayText: 'ABC',
                onPressed: () => onKeyPressed('SWITCH_TO_LETTERS'),
                flex: 2,
                isSpecial: true,
              ),
              
              // Comma
              KeyboardKey(
                keyValue: ',',
                onPressed: () => onKeyPressed(','),
                flex: 1,
              ),
              
              // Space bar
              KeyboardKey(
                keyValue: 'SPACE',
                displayText: '',
                onPressed: () => onKeyPressed('SPACE'),
                flex: 5,
                isSpacebar: true,
              ),
              
              // Period
              KeyboardKey(
                keyValue: '.',
                onPressed: () => onKeyPressed('.'),
                flex: 1,
              ),
              
              // Enter key
              KeyboardKey(
                keyValue: 'ENTER',
                icon: Icons.keyboard_return,
                onPressed: () => onKeyPressed('ENTER'),
                flex: 2,
                isSpecial: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSymbolLayout(BuildContext context, KeyboardStateModel state) {
    final symbols1 = ['[', ']', '{', '}', '#', '%', '^', '*', '+', '='];
    final symbols2 = ['_', '\\', '|', '~', '<', '>', '€', '£', '¥', '•'];
    final symbols3 = ['.', ',', '?', '!', "'"];
    
    return Column(
      children: [
        // First row: [ ] { } # % ^ * + =
        Expanded(
          child: _buildKeyRow(context, symbols1, state),
        ),
        
        // Second row: _ \ | ~ < > € £ ¥ •
        Expanded(
          child: _buildKeyRow(context, symbols2, state),
        ),
        
        // Third row: Numbers . , ? ! '
        Expanded(
          child: Row(
            children: [
              // Numbers switch
              KeyboardKey(
                keyValue: 'SWITCH_TO_NUMBERS',
                displayText: '123',
                onPressed: () => onKeyPressed('SWITCH_TO_NUMBERS'),
                flex: 2,
                isSpecial: true,
              ),
              
              // Symbol keys
              ...symbols3.map((key) {
                return KeyboardKey(
                  keyValue: key,
                  onPressed: () => onKeyPressed(key),
                  flex: 1,
                );
              }),
              
              // Fill remaining space
              const Spacer(flex: 3),
              
              // Backspace
              KeyboardKey(
                keyValue: 'BACKSPACE',
                icon: Icons.backspace_outlined,
                onPressed: () => onKeyPressed('BACKSPACE'),
                flex: 2,
                isSpecial: true,
              ),
            ],
          ),
        ),
        
        // Fourth row: ABC, comma, space, period, enter
        Expanded(
          child: Row(
            children: [
              // Switch to letters
              KeyboardKey(
                keyValue: 'SWITCH_TO_LETTERS',
                displayText: 'ABC',
                onPressed: () => onKeyPressed('SWITCH_TO_LETTERS'),
                flex: 2,
                isSpecial: true,
              ),
              
              // Comma
              KeyboardKey(
                keyValue: ',',
                onPressed: () => onKeyPressed(','),
                flex: 1,
              ),
              
              // Space bar
              KeyboardKey(
                keyValue: 'SPACE',
                displayText: '',
                onPressed: () => onKeyPressed('SPACE'),
                flex: 5,
                isSpacebar: true,
              ),
              
              // Period
              KeyboardKey(
                keyValue: '.',
                onPressed: () => onKeyPressed('.'),
                flex: 1,
              ),
              
              // Enter key
              KeyboardKey(
                keyValue: 'ENTER',
                icon: Icons.keyboard_return,
                onPressed: () => onKeyPressed('ENTER'),
                flex: 2,
                isSpecial: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyRow(
    BuildContext context,
    List<String> keys,
    KeyboardStateModel state, {
    double leftPadding = 0,
    double rightPadding = 0,
  }) {
    return Row(
      children: [
        if (leftPadding > 0) SizedBox(width: leftPadding),
        ...keys.map((key) {
          String displayKey = key;
          
          // Apply shift/caps logic for letters
          if (state.isLetterMode && key.length == 1 && RegExp(r'[a-z]').hasMatch(key)) {
            displayKey = state.processKey(key);
          }
          
          // Apply shift logic for numbers (to show symbols)
          if (state.isNumberMode && state.isShiftPressed) {
            final languageConfig = LanguageConfig.getConfig(state.currentLanguage);
            displayKey = languageConfig.shiftMap[key] ?? key;
          }
          
          return KeyboardKey(
            keyValue: key,
            displayText: displayKey,
            onPressed: () => onKeyPressed(key),
            flex: 1,
          );
        }),
        if (rightPadding > 0) SizedBox(width: rightPadding),
      ],
    );
  }
}