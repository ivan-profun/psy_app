import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final localizations = AppLocalizations.of(context) ?? AppLocalizations(const Locale('ru'));
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, Icons.palette, localizations.theme),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.brightness_6, color: theme.colorScheme.primary),
                  title: Text(localizations.theme),
                  subtitle: Text(_getThemeModeText(settings.themeMode, localizations)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context, settings, localizations),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.text_fields, color: theme.colorScheme.primary),
                  title: Text(localizations.fontSize),
                  subtitle: Text(_getFontSizeText(settings.fontSize, localizations)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showFontSizeDialog(context, settings, localizations),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader(context, Icons.language, localizations.language),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.language, color: theme.colorScheme.primary),
              title: Text(localizations.language),
              subtitle: Text(_getLanguageText(settings.language, localizations)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context, settings, localizations),
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader(context, Icons.notifications, localizations.notifications),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.notifications_active, color: theme.colorScheme.primary),
                  title: Text(localizations.translate('push_notifications')),
                  subtitle: Text(localizations.translate('receive_notifications')),
                  value: settings.pushNotifications,
                  onChanged: (value) {
                    settings.setPushNotifications(value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(Icons.email, color: theme.colorScheme.primary),
                  title: Text(localizations.translate('email_notifications')),
                  subtitle: Text(localizations.translate('receive_email_notifications')),
                  value: settings.emailNotifications,
                  onChanged: (value) {
                    settings.setEmailNotifications(value);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader(context, Icons.security, localizations.privacy),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock, color: theme.colorScheme.primary),
                  title: Text(localizations.translate('privacy_policy')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      localizations.translate('privacy_policy'),
                      localizations.translate('privacy_policy_text'),
                      localizations,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.shield, color: theme.colorScheme.primary),
                  title: Text(localizations.translate('data_security')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      localizations.translate('data_security'),
                      localizations.translate('data_security_text'),
                      localizations,
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader(context, Icons.info, localizations.about),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
                  title: Text(localizations.translate('app_version')),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.description, color: theme.colorScheme.primary),
                  title: Text(localizations.translate('terms_of_use')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      localizations.translate('terms_of_use'),
                      localizations.translate('terms_of_use_text'),
                      localizations,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.help_outline, color: theme.colorScheme.primary),
                  title: Text(localizations.translate('help_support')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showInfoDialog(
                      context,
                      localizations.translate('help_support'),
                      localizations.translate('help_support_text'),
                      localizations,
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  String _getThemeModeText(ThemeMode mode, AppLocalizations localizations) {
    switch (mode) {
      case ThemeMode.light:
        return localizations.lightTheme;
      case ThemeMode.dark:
        return localizations.darkTheme;
      case ThemeMode.system:
        return localizations.systemTheme;
    }
  }

  String _getFontSizeText(FontSize size, AppLocalizations localizations) {
    switch (size) {
      case FontSize.small:
        return localizations.smallFont;
      case FontSize.medium:
        return localizations.mediumFont;
      case FontSize.large:
        return localizations.largeFont;
    }
  }

  String _getLanguageText(String lang, AppLocalizations localizations) {
    switch (lang) {
      case 'ru':
        return localizations.russian;
      case 'en':
        return localizations.english;
      case 'uz':
        return localizations.uzbek;
      case 'tg':
        return localizations.tajik;
      case 'qya':
        return localizations.elvish;
      case 'os':
        return localizations.ossetian;
      case 'uk':
        return localizations.ukrainian;
      case 'sah':
        return localizations.yakut;
      case 'cu':
        return localizations.oldChurchSlavonic;
      default:
        return localizations.russian;
    }
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.brightness_6, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                localizations.translate('select_theme'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(localizations.lightTheme),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(localizations.darkTheme),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(localizations.systemTheme),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, SettingsProvider settings, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.text_fields, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                localizations.fontSize,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<FontSize>(
              title: Text(localizations.smallFont),
              value: FontSize.small,
              groupValue: settings.fontSize,
              onChanged: (value) {
                if (value != null) {
                  settings.setFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<FontSize>(
              title: Text(localizations.mediumFont),
              value: FontSize.medium,
              groupValue: settings.fontSize,
              onChanged: (value) {
                if (value != null) {
                  settings.setFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<FontSize>(
              title: Text(localizations.largeFont),
              value: FontSize.large,
              groupValue: settings.fontSize,
              onChanged: (value) {
                if (value != null) {
                  settings.setFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                localizations.translate('select_language'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Русский'),
                value: 'ru',
                groupValue: settings.language,
                onChanged: (value) async {
                  if (value != null && value != settings.language) {
                    Navigator.pop(context);
                    await settings.setLanguage(value);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.translate('language_changed') ?? 'Язык изменён'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: settings.language,
                onChanged: (value) async {
                  if (value != null && value != settings.language) {
                    Navigator.pop(context);
                    await settings.setLanguage(value);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.translate('language_changed') ?? 'Language changed'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('O\'zbek'),
                value: 'uz',
                groupValue: settings.language,
                onChanged: (value) async {
                  if (value != null && value != settings.language) {
                    Navigator.pop(context);
                    await settings.setLanguage(value);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.translate('language_changed') ?? 'Язык изменён'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Тоҷикӣ'),
                value: 'tg',
                groupValue: settings.language,
                onChanged: (value) async {
                  if (value != null && value != settings.language) {
                    Navigator.pop(context);
                    await settings.setLanguage(value);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.translate('language_changed') ?? 'Язык изменён'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Quenya (Elvish)'),
                value: 'qya',
                groupValue: settings.language,
                onChanged: (value) async {
                  if (value != null && value != settings.language) {
                    Navigator.pop(context);
                    await settings.setLanguage(value);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.translate('language_changed') ?? 'Язык изменён'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Ирон (Ossetian)'),
                value: 'os',
                groupValue: settings.language,
                onChanged: (value) async {
                  if (value != null && value != settings.language) {
                    Navigator.pop(context);
                    await settings.setLanguage(value);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.translate('language_changed') ?? 'Язык изменён'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Українська'),
                value: 'uk',
                groupValue: settings.language,
                onChanged: (value) async {
                  if (value != null && value != settings.language) {
                    Navigator.pop(context);
                    await settings.setLanguage(value);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.translate('language_changed') ?? 'Язык изменён'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Саха (Yakut)'),
                value: 'sah',
                groupValue: settings.language,
                onChanged: (value) async {
                  if (value != null && value != settings.language) {
                    Navigator.pop(context);
                    await settings.setLanguage(value);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.translate('language_changed') ?? 'Язык изменён'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Словѣньскъ (Old Church Slavonic)'),
                value: 'cu',
                groupValue: settings.language,
                onChanged: (value) async {
                  if (value != null && value != settings.language) {
                    Navigator.pop(context);
                    await settings.setLanguage(value);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.translate('language_changed') ?? 'Язык изменён'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('close')),
          ),
        ],
      ),
    );
  }
}
