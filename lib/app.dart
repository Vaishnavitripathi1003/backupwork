import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/language_manager.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

export 'core/theme/app_theme.dart';

class DakshApp extends StatelessWidget {
  const DakshApp({super.key});
  static const platform = MethodChannel('com.example.fingerprintworkdemo/native');

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.instance.languageNotifier,
      builder: (context, langCode, child) {
        return MaterialApp.router(
          title: 'Daksh',
          locale: Locale(langCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
