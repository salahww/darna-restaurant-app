import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:darna/features/settings/presentation/providers/settings_provider.dart';
import 'package:darna/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);
    // Fallback if l10n is null (e.g. before generation/rebuild)
    // We can use ternary or ensuring generation is run.

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n?.settings ?? 'Settings', style: theme.textTheme.headlineSmall),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Language Section
            _buildSection(
              theme,
              title: l10n?.language ?? 'Language',
              children: [
                _buildRadioItem(
                  theme: theme,
                  title: 'English',
                  value: const Locale('en'),
                  groupValue: settings.locale,
                  onChanged: (val) => ref.read(settingsProvider.notifier).setLocale(val!),
                ),
                _buildRadioItem(
                  theme: theme,
                  title: 'Français',
                  value: const Locale('fr'),
                  groupValue: settings.locale,
                  onChanged: (val) => ref.read(settingsProvider.notifier).setLocale(val!),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Theme Section
            _buildSection(
              theme,
              title: l10n?.theme ?? 'Theme',
              children: [
                _buildRadioItem(
                  theme: theme,
                  title: l10n?.systemMode ?? 'System',
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (val) => ref.read(settingsProvider.notifier).setThemeMode(val!),
                ),
                _buildRadioItem(
                  theme: theme,
                  title: l10n?.lightMode ?? 'Light Mode',
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (val) => ref.read(settingsProvider.notifier).setThemeMode(val!),
                ),
                _buildRadioItem(
                  theme: theme,
                  title: l10n?.darkMode ?? 'Dark Mode',
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (val) => ref.read(settingsProvider.notifier).setThemeMode(val!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRadioItem<T>({
    required ThemeData theme,
    required String title,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    // Determine active color based on theme
    final isSelected = value == groupValue;
    return RadioListTile<T>(
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.deepTeal,
      contentPadding: EdgeInsets.zero,
    );
  }
}
