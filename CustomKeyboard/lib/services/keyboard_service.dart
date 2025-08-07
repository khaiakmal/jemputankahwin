import 'package:flutter/services.dart';

class KeyboardService {
  static final KeyboardService _instance = KeyboardService._internal();
  factory KeyboardService() => _instance;
  KeyboardService._internal();

  // Callback for handling text input changes
  Function(String)? _onTextChanged;
  Function(String)? _onKeyPressed;

  String _currentText = '';
  int _cursorPosition = 0;

  // Getters
  String get currentText => _currentText;
  int get cursorPosition => _cursorPosition;

  /// Initialize the keyboard service with callbacks
  void initialize({
    Function(String)? onTextChanged,
    Function(String)? onKeyPressed,
  }) {
    _onTextChanged = onTextChanged;
    _onKeyPressed = onKeyPressed;
  }

  /// Handle key press events from the keyboard
  void handleKeyPress(String key) {
    _onKeyPressed?.call(key);

    switch (key) {
      case 'BACKSPACE':
        _handleBackspace();
        break;
      case 'SPACE':
        _insertText(' ');
        break;
      case 'ENTER':
        _insertText('\n');
        break;
      default:
        _insertText(key);
        break;
    }

    _onTextChanged?.call(_currentText);
    _triggerHapticFeedback();
  }

  /// Insert text at the current cursor position
  void _insertText(String text) {
    final beforeCursor = _currentText.substring(0, _cursorPosition);
    final afterCursor = _currentText.substring(_cursorPosition);
    
    _currentText = beforeCursor + text + afterCursor;
    _cursorPosition += text.length;
  }

  /// Handle backspace key press
  void _handleBackspace() {
    if (_cursorPosition > 0) {
      final beforeCursor = _currentText.substring(0, _cursorPosition - 1);
      final afterCursor = _currentText.substring(_cursorPosition);
      
      _currentText = beforeCursor + afterCursor;
      _cursorPosition--;
    }
  }

  /// Set cursor position (for external text field updates)
  void setCursorPosition(int position) {
    _cursorPosition = position.clamp(0, _currentText.length);
  }

  /// Update the current text (for external text field updates)
  void updateText(String newText, {int? newCursorPosition}) {
    _currentText = newText;
    _cursorPosition = newCursorPosition ?? _currentText.length;
  }

  /// Clear all text
  void clearText() {
    _currentText = '';
    _cursorPosition = 0;
    _onTextChanged?.call(_currentText);
  }

  /// Insert text at a specific position
  void insertTextAtPosition(String text, int position) {
    final clampedPosition = position.clamp(0, _currentText.length);
    final beforePosition = _currentText.substring(0, clampedPosition);
    final afterPosition = _currentText.substring(clampedPosition);
    
    _currentText = beforePosition + text + afterPosition;
    _cursorPosition = clampedPosition + text.length;
    _onTextChanged?.call(_currentText);
  }

  /// Delete text in a range
  void deleteTextRange(int start, int end) {
    final clampedStart = start.clamp(0, _currentText.length);
    final clampedEnd = end.clamp(clampedStart, _currentText.length);
    
    final beforeRange = _currentText.substring(0, clampedStart);
    final afterRange = _currentText.substring(clampedEnd);
    
    _currentText = beforeRange + afterRange;
    _cursorPosition = clampedStart;
    _onTextChanged?.call(_currentText);
  }

  /// Get text selection (for future text selection features)
  TextSelection getSelection() {
    return TextSelection.collapsed(offset: _cursorPosition);
  }

  /// Trigger haptic feedback
  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  /// Dispose of the service (cleanup)
  void dispose() {
    _onTextChanged = null;
    _onKeyPressed = null;
    _currentText = '';
    _cursorPosition = 0;
  }
}

/// Keyboard state management
class KeyboardState {
  bool isShiftPressed;
  bool isCapsLockOn;
  bool isNumberMode;
  bool isSymbolMode;
  String currentLanguage;

  KeyboardState({
    this.isShiftPressed = false,
    this.isCapsLockOn = false,
    this.isNumberMode = false,
    this.isSymbolMode = false,
    this.currentLanguage = 'en',
  });

  /// Toggle shift state
  void toggleShift() {
    isShiftPressed = !isShiftPressed;
  }

  /// Toggle caps lock state
  void toggleCapsLock() {
    isCapsLockOn = !isCapsLockOn;
  }

  /// Toggle number mode
  void toggleNumberMode() {
    isNumberMode = !isNumberMode;
    if (isNumberMode) {
      isSymbolMode = false;
    }
  }

  /// Toggle symbol mode
  void toggleSymbolMode() {
    isSymbolMode = !isSymbolMode;
    if (isSymbolMode) {
      isNumberMode = false;
    }
  }

  /// Set language
  void setLanguage(String language) {
    currentLanguage = language;
  }

  /// Reset to default state
  void reset() {
    isShiftPressed = false;
    isCapsLockOn = false;
    isNumberMode = false;
    isSymbolMode = false;
    currentLanguage = 'en';
  }

  /// Copy current state
  KeyboardState copy() {
    return KeyboardState(
      isShiftPressed: isShiftPressed,
      isCapsLockOn: isCapsLockOn,
      isNumberMode: isNumberMode,
      isSymbolMode: isSymbolMode,
      currentLanguage: currentLanguage,
    );
  }
}

/// Text processing utilities
class TextProcessor {
  /// Apply text transformations based on keyboard state
  static String processText(String input, KeyboardState state) {
    if (input.isEmpty) return input;

    // Handle letter case
    if (_isLetter(input)) {
      if (state.isShiftPressed || state.isCapsLockOn) {
        return input.toUpperCase();
      } else {
        return input.toLowerCase();
      }
    }

    return input;
  }

  /// Check if the input is a letter
  static bool _isLetter(String input) {
    return RegExp(r'^[a-zA-Z]$').hasMatch(input);
  }

  /// Check if the input is a number
  static bool isNumber(String input) {
    return RegExp(r'^[0-9]$').hasMatch(input);
  }

  /// Check if the input is a symbol
  static bool isSymbol(String input) {
    return RegExp(r'^[!@#\$%^&*()_+\-=\[\]{};:"\\|,.<>?/~`]$').hasMatch(input);
  }

  /// Get word boundaries for text selection
  static List<int> getWordBoundaries(String text, int position) {
    if (text.isEmpty) return [0, 0];

    int start = position;
    int end = position;

    // Find word start
    while (start > 0 && !_isWordBoundary(text[start - 1])) {
      start--;
    }

    // Find word end
    while (end < text.length && !_isWordBoundary(text[end])) {
      end++;
    }

    return [start, end];
  }

  /// Check if character is a word boundary
  static bool _isWordBoundary(String char) {
    return RegExp(r'\s').hasMatch(char);
  }
}