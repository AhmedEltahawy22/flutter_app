import 'package:flutter/material.dart';

class AppLanguageScope extends InheritedNotifier<ValueNotifier<String>> {
  const AppLanguageScope({
    super.key,
    required ValueNotifier<String> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ValueNotifier<String> notifierOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLanguageScope>();
    assert(scope != null, 'AppLanguageScope not found in widget tree');
    return scope!.notifier!;
  }
}