import 'package:flutter/foundation.dart';
import '../services/preferences_service.dart';

enum KeyboardMode { letters, numbers, symbols }

class KeyboardStateModel extends ChangeNotifier {
  bool _isShiftPressed = false;
  bool _isCapsLockOn = false;
  KeyboardMode _currentMode = KeyboardMode.letters;
  String _currentLanguage = 'en';
  Map<String, dynamic> _inputInfo = {};
  
  // Getters
  bool get isShiftPressed => _isShiftPressed;
  bool get isCapsLockOn => _isCapsLockOn;
  KeyboardMode get currentMode => _currentMode;
  String get currentLanguage => _currentLanguage;
  Map<String, dynamic> get inputInfo => _inputInfo;
  
  // Derived getters
  bool get isUpperCase => _isShiftPressed || _isCapsLockOn;
  bool get isNumberMode => _currentMode == KeyboardMode.numbers;
  bool get isSymbolMode => _currentMode == KeyboardMode.symbols;
  bool get isLetterMode => _currentMode == KeyboardMode.letters;

  KeyboardStateModel() {
    _loadSettings();
  }

  void _loadSettings() {
    final prefs = PreferencesService.instance;
    _currentLanguage = prefs.currentLanguage;
  }

  // Shift functionality
  void toggleShift() {
    _isShiftPressed = !_isShiftPressed;
    notifyListeners();
  }

  void setShift(bool enabled) {
    if (_isShiftPressed != enabled) {
      _isShiftPressed = enabled;
      notifyListeners();
    }
  }

  void resetShift() {
    if (_isShiftPressed) {
      _isShiftPressed = false;
      notifyListeners();
    }
  }

  // Caps lock functionality
  void toggleCapsLock() {
    _isCapsLockOn = !_isCapsLockOn;
    // Reset shift when caps lock is toggled
    if (_isCapsLockOn) {
      _isShiftPressed = false;
    }
    notifyListeners();
  }

  void setCapsLock(bool enabled) {
    if (_isCapsLockOn != enabled) {
      _isCapsLockOn = enabled;
      if (enabled) {
        _isShiftPressed = false;
      }
      notifyListeners();
    }
  }

  // Keyboard mode switching
  void setMode(KeyboardMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      notifyListeners();
    }
  }

  void switchToLetters() => setMode(KeyboardMode.letters);
  void switchToNumbers() => setMode(KeyboardMode.numbers);
  void switchToSymbols() => setMode(KeyboardMode.symbols);

  void toggleNumbersSymbols() {
    if (_currentMode == KeyboardMode.numbers) {
      setMode(KeyboardMode.symbols);
    } else {
      setMode(KeyboardMode.numbers);
    }
  }

  // Language functionality
  Future<void> setLanguage(String language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      await PreferencesService.instance.setCurrentLanguage(language);
      notifyListeners();
    }
  }

  Future<void> switchToNextLanguage() async {
    final prefs = PreferencesService.instance;
    final enabledLanguages = prefs.enabledLanguages;
    
    if (enabledLanguages.length > 1) {
      final currentIndex = enabledLanguages.indexOf(_currentLanguage);
      final nextIndex = (currentIndex + 1) % enabledLanguages.length;
      await setLanguage(enabledLanguages[nextIndex]);
    }
  }

  // Input info (from Android InputMethodService)
  void updateInputInfo(Map<String, dynamic> info) {
    _inputInfo = Map.from(info);
    notifyListeners();
  }

  // Text processing
  String processKey(String key) {
    if (key.length == 1 && _isLetter(key)) {
      return isUpperCase ? key.toUpperCase() : key.toLowerCase();
    }
    return key;
  }

  bool _isLetter(String key) {
    return RegExp(r'^[a-zA-Z]$').hasMatch(key);
  }

  // Auto capitalization logic
  bool shouldAutoCapitalize(String beforeText) {
    final prefs = PreferencesService.instance;
    if (!prefs.autoCapitalize) return false;

    if (beforeText.isEmpty) return true; // Beginning of text
    
    // After sentence ending punctuation
    final sentenceEnders = RegExp(r'[.!?]\s*$');
    if (sentenceEnders.hasMatch(beforeText)) return true;
    
    // After newline
    if (beforeText.endsWith('\n')) return true;
    
    return false;
  }

  // Reset state
  void reset() {
    _isShiftPressed = false;
    _isCapsLockOn = false;
    _currentMode = KeyboardMode.letters;
    _inputInfo.clear();
    notifyListeners();
  }

  // State snapshot for debugging
  Map<String, dynamic> getStateSnapshot() {
    return {
      'isShiftPressed': _isShiftPressed,
      'isCapsLockOn': _isCapsLockOn,
      'currentMode': _currentMode.toString(),
      'currentLanguage': _currentLanguage,
      'inputInfo': _inputInfo,
    };
  }
}

// Language configuration
class LanguageConfig {
  final String code;
  final String name;
  final String displayName;
  final List<List<String>> layout;
  final Map<String, String> shiftMap;

  const LanguageConfig({
    required this.code,
    required this.name,
    required this.displayName,
    required this.layout,
    required this.shiftMap,
  });

  static const Map<String, LanguageConfig> languages = {
    'en': LanguageConfig(
      code: 'en',
      name: 'English',
      displayName: 'EN',
      layout: [
        ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
        ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
        ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
      ],
      shiftMap: {
        '1': '!', '2': '@', '3': '#', '4': '\$', '5': '%',
        '6': '^', '7': '&', '8': '*', '9': '(', '0': ')',
        '-': '_', '=': '+', '[': '{', ']': '}', '\\': '|',
        ';': ':', "'": '"', ',': '<', '.': '>', '/': '?',
      },
    ),
    'id': LanguageConfig(
      code: 'id',
      name: 'Indonesian',
      displayName: 'ID',
      layout: [
        ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
        ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
        ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
      ],
      shiftMap: {
        '1': '!', '2': '@', '3': '#', '4': '\$', '5': '%',
        '6': '^', '7': '&', '8': '*', '9': '(', '0': ')',
        '-': '_', '=': '+', '[': '{', ']': '}', '\\': '|',
        ';': ':', "'": '"', ',': '<', '.': '>', '/': '?',
      },
    ),
  };

  static LanguageConfig getConfig(String languageCode) {
    return languages[languageCode] ?? languages['en']!;
  }

  static List<String> get availableLanguages => languages.keys.toList();
}