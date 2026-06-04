import 'package:flutter/material.dart';
import '../providers/app_language_scope.dart';

String tr(BuildContext context, String ar, String en) {
  return AppLanguageScope.notifierOf(context).value == 'ar' ? ar : en;
}