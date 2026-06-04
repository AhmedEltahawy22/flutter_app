import 'package:flutter/material.dart';

class AppThemeScope extends InheritedWidget {
  const AppThemeScope({
    super.key,
    required this.notifier,
    required super.child,
  });

  final ValueNotifier<ThemeMode> notifier;

  static ValueNotifier<ThemeMode> notifierOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppThemeScope>()!.notifier;
  }

  @override
  bool updateShouldNotify(AppThemeScope oldWidget) => notifier != oldWidget.notifier;
}
