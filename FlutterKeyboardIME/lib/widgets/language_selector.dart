import 'package:flutter/material.dart';
import '../models/keyboard_state.dart';
import '../services/preferences_service.dart';

class LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final prefs = PreferencesService.instance;
    final enabledLanguages = prefs.enabledLanguages;
    
    if (enabledLanguages.length <= 1) {
      return const SizedBox.shrink();
    }

    final currentConfig = LanguageConfig.getConfig(currentLanguage);
    
    return GestureDetector(
      onTap: () {
        _switchToNextLanguage(enabledLanguages);
      },
      onLongPress: () {
        _showLanguageSelector(context, enabledLanguages);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          currentConfig.displayName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _switchToNextLanguage(List<String> enabledLanguages) {
    final currentIndex = enabledLanguages.indexOf(currentLanguage);
    final nextIndex = (currentIndex + 1) % enabledLanguages.length;
    onLanguageChanged(enabledLanguages[nextIndex]);
  }

  void _showLanguageSelector(BuildContext context, List<String> enabledLanguages) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Language',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...enabledLanguages.map((languageCode) {
                final config = LanguageConfig.getConfig(languageCode);
                final isSelected = languageCode == currentLanguage;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    child: Text(
                      config.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  title: Text(config.name),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    onLanguageChanged(languageCode);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}