import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/keyboard_layout.dart';

void main() {
  runApp(const CustomKeyboardApp());
}

class CustomKeyboardApp extends StatelessWidget {
  const CustomKeyboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Keyboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const KeyboardScreen(),
    );
  }
}

class KeyboardScreen extends StatefulWidget {
  const KeyboardScreen({super.key});

  @override
  State<KeyboardScreen> createState() => _KeyboardScreenState();
}

class _KeyboardScreenState extends State<KeyboardScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus for the text field to show keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    final currentText = _textController.text;
    final cursorPosition = _textController.selection.start;

    if (key == 'BACKSPACE') {
      if (cursorPosition > 0) {
        final newText = currentText.substring(0, cursorPosition - 1) +
            currentText.substring(cursorPosition);
        _textController.text = newText;
        _textController.selection = TextSelection.collapsed(
          offset: cursorPosition - 1,
        );
      }
    } else if (key == 'SPACE') {
      final newText = currentText.substring(0, cursorPosition) +
          ' ' +
          currentText.substring(cursorPosition);
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: cursorPosition + 1,
      );
    } else {
      final newText = currentText.substring(0, cursorPosition) +
          key +
          currentText.substring(cursorPosition);
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: cursorPosition + key.length,
      );
    }

    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Custom Keyboard Demo'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Text input area
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Start typing with the custom keyboard below...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(16),
                ),
                // Disable system keyboard
                showCursor: true,
                readOnly: false,
              ),
            ),
          ),
          // Custom keyboard
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: KeyboardLayout(onKeyPressed: _onKeyPressed),
            ),
          ),
        ],
      ),
    );
  }
}