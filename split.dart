import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  final lines = file.readAsLinesSync();
  
  Map<String, List<String>> extracted = {};
  String? currentBlock;
  int braceCount = 0;
  List<String> currentLines = [];

  for (int i = 0; i < lines.length; i++) {
    String line = lines[i];
    
    if (currentBlock == null) {
      if (line.startsWith('class AppLanguageScope')) currentBlock = 'AppLanguageScope';
      else if (line.startsWith('class AppRoutePreferenceScope')) currentBlock = 'AppRoutePreferenceScope';
      else if (line.startsWith('String tr(')) currentBlock = 'tr';
      else if (line.startsWith('class SplashPage')) currentBlock = 'SplashPage';
      else if (line.startsWith('class _SplashPageState')) currentBlock = '_SplashPageState';
      else if (line.startsWith('class HomePage')) currentBlock = 'HomePage';
      else if (line.startsWith('class _HomePageState')) currentBlock = '_HomePageState';
      else if (line.startsWith('class LoginPage')) currentBlock = 'LoginPage';
      else if (line.startsWith('class _LoginPageState')) currentBlock = '_LoginPageState';
      else if (line.startsWith('class SignUpPage')) currentBlock = 'SignUpPage';
      else if (line.startsWith('class _SignUpPageState')) currentBlock = '_SignUpPageState';
      else if (line.startsWith('class SearchPage')) currentBlock = 'SearchPage';
      else if (line.startsWith('class _SearchPageState')) currentBlock = '_SearchPageState';
      else if (line.startsWith('class TripOption')) currentBlock = 'TripOption';
      else if (line.startsWith('class SearchTripsPage')) currentBlock = 'SearchTripsPage';
      else if (line.startsWith('class _SearchTripsPageState')) currentBlock = '_SearchTripsPageState';
      else if (line.startsWith('class RouteDetailsPage')) currentBlock = 'RouteDetailsPage';
      else if (line.startsWith('class JourneyTrackingPage')) currentBlock = 'JourneyTrackingPage';
      else if (line.startsWith('class _JourneyTrackingPageState')) currentBlock = '_JourneyTrackingPageState';
      else if (line.startsWith('class SettingsPage')) currentBlock = 'SettingsPage';
      else if (line.startsWith('class _SettingsPageState')) currentBlock = '_SettingsPageState';
      else if (line.startsWith('class _GoogleLogoPainter')) currentBlock = '_GoogleLogoPainter';
      
      if (currentBlock != null) {
        currentLines.add(line);
        braceCount += '{'.allMatches(line).length;
        braceCount -= '}'.allMatches(line).length;
        if (braceCount == 0 && currentBlock == 'tr' && line.contains('}')) {
             extracted[currentBlock] = List.from(currentLines);
             currentLines.clear();
             currentBlock = null;
        }
      }
    } else {
      currentLines.add(line);
      braceCount += '{'.allMatches(line).length;
      braceCount -= '}'.allMatches(line).length;
      
      if (braceCount == 0) {
        extracted[currentBlock] = List.from(currentLines);
        currentLines.clear();
        currentBlock = null;
      }
    }
  }

  final files = {
    'lib/core/localization.dart': [
      "import 'package:flutter/material.dart';",
      "import '../providers/app_language_scope.dart';",
      "",
      ...(extracted['tr'] ?? [])
    ],
    'lib/core/constants.dart': [
      "const String logoAsset = 'assets/images/logo.png';"
    ],
    'lib/providers/app_language_scope.dart': [
      "import 'package:flutter/material.dart';",
      "",
      ...(extracted['AppLanguageScope'] ?? [])
    ],
    'lib/providers/app_route_preference_scope.dart': [
      "import 'package:flutter/material.dart';",
      "",
      ...(extracted['AppRoutePreferenceScope'] ?? [])
    ],
    'lib/models/trip_option.dart': [
      ...(extracted['TripOption'] ?? [])
    ],
    'lib/screens/splash_page.dart': [
      "import 'package:flutter/material.dart';",
      "import '../core/constants.dart';",
      "import '../core/localization.dart';",
      "import 'auth/login_page.dart';",
      "",
      ...(extracted['SplashPage'] ?? []),
      ...(extracted['_SplashPageState'] ?? [])
    ],
    'lib/screens/home_page.dart': [
      "import 'package:flutter/material.dart';",
      "import 'package:shared_preferences/shared_preferences.dart';",
      "import '../core/localization.dart';",
      "import '../metro_graph.dart';",
      "import 'search/search_page.dart';",
      "import 'settings/settings_page.dart';",
      "",
      ...(extracted['HomePage'] ?? []),
      ...(extracted['_HomePageState'] ?? [])
    ],
    'lib/screens/auth/login_page.dart': [
      "import 'package:flutter/material.dart';",
      "import 'package:shared_preferences/shared_preferences.dart';",
      "import 'package:flutter/services.dart';",
      "import '../../core/constants.dart';",
      "import '../../core/localization.dart';",
      "import '../home_page.dart';",
      "import 'sign_up_page.dart';",
      "",
      ...(extracted['LoginPage'] ?? []),
      ...(extracted['_LoginPageState'] ?? [])
    ],
    'lib/screens/auth/sign_up_page.dart': [
      "import 'package:flutter/material.dart';",
      "import 'package:shared_preferences/shared_preferences.dart';",
      "import '../../core/constants.dart';",
      "import '../../core/localization.dart';",
      "import '../home_page.dart';",
      "import '../../widgets/google_logo_painter.dart';",
      "",
      ...(extracted['SignUpPage'] ?? []),
      ...(extracted['_SignUpPageState'] ?? [])
    ],
    'lib/screens/search/search_page.dart': [
      "import 'package:flutter/material.dart';",
      "import '../../core/localization.dart';",
      "import '../../metro_graph.dart';",
      "import 'search_trips_page.dart';",
      "",
      ...(extracted['SearchPage'] ?? []),
      ...(extracted['_SearchPageState'] ?? [])
    ],
    'lib/screens/search/search_trips_page.dart': [
      "import 'package:flutter/material.dart';",
      "import '../../core/localization.dart';",
      "import '../../metro_graph.dart';",
      "import '../../models/trip_option.dart';",
      "import '../../routing_service.dart';",
      "import '../../providers/app_route_preference_scope.dart';",
      "import '../journey/route_details_page.dart';",
      "",
      ...(extracted['SearchTripsPage'] ?? []),
      ...(extracted['_SearchTripsPageState'] ?? [])
    ],
    'lib/screens/journey/route_details_page.dart': [
      "import 'package:flutter/material.dart';",
      "import 'package:flutter_map/flutter_map.dart';",
      "import 'package:latlong2/latlong.dart';",
      "import '../../core/localization.dart';",
      "import '../../metro_graph.dart';",
      "import '../../models/trip_option.dart';",
      "import 'journey_tracking_page.dart';",
      "",
      ...(extracted['RouteDetailsPage'] ?? [])
    ],
    'lib/screens/journey/journey_tracking_page.dart': [
      "import 'package:flutter/material.dart';",
      "import 'package:flutter_map/flutter_map.dart';",
      "import 'package:latlong2/latlong.dart';",
      "import '../../core/localization.dart';",
      "import '../../metro_graph.dart';",
      "import '../../models/trip_option.dart';",
      "",
      ...(extracted['JourneyTrackingPage'] ?? []),
      ...(extracted['_JourneyTrackingPageState'] ?? [])
    ],
    'lib/screens/settings/settings_page.dart': [
      "import 'package:flutter/material.dart';",
      "import 'package:shared_preferences/shared_preferences.dart';",
      "import '../../core/localization.dart';",
      "import '../../providers/app_language_scope.dart';",
      "import '../../providers/app_route_preference_scope.dart';",
      "import '../auth/login_page.dart';",
      "",
      ...(extracted['SettingsPage'] ?? []),
      ...(extracted['_SettingsPageState'] ?? [])
    ],
    'lib/widgets/google_logo_painter.dart': [
      "import 'package:flutter/material.dart';",
      "import 'dart:math';",
      "",
      ...(extracted['_GoogleLogoPainter'] ?? [])
    ]
  };

  for (var entry in files.entries) {
    File(entry.key).writeAsStringSync(entry.value.join('\n'));
  }

  print('Files created.');
}
