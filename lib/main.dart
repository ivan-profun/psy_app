import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/firebase_service.dart';
import 'core/providers/settings_provider.dart';
import 'core/l10n/app_localizations.dart';
import 'core/navigation/navigator_key.dart';
import 'presentation/screens/auth/auth_wrapper.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase инициализирован');
  } catch (e) {
    print('❌ Ошибка Firebase: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Locale _materialLocaleFor(String lang) {
    switch (lang) {
      case 'ru':
        return const Locale('ru', 'RU');
      default:
        return const Locale('en', 'US');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseService>(
          create: (_) => FirebaseService(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final forced = ['ru', 'en', 'uz', 'tg', 'qya', 'os', 'uk', 'sah', 'cu'].contains(settings.language)
              ? Locale(settings.language)
              : const Locale('ru', 'RU');
          AppLocalizations.forcedLocale = forced;

          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Психологическая помощь',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: _materialLocaleFor(settings.language),
            localizationsDelegates: [
              AppLocalizations.delegateFor(forced),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ru', 'RU'),
              Locale('en', 'US'),
              Locale('uz', 'UZ'),
              Locale('tg', 'TJ'),
              Locale('qya'),
              Locale('os'),
              Locale('uk', 'UA'),
              Locale('sah'),
              Locale('cu'),
            ],
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: settings.textScaleFactor,
                ),
                child: child!,
              );
            },
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}