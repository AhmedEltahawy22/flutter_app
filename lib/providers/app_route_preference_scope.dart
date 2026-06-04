import 'package:flutter/material.dart';

class AppRoutePreferenceScope extends InheritedNotifier<ValueNotifier<String>> {
  const AppRoutePreferenceScope({
    super.key,
    required ValueNotifier<String> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ValueNotifier<String> notifierOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppRoutePreferenceScope>();
    assert(scope != null, 'AppRoutePreferenceScope not found in widget tree');
    return scope!.notifier!;
  }
}