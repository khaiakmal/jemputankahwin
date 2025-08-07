import 'package:flutter/services.dart';

class KeyboardPlatformService {
  static const MethodChannel _channel = 
      MethodChannel('com.example.flutter_keyboard_ime/keyboard');
  
  static KeyboardPlatformService? _instance;
  
  static KeyboardPlatformService get instance {
    _instance ??= KeyboardPlatformService._();
    return _instance!;
  }
  
  KeyboardPlatformService._() {
    _setupMethodCallHandler();
  }

  // Callbacks for keyboard events
  Function(Map<String, dynamic>)? onStartInputView;
  Function(bool)? onFinishInputView;
  Function(Map<String, dynamic>)? onUpdateSelection;

  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onStartInputView':
          onStartInputView?.call(Map<String, dynamic>.from(call.arguments));
          break;
        case 'onFinishInputView':
          onFinishInputView?.call(call.arguments as bool);
          break;
        case 'onUpdateSelection':
          onUpdateSelection?.call(Map<String, dynamic>.from(call.arguments));
          break;
      }
    });
  }

  /// Commit text to the current input field
  Future<bool> commitText(String text) async {
    try {
      final result = await _channel.invokeMethod('commitText', {
        'text': text,
      });
      return result as bool? ?? false;
    } catch (e) {
      print('Error committing text: $e');
      return false;
    }
  }

  /// Delete surrounding text
  Future<bool> deleteSurroundingText({int beforeLength = 1, int afterLength = 0}) async {
    try {
      final result = await _channel.invokeMethod('deleteSurroundingText', {
        'beforeLength': beforeLength,
        'afterLength': afterLength,
      });
      return result as bool? ?? false;
    } catch (e) {
      print('Error deleting surrounding text: $e');
      return false;
    }
  }

  /// Finish composing text
  Future<bool> finishComposingText() async {
    try {
      final result = await _channel.invokeMethod('finishComposingText');
      return result as bool? ?? false;
    } catch (e) {
      print('Error finishing composing text: $e');
      return false;
    }
  }

  /// Set composing text
  Future<bool> setComposingText(String text, {int newCursorPosition = 1}) async {
    try {
      final result = await _channel.invokeMethod('setComposingText', {
        'text': text,
        'newCursorPosition': newCursorPosition,
      });
      return result as bool? ?? false;
    } catch (e) {
      print('Error setting composing text: $e');
      return false;
    }
  }

  /// Send key event
  Future<bool> sendKeyEvent(int keyCode) async {
    try {
      final result = await _channel.invokeMethod('sendKeyEvent', {
        'keyCode': keyCode,
      });
      return result as bool? ?? false;
    } catch (e) {
      print('Error sending key event: $e');
      return false;
    }
  }

  /// Get selected text
  Future<String> getSelectedText({int flags = 0}) async {
    try {
      final result = await _channel.invokeMethod('getSelectedText', {
        'flags': flags,
      });
      return result as String? ?? '';
    } catch (e) {
      print('Error getting selected text: $e');
      return '';
    }
  }

  /// Get text before cursor
  Future<String> getTextBeforeCursor({int length = 100, int flags = 0}) async {
    try {
      final result = await _channel.invokeMethod('getTextBeforeCursor', {
        'length': length,
        'flags': flags,
      });
      return result as String? ?? '';
    } catch (e) {
      print('Error getting text before cursor: $e');
      return '';
    }
  }

  /// Get text after cursor
  Future<String> getTextAfterCursor({int length = 100, int flags = 0}) async {
    try {
      final result = await _channel.invokeMethod('getTextAfterCursor', {
        'length': length,
        'flags': flags,
      });
      return result as String? ?? '';
    } catch (e) {
      print('Error getting text after cursor: $e');
      return '';
    }
  }

  /// Hide keyboard
  Future<bool> hideKeyboard() async {
    try {
      final result = await _channel.invokeMethod('hideKeyboard');
      return result as bool? ?? false;
    } catch (e) {
      print('Error hiding keyboard: $e');
      return false;
    }
  }

  /// Helper method to handle backspace
  Future<bool> handleBackspace() async {
    final selectedText = await getSelectedText();
    if (selectedText.isNotEmpty) {
      // Delete selected text
      return await commitText('');
    } else {
      // Delete one character before cursor
      return await deleteSurroundingText();
    }
  }

  /// Helper method to handle enter/return
  Future<bool> handleEnter() async {
    return await commitText('\n');
  }

  /// Helper method to handle space
  Future<bool> handleSpace() async {
    return await commitText(' ');
  }

  /// Helper method to handle tab
  Future<bool> handleTab() async {
    return await commitText('\t');
  }
}