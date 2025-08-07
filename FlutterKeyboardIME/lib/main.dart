import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/preferences_service.dart';
import 'services/keyboard_platform_service.dart';
import 'widgets/keyboard_view.dart';
import 'models/keyboard_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize preferences
  await PreferencesService.instance.init();
  
  runApp(const KeyboardApp());
}

class KeyboardApp extends StatelessWidget {
  const KeyboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KeyboardStateModel()),
      ],
      child: Consumer<KeyboardStateModel>(
        builder: (context, keyboardState, child) {
          return MaterialApp(
            title: 'Flutter Keyboard IME',
            debugShowCheckedModeBanner: false,
            theme: _getTheme(false),
            darkTheme: _getTheme(true),
            themeMode: _getThemeMode(),
            home: const KeyboardView(),
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode() {
    final prefs = PreferencesService.instance;
    switch (prefs.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ThemeData _getTheme(bool isDark) {
    final colorScheme = isDark
        ? const ColorScheme.dark(
            primary: Color(0xFF4285F4),
            secondary: Color(0xFF34A853),
            surface: Color(0xFF1F1F1F),
            background: Color(0xFF121212),
            onSurface: Color(0xFFE0E0E0),
            onBackground: Color(0xFFE0E0E0),
          )
        : const ColorScheme.light(
            primary: Color(0xFF4285F4),
            secondary: Color(0xFF34A853),
            surface: Color(0xFFF5F5F5),
            background: Color(0xFFFFFFFF),
            onSurface: Color(0xFF1F1F1F),
            onBackground: Color(0xFF1F1F1F),
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'KeyboardFont',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}