import 'package:flutter/material.dart';
import 'app_theme.dart';

abstract class AppColors {
  static const Color primary = AppTheme.primary;
  static const Color primaryDark = AppTheme.primaryDark;
  static const Color secondary = AppTheme.secondary;
  static const Color accent = AppTheme.accent;
  static const Color background = AppTheme.background;
  static const Color surface = AppTheme.surface;
  static const Color cardBorder = AppTheme.cardBorder;
  static const Color textPrimary = AppTheme.textPrimary;
  static const Color textSecondary = AppTheme.textSecondary;
  static const Color success = AppTheme.success;
  static const Color warning = AppTheme.warning;

  // Intelligence Category Color Codes
  static const Color linguistic = AppTheme.linguistic;
  static const Color logical = AppTheme.logical;
  static const Color spatial = AppTheme.spatial;
  static const Color bodily = AppTheme.bodily;
  static const Color musical = AppTheme.musical;
  static const Color interpersonal = AppTheme.interpersonal;
  static const Color intrapersonal = AppTheme.intrapersonal;
  static const Color naturalistic = AppTheme.naturalistic;
  static const Color onboardingBorder = Color(0xFFE2E8F0);
  static const Color onboardingTextTitle = Color(0xFF0F172A);
  static const Color onboardingTextBody = Color(0xFF64748B);
}
