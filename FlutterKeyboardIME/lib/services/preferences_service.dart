import 'package:shared_preferences.dart';

class PreferencesService {
  static PreferencesService? _instance;
  static SharedPreferences? _prefs;

  static PreferencesService get instance {
    _instance ??= PreferencesService._();
    return _instance!;
  }

  PreferencesService._();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Keyboard Theme Settings
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyKeyboardHeight = 'keyboard_height';
  static const String _keyKeySound = 'key_sound';
  static const String _keyHapticFeedback = 'haptic_feedback';
  static const String _keyKeyPreview = 'key_preview';

  // Language Settings
  static const String _keyCurrentLanguage = 'current_language';
  static const String _keyEnabledLanguages = 'enabled_languages';

  // Input Settings
  static const String _keyAutoCapitalize = 'auto_capitalize';
  static const String _keyAutoCorrect = 'auto_correct';
  static const String _keyWordSuggestions = 'word_suggestions';
  static const String _keySwipeToDelete = 'swipe_to_delete';

  // Advanced Settings
  static const String _keyNumberRowVisible = 'number_row_visible';
  static const String _keyLongPressDelay = 'long_press_delay';
  static const String _keyKeyRepeatRate = 'key_repeat_rate';

  // Theme Mode (light, dark, system)
  String get themeMode => _prefs?.getString(_keyThemeMode) ?? 'system';
  Future<bool> setThemeMode(String mode) async {
    return await _prefs?.setString(_keyThemeMode, mode) ?? false;
  }

  // Keyboard Height (percentage of screen)
  double get keyboardHeight => _prefs?.getDouble(_keyKeyboardHeight) ?? 0.35;
  Future<bool> setKeyboardHeight(double height) async {
    return await _prefs?.setDouble(_keyKeyboardHeight, height) ?? false;
  }

  // Key Sound
  bool get keySound => _prefs?.getBool(_keyKeySound) ?? true;
  Future<bool> setKeySound(bool enabled) async {
    return await _prefs?.setBool(_keyKeySound, enabled) ?? false;
  }

  // Haptic Feedback
  bool get hapticFeedback => _prefs?.getBool(_keyHapticFeedback) ?? true;
  Future<bool> setHapticFeedback(bool enabled) async {
    return await _prefs?.setBool(_keyHapticFeedback, enabled) ?? false;
  }

  // Key Preview (popup when pressed)
  bool get keyPreview => _prefs?.getBool(_keyKeyPreview) ?? true;
  Future<bool> setKeyPreview(bool enabled) async {
    return await _prefs?.setBool(_keyKeyPreview, enabled) ?? false;
  }

  // Current Language
  String get currentLanguage => _prefs?.getString(_keyCurrentLanguage) ?? 'en';
  Future<bool> setCurrentLanguage(String language) async {
    return await _prefs?.setString(_keyCurrentLanguage, language) ?? false;
  }

  // Enabled Languages
  List<String> get enabledLanguages => 
      _prefs?.getStringList(_keyEnabledLanguages) ?? ['en'];
  Future<bool> setEnabledLanguages(List<String> languages) async {
    return await _prefs?.setStringList(_keyEnabledLanguages, languages) ?? false;
  }
  Future<bool> addLanguage(String language) async {
    final current = enabledLanguages;
    if (!current.contains(language)) {
      current.add(language);
      return await setEnabledLanguages(current);
    }
    return true;
  }
  Future<bool> removeLanguage(String language) async {
    final current = enabledLanguages;
    current.remove(language);
    if (current.isEmpty) current.add('en'); // Ensure at least one language
    return await setEnabledLanguages(current);
  }

  // Auto Capitalize
  bool get autoCapitalize => _prefs?.getBool(_keyAutoCapitalize) ?? true;
  Future<bool> setAutoCapitalize(bool enabled) async {
    return await _prefs?.setBool(_keyAutoCapitalize, enabled) ?? false;
  }

  // Auto Correct
  bool get autoCorrect => _prefs?.getBool(_keyAutoCorrect) ?? true;
  Future<bool> setAutoCorrect(bool enabled) async {
    return await _prefs?.setBool(_keyAutoCorrect, enabled) ?? false;
  }

