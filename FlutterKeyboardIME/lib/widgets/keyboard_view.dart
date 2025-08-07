import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/keyboard_state.dart';
import '../services/keyboard_platform_service.dart';
import '../services/preferences_service.dart';
import 'keyboard_layout.dart';
import 'language_selector.dart';

class KeyboardView extends StatefulWidget {
  const KeyboardView({super.key});

  @override
  State<KeyboardView> createState() => _KeyboardViewState();
}

class _KeyboardViewState extends State<KeyboardView>
    with TickerProviderStateMixin {
  late KeyboardPlatformService _platformService;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _platformService = KeyboardPlatformService.instance;
    _initializeAnimations();
    _setupPlatformCallbacks();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start entrance animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
  }

  void _setupPlatformCallbacks() {
    final keyboardState = context.read<KeyboardStateModel>();
    
    _platformService.onStartInputView = (inputInfo) {
      keyboardState.updateInputInfo(inputInfo);
      _slideController.forward();
    };

    _platformService.onFinishInputView = (finishingInput) {
      if (finishingInput) {
        _slideController.reverse();
      }
    };

    _platformService.onUpdateSelection = (selectionInfo) {
      // Handle text selection updates if needed
    };
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleKeyPress(String key) async {
    final keyboardState = context.read<KeyboardStateModel>();
    final prefs = PreferencesService.instance;

    // Provide haptic feedback
    if (prefs.hapticFeedback) {
      HapticFeedback.lightImpact();
    }

    // Handle special keys
    switch (key) {
      case 'BACKSPACE':
        await _platformService.handleBackspace();
        break;
      
      case 'SPACE':
        await _platformService.handleSpace();
        // Auto-capitalize after space if at sentence beginning
        _checkAutoCapitalization();
        break;
      
      case 'ENTER':
        await _platformService.handleEnter();
        // Auto-capitalize after new line
        _checkAutoCapitalization();
        break;
      
      case 'SHIFT':
        keyboardState.toggleShift();
        break;
      
      case 'CAPS_LOCK':
        keyboardState.toggleCapsLock();
        break;
      
      case 'SWITCH_LANGUAGE':
        await keyboardState.switchToNextLanguage();
        break;
      
      case 'SWITCH_TO_NUMBERS':
        keyboardState.switchToNumbers();
        break;
      
      case 'SWITCH_TO_SYMBOLS':
        keyboardState.switchToSymbols();
        break;
      
      case 'SWITCH_TO_LETTERS':
        keyboardState.switchToLetters();
        break;
      
      case 'HIDE_KEYBOARD':
        await _platformService.hideKeyboard();
        break;
      
      default:
        // Regular character input
        final processedKey = keyboardState.processKey(key);
        await _platformService.commitText(processedKey);
        
        // Reset shift after character input (unless caps lock is on)
        if (keyboardState.isShiftPressed && !keyboardState.isCapsLockOn) {
          keyboardState.resetShift();
        }
        
        // Check for auto-capitalization
        _checkAutoCapitalization();
        break;
    }
  }

  Future<void> _checkAutoCapitalization() async {
    final keyboardState = context.read<KeyboardStateModel>();
    
    if (!keyboardState.isCapsLockOn && !keyboardState.isShiftPressed) {
      final textBefore = await _platformService.getTextBeforeCursor(length: 50);
      
      if (keyboardState.shouldAutoCapitalize(textBefore)) {
        keyboardState.setShift(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KeyboardStateModel>(
      builder: (context, keyboardState, child) {
        final prefs = PreferencesService.instance;
        final screenHeight = MediaQuery.of(context).size.height;
        final keyboardHeight = screenHeight * prefs.keyboardHeight;

        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            height: keyboardHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top toolbar
                  _buildTopToolbar(keyboardState),
                  
                  // Main keyboard layout
                  Expanded(
                    child: KeyboardLayout(
                      onKeyPressed: _handleKeyPress,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopToolbar(KeyboardStateModel keyboardState) {
    final prefs = PreferencesService.instance;
    final enabledLanguages = prefs.enabledLanguages;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Language selector (if multiple languages enabled)
          if (enabledLanguages.length > 1)
            LanguageSelector(
              currentLanguage: keyboardState.currentLanguage,
              onLanguageChanged: (language) async {
                await keyboardState.setLanguage(language);
              },
            ),
          
          const Spacer(),
          
          // Input type indicator
          _buildInputTypeIndicator(keyboardState.inputInfo),
          
          const SizedBox(width: 8),
          
          // Hide keyboard button
          IconButton(
            onPressed: () => _handleKeyPress('HIDE_KEYBOARD'),
            icon: const Icon(Icons.keyboard_hide),
            iconSize: 20,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }

  Widget _buildInputTypeIndicator(Map<String, dynamic> inputInfo) {
    if (inputInfo.isEmpty) return const SizedBox.shrink();

    IconData icon = Icons.text_fields;
    String tooltip = 'Text input';

    // Determine input type based on Android InputType
    final inputType = inputInfo['inputType'] as int? ?? 0;
    
    if (inputType & 0x00000002 != 0) { // TYPE_CLASS_NUMBER
      icon = Icons.numbers;
      tooltip = 'Number input';
    } else if (inputType & 0x00000020 != 0) { // TYPE_TEXT_VARIATION_EMAIL_ADDRESS
      icon = Icons.email;
      tooltip = 'Email input';
    } else if (inputType & 0x00000080 != 0) { // TYPE_TEXT_VARIATION_PASSWORD
      icon = Icons.lock;
      tooltip = 'Password input';
    } else if (inputType & 0x00000010 != 0) { // TYPE_TEXT_VARIATION_URI
      icon = Icons.link;
      tooltip = 'URL input';
    }

    return Tooltip(
      message: tooltip,
      child: Icon(
        icon,
        size: 16,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}