import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'metro_graph.dart';
import 'providers/app_language_scope.dart';
import 'providers/app_route_preference_scope.dart';
import 'providers/app_wallet_scope.dart';
import 'providers/app_theme_scope.dart';
import 'screens/splash_page.dart';

void main() {
  MetroGraph.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<String> _languageNotifier = ValueNotifier<String>('ar');
  final ValueNotifier<String> _routePreferenceNotifier = ValueNotifier<String>('fastest');
  final ValueNotifier<WalletState> _walletNotifier = ValueNotifier<WalletState>(
    WalletState(balance: 0.0, transactions: []),
  );
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      notifier: _themeNotifier,
      child: AppWalletScope(
        notifier: _walletNotifier,
        child: AppRoutePreferenceScope(
          notifier: _routePreferenceNotifier,
          child: AppLanguageScope(
            notifier: _languageNotifier,
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: _themeNotifier,
              builder: (context, themeMode, _) {
                return ValueListenableBuilder<String>(
                  valueListenable: _languageNotifier,
                  builder: (context, language, _) {
                    // ضبط لون شريط الحالة ليكون واضحاً دائماً
                    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark,
                      statusBarBrightness: themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
                    ));

                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      title: language == 'ar' ? 'مواصلاتي' : 'Mwasalaty',
                      themeMode: themeMode,
                      builder: (context, child) {
                        final mediaQuery = MediaQuery.of(context);
                        final width = mediaQuery.size.width;
                        final scale = (width / 390).clamp(0.95, 1.15);
                        return Directionality(
                          textDirection: language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                          child: MediaQuery(
                            data: mediaQuery.copyWith(textScaler: TextScaler.linear(scale)),
                            child: child!,
                          ),
                        );
                      },
                      theme: ThemeData(
                        useMaterial3: true,
                        brightness: Brightness.light,
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: const Color(0xFF1F2B63),
                          brightness: Brightness.light,
                        ),
                        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
                        elevatedButtonTheme: ElevatedButtonThemeData(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      darkTheme: ThemeData(
                        useMaterial3: true,
                        brightness: Brightness.dark,
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: const Color(0xFF1F2B63),
                          brightness: Brightness.dark,
                          surface: const Color(0xFF121212),
                        ),
                        scaffoldBackgroundColor: const Color(0xFF121212),
                        appBarTheme: const AppBarTheme(
                          backgroundColor: Color(0xFF1E1E1E),
                          foregroundColor: Colors.white,
                          titleTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          iconTheme: IconThemeData(color: Colors.white),
                        ),
                        snackBarTheme: const SnackBarThemeData(
                          backgroundColor: Color(0xFF2D2D2D),
                          contentTextStyle: TextStyle(color: Colors.white),
                          actionTextColor: Color(0xFFF2C230),
                        ),
                        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                          backgroundColor: Color(0xFF1E1E1E),
                          selectedItemColor: Color(0xFFF2C230),
                          unselectedItemColor: Color(0xFF8A92A6),
                        ),
                        elevatedButtonTheme: ElevatedButtonThemeData(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      home: const SplashPage(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
