import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'metro_graph.dart';
import 'providers/app_language_scope.dart';
import 'providers/app_route_preference_scope.dart';
import 'providers/app_wallet_scope.dart';
import 'providers/app_theme_scope.dart';
import 'screens/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    MetroGraph.init();
    // تهيئة Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyB02OtVlmS0EpGr-AFb7aVNeeW2uA_t2xQ',
        authDomain: 'flutter-mwasalaty-app.firebaseapp.com',
        projectId: 'flutter-mwasalaty-app',
        storageBucket: 'flutter-mwasalaty-app.firebasestorage.app',
        messagingSenderId: '1028046177662',
        appId: '1:1028046177662:web:fbec1fe75c0307ed965f2f',
        measurementId: 'G-EK1YTP1PPJ',
      ),
    );
    
    // تحميل التفضيلات المحفوظة
    final prefs = await SharedPreferences.getInstance();
    final initialLang = prefs.getString('language') ?? 'ar';
    final initialPref = prefs.getString('route_preference') ?? 'fastest';
    final initialThemeStr = prefs.getString('theme_mode') ?? 'light';
    ThemeMode initialTheme = ThemeMode.light;
    if (initialThemeStr == 'dark') initialTheme = ThemeMode.dark;
    else if (initialThemeStr == 'system') initialTheme = ThemeMode.system;

    // تحميل بيانات المحفظة المحفوظة مسبقاً
    final savedWallet = await WalletPersistence.load();
    runApp(MyApp(
      initialWallet: savedWallet,
      initialLang: initialLang,
      initialRoutePref: initialPref,
      initialTheme: initialTheme,
    ));
  } catch (e, stackTrace) {
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Crash during startup:\n$e\n\nStackTrace:\n$stackTrace',
              style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatefulWidget {
  final WalletState? initialWallet;
  final String? initialLang;
  final String? initialRoutePref;
  final ThemeMode? initialTheme;

  const MyApp({
    super.key,
    this.initialWallet,
    this.initialLang,
    this.initialRoutePref,
    this.initialTheme,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ValueNotifier<String> _languageNotifier;
  late final ValueNotifier<String> _routePreferenceNotifier;
  late final ValueNotifier<WalletState> _walletNotifier;
  late final ValueNotifier<ThemeMode> _themeNotifier;

  @override
  void initState() {
    super.initState();
    _languageNotifier = ValueNotifier<String>(widget.initialLang ?? 'ar');
    _routePreferenceNotifier = ValueNotifier<String>(widget.initialRoutePref ?? 'fastest');
    _themeNotifier = ValueNotifier<ThemeMode>(widget.initialTheme ?? ThemeMode.light);
    
    // تهيئة المحفظة بالبيانات المحفوظة أو القيم الافتراضية
    _walletNotifier = ValueNotifier<WalletState>(
      widget.initialWallet ?? WalletState(balance: 0.0, transactions: []),
    );

    // إضافة مستمعين لحفظ التغييرات في SharedPreferences
    _languageNotifier.addListener(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', _languageNotifier.value);
    });

    _routePreferenceNotifier.addListener(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('route_preference', _routePreferenceNotifier.value);
    });

    _themeNotifier.addListener(() async {
      final prefs = await SharedPreferences.getInstance();
      String themeStr = 'light';
      if (_themeNotifier.value == ThemeMode.dark) themeStr = 'dark';
      else if (_themeNotifier.value == ThemeMode.system) themeStr = 'system';
      await prefs.setString('theme_mode', themeStr);
    });
  }

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