  // Word Suggestions
  bool get wordSuggestions => _prefs?.getBool(_keyWordSuggestions) ?? true;
  Future<bool> setWordSuggestions(bool enabled) async {
    return await _prefs?.setBool(_keyWordSuggestions, enabled) ?? false;
  }

  // Swipe to Delete
  bool get swipeToDelete => _prefs?.getBool(_keySwipeToDelete) ?? true;
  Future<bool> setSwipeToDelete(bool enabled) async {
    return await _prefs?.setBool(_keySwipeToDelete, enabled) ?? false;
  }

  // Number Row Visible
  bool get numberRowVisible => _prefs?.getBool(_keyNumberRowVisible) ?? true;
  Future<bool> setNumberRowVisible(bool visible) async {
    return await _prefs?.setBool(_keyNumberRowVisible, visible) ?? false;
  }

  // Long Press Delay (in milliseconds)
  int get longPressDelay => _prefs?.getInt(_keyLongPressDelay) ?? 500;
  Future<bool> setLongPressDelay(int delay) async {
    return await _prefs?.setInt(_keyLongPressDelay, delay) ?? false;
  }

  // Key Repeat Rate (keys per second)
  int get keyRepeatRate => _prefs?.getInt(_keyKeyRepeatRate) ?? 5;
  Future<bool> setKeyRepeatRate(int rate) async {
    return await _prefs?.setInt(_keyKeyRepeatRate, rate) ?? false;
  }

  // Reset to defaults
  Future<bool> resetToDefaults() async {
    try {
      await _prefs?.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Export settings
  Map<String, dynamic> exportSettings() {
    return {
      'theme_mode': themeMode,
      'keyboard_height': keyboardHeight,
      'key_sound': keySound,
      'haptic_feedback': hapticFeedback,
      'key_preview': keyPreview,
      'current_language': currentLanguage,
      'enabled_languages': enabledLanguages,
      'auto_capitalize': autoCapitalize,
      'auto_correct': autoCorrect,
      'word_suggestions': wordSuggestions,
      'swipe_to_delete': swipeToDelete,
      'number_row_visible': numberRowVisible,
      'long_press_delay': longPressDelay,
      'key_repeat_rate': keyRepeatRate,
    };
  }

  // Import settings
  Future<bool> importSettings(Map<String, dynamic> settings) async {
    try {
      if (settings.containsKey('theme_mode')) {
        await setThemeMode(settings['theme_mode']);
      }
      if (settings.containsKey('keyboard_height')) {
        await setKeyboardHeight(settings['keyboard_height']);
      }
      if (settings.containsKey('key_sound')) {
        await setKeySound(settings['key_sound']);
      }
      if (settings.containsKey('haptic_feedback')) {
        await setHapticFeedback(settings['haptic_feedback']);
      }
      if (settings.containsKey('key_preview')) {
        await setKeyPreview(settings['key_preview']);
      }
      if (settings.containsKey('current_language')) {
        await setCurrentLanguage(settings['current_language']);
      }
      if (settings.containsKey('enabled_languages')) {
        await setEnabledLanguages(List<String>.from(settings['enabled_languages']));
      }
      if (settings.containsKey('auto_capitalize')) {
        await setAutoCapitalize(settings['auto_capitalize']);
      }
      if (settings.containsKey('auto_correct')) {
        await setAutoCorrect(settings['auto_correct']);
      }
      if (settings.containsKey('word_suggestions')) {
        await setWordSuggestions(settings['word_suggestions']);
      }
      if (settings.containsKey('swipe_to_delete')) {
        await setSwipeToDelete(settings['swipe_to_delete']);
      }
      if (settings.containsKey('number_row_visible')) {
        await setNumberRowVisible(settings['number_row_visible']);
      }
      if (settings.containsKey('long_press_delay')) {
        await setLongPressDelay(settings['long_press_delay']);
      }
      if (settings.containsKey('key_repeat_rate')) {
        await setKeyRepeatRate(settings['key_repeat_rate']);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}