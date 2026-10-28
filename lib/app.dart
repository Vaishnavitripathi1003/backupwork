/*
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/screens/dashboard.dart';

export 'core/theme/app_theme.dart';

class DakshApp extends StatelessWidget {
  const DakshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daksh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/localization/language_manager.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

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
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}