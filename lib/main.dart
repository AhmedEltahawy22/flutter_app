import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const String logoAsset = 'assets/images/logo.png';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مواصلاتي',
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final width = mediaQuery.size.width;
        final scale = (width / 390).clamp(0.95, 1.15);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F2B63),
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2B63),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6C63B),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.16),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 22,
                      child: Text(
                        'EST.2025',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 22,
                      child: Text(
                        'خليك على الطريق',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 42,
                      top: 92,
                      child: Icon(
                        Icons.location_on,
                        size: 34,
                        color: Colors.white.withOpacity(0.92),
                      ),
                    ),
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          logoAsset,
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              'مواصلاتي',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF1F2B63),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Mwasalaty',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'معاك طول الطريق',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height - MediaQuery.of(context).padding.vertical,
            child: Stack(
              children: [
                Container(
                  height: size.height * 0.38,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1F2B63), Color(0xFFF6C63B)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.16),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            logoAsset,
                            width: 96,
                            height: 96,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text(
                                'مواصلاتي',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF1F2B63),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                Positioned(
                  top: size.height * 0.24,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            color: const Color(0xFF1F2B63),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue your journey',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            labelText: 'Email',
                            hintText: 'your.email@example.com',
                            filled: true,
                            fillColor: const Color(0xFFF7F9FE),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            filled: true,
                            fillColor: const Color(0xFFF7F9FE),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF1F2B63),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const SearchPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF6C63B),
                            foregroundColor: Colors.black,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: const [
                            Expanded(child: Divider(thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.g_mobiledata_outlined),
                          label: const Text('Continue with Google'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            backgroundColor: const Color(0xFFF7F9FE),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.facebook),
                          label: const Text('Continue with Facebook'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F2B63),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1F2B63),
                              ),
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const SearchPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Skip for now',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const LatLng _ramses = LatLng(30.06263, 31.24685);
  static const LatLng _cairoAirport = LatLng(30.11298, 31.40097);
  static const LatLng _downtown = LatLng(30.04442, 31.23571);
  static const LatLng _abbassia = LatLng(30.07234, 31.28271);

  final TextEditingController _fromController = TextEditingController(
    text: 'Ramses Station',
  );
  final TextEditingController _toController = TextEditingController(
    text: 'Cairo Airport',
  );
  final Set<String> _selectedModes = {'Bus', 'Metro'};

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      const Marker(
        markerId: MarkerId('from'),
        position: _ramses,
        infoWindow: InfoWindow(title: 'From: Ramses Station'),
      ),
      const Marker(
        markerId: MarkerId('to'),
        position: _cairoAirport,
        infoWindow: InfoWindow(title: 'To: Cairo Airport'),
      ),
      const Marker(
        markerId: MarkerId('interchange_1'),
        position: _downtown,
        infoWindow: InfoWindow(title: 'Interchange: Metro'),
      ),
      const Marker(
        markerId: MarkerId('interchange_2'),
        position: _abbassia,
        infoWindow: InfoWindow(title: 'Interchange: Bus'),
      ),
    };

    final polylines = <Polyline>{
      const Polyline(
        polylineId: PolylineId('route_preview'),
        points: [_ramses, _downtown, _abbassia, _cairoAirport],
        color: Color(0xFF1F2BDB),
        width: 5,
      ),
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2BDB),
        foregroundColor: Colors.white,
        title: const Text('Search Trip'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(30.079, 31.31),
                        zoom: 11.2,
                      ),
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      markers: markers,
                      polylines: polylines,
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 15,
                              color: Color(0xFF1F2B63),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Route preview',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2B63),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _fromController,
                      decoration: InputDecoration(
                        labelText: 'From',
                        prefixIcon: const Icon(Icons.trip_origin),
                        filled: true,
                        fillColor: const Color(0xFFF7F9FE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _toController,
                      decoration: InputDecoration(
                        labelText: 'To',
                        prefixIcon: const Icon(Icons.place_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF7F9FE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Transport Options',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _modeChip('Bus'),
                        _modeChip('Metro'),
                        _modeChip('Microbus'),
                        _modeChip('Walk'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SearchTripsPage(
                                from: _fromController.text.trim(),
                                to: _toController.text.trim(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2C230),
                          foregroundColor: const Color(0xFF1F2B63),
                        ),
                        child: const Text('Find Routes'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeChip(String mode) {
    final selected = _selectedModes.contains(mode);
    return FilterChip(
      label: Text(mode),
      selected: selected,
      onSelected: (value) {
        setState(() {
          if (value) {
            _selectedModes.add(mode);
          } else {
            _selectedModes.remove(mode);
          }
        });
      },
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: selected ? const Color(0xFF1F2B63) : Colors.black87,
      ),
      selectedColor: const Color(0xFFF2C230),
      checkmarkColor: const Color(0xFF1F2B63),
    );
  }
}

class TripOption {
  const TripOption({
    required this.title,
    required this.durationMinutes,
    required this.price,
    required this.steps,
  });

  final String title;
  final int durationMinutes;
  final int price;
  final List<String> steps;
}

class RouteSegment {
  const RouteSegment({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.durationText,
    required this.distanceText,
  });

  final String mode;
  final String title;
  final String subtitle;
  final String durationText;
  final String distanceText;
}

class SearchTripsPage extends StatefulWidget {
  const SearchTripsPage({super.key, required this.from, required this.to});

  final String from;
  final String to;

  @override
  State<SearchTripsPage> createState() => _SearchTripsPageState();
}

class _SearchTripsPageState extends State<SearchTripsPage> {
  String _sortBy = 'time';
  int _bottomNavIndex = 0;

  final List<TripOption> _allTrips = const [
    TripOption(
      title: 'Economy Route',
      durationMinutes: 48,
      price: 18,
      steps: ['Bus 32', 'Metro Line 1', 'Walk 6 min'],
    ),
    TripOption(
      title: 'Fastest Route',
      durationMinutes: 33,
      price: 27,
      steps: ['Metro Line 2', 'Microbus 14'],
    ),
    TripOption(
      title: 'Balanced Route',
      durationMinutes: 41,
      price: 22,
      steps: ['Bus 10', 'Metro Line 1', 'Bus 6'],
    ),
    TripOption(
      title: 'Few Transfers',
      durationMinutes: 45,
      price: 24,
      steps: ['Microbus 21', 'Metro Line 1'],
    ),
  ];

  List<TripOption> get _filteredTrips {
    final trips = List<TripOption>.from(_allTrips);

    trips.sort((a, b) {
      if (_sortBy == 'time') {
        return a.durationMinutes.compareTo(b.durationMinutes);
      }
      return a.price.compareTo(b.price);
    });
    return trips;
  }

  @override
  Widget build(BuildContext context) {
    final trips = _filteredTrips;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopHeader(trips.length),
            const SizedBox(height: 12),
            if (trips.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No routes match the selected filters.'),
                ),
              )
            else
              ...trips.map(_buildTripCard),
          ],
        ),
      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          if (index == 0) {
            Navigator.of(context).pop();
          } else if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Saved routes soon')),
            );
          } else if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          }
        },
        selectedItemColor: const Color(0xFFF2C230),
        unselectedItemColor: const Color(0xFF8A92A6),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border_rounded),
            label: 'Saved',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildTopHeader(int tripsCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2BDB),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildSortChip(label: 'Time Route', value: 'time'),
                    _buildSortChip(label: 'Cost Route', value: 'price'),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
                icon: const Icon(Icons.settings, color: Colors.white, size: 18),
                visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$tripsCount routes found',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.from}  ->  ${widget.to}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip({required String label, required String value}) {
    final selected = _sortBy == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFF1A1A1A) : const Color(0xFF1F2B63),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: selected,
      onSelected: (_) => setState(() => _sortBy = value),
      selectedColor: const Color(0xFFF6C63B),
      backgroundColor: const Color(0xFFF1F3FA),
      side: BorderSide(
        color: selected ? const Color(0xFFF6C63B) : const Color(0xFFD5DBEB),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
    );
  }

  Widget _buildTransportIcon(String step) {
    IconData icon = Icons.directions_walk;
    String label = 'Walk';
    Color bg = const Color(0xFF9EA4B5);
    if (step.toLowerCase().contains('metro')) {
      icon = Icons.train_rounded;
      label = 'Metro';
      bg = const Color(0xFFE53935);
    } else if (step.toLowerCase().contains('train')) {
      icon = Icons.directions_railway_rounded;
      label = 'Train';
      bg = const Color(0xFF6A1B9A);
    } else if (step.toLowerCase().contains('bus')) {
      icon = Icons.directions_bus_filled_rounded;
      label = 'Bus';
      bg = const Color(0xFF1F2BDB);
    } else if (step.toLowerCase().contains('microbus')) {
      icon = Icons.airport_shuttle_rounded;
      label = 'Micro';
      bg = const Color(0xFF3949AB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bg.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: bg, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: bg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(TripOption trip) {
    final transfers = trip.steps.length > 1 ? trip.steps.length - 1 : 0;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RouteDetailsPage(
              trip: trip,
              segments: _buildSegmentsForTrip(trip),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTripMeta(Icons.access_time_rounded, '${trip.durationMinutes} min'),
                const SizedBox(width: 12),
                _buildTripMeta(Icons.payments_outlined, '${trip.price} EGP'),
                const SizedBox(width: 12),
                _buildTripMeta(Icons.swap_horiz, '$transfers transfer'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  '90',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2B63),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: trip.steps.map(_buildTransportIcon).toList(),
                ),
                const SizedBox(width: 10),
                const Text(
                  '09',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2B63),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              trip.title.toLowerCase(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<RouteSegment> _buildSegmentsForTrip(TripOption trip) {
    return [
      const RouteSegment(
        mode: 'walk',
        title: 'Walk',
        subtitle: 'User location -> Nearby stop',
        durationText: '8-10 min',
        distanceText: '0.7 km',
      ),
      ...trip.steps.map((step) {
        if (step.toLowerCase().contains('metro')) {
          return RouteSegment(
            mode: 'metro',
            title: 'Metro',
            subtitle: step,
            durationText: '18-22 min',
            distanceText: '8.5 km',
          );
        }
        if (step.toLowerCase().contains('microbus')) {
          return RouteSegment(
            mode: 'microbus',
            title: 'Microbus',
            subtitle: step,
            durationText: '12-16 min',
            distanceText: '5.2 km',
          );
        }
        if (step.toLowerCase().contains('bus')) {
          return RouteSegment(
            mode: 'bus',
            title: 'Bus',
            subtitle: step,
            durationText: '14-18 min',
            distanceText: '6.4 km',
          );
        }
        return RouteSegment(
          mode: 'walk',
          title: 'Walk',
          subtitle: step,
          durationText: '5-7 min',
          distanceText: '0.4 km',
        );
      }),
      const RouteSegment(
        mode: 'walk',
        title: 'Walk',
        subtitle: 'Final stop -> Destination',
        durationText: '4-6 min',
        distanceText: '0.3 km',
      ),
    ];
  }
}

class RouteDetailsPage extends StatelessWidget {
  const RouteDetailsPage({super.key, required this.trip, required this.segments});

  final TripOption trip;
  final List<RouteSegment> segments;

  @override
  Widget build(BuildContext context) {
    final transfers = trip.steps.length > 1 ? trip.steps.length - 1 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2BDB),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      BackButton(color: Colors.white),
                    ],
                  ),
                  const Text(
                    'Route Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _headerMeta('${trip.durationMinutes} min'),
                      const SizedBox(width: 10),
                      _headerMeta('${trip.price} EGP'),
                      const SizedBox(width: 10),
                      _headerMeta('$transfers transfer'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  itemCount: segments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (context, index) {
                    final segment = segments[index];
                    return _segmentTile(segment, isLast: index == segments.length - 1);
                  },
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => JourneyTrackingPage(segments: segments),
                    ),
                  );
                },
                icon: const Icon(Icons.navigation_outlined),
                label: const Text('Start Journey'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2C230),
                  foregroundColor: const Color(0xFF1F2B63),
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _headerMeta(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _segmentTile(RouteSegment segment, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _modeColor(segment.mode),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _modeIcon(segment.mode),
                color: Colors.white,
                size: 14,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: const Color(0xFFE2E4EA),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  segment.title,
                  style: TextStyle(
                    color: _modeColor(segment.mode),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  segment.subtitle,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  segment.durationText,
                  style: const TextStyle(
                    color: Color(0xFF1F2BDB),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  segment.distanceText,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _modeColor(String mode) {
    switch (mode) {
      case 'metro':
        return const Color(0xFFE53935);
      case 'bus':
        return const Color(0xFF1F2BDB);
      case 'microbus':
        return const Color(0xFF5E35B1);
      default:
        return const Color(0xFF9EA4B5);
    }
  }

  IconData _modeIcon(String mode) {
    switch (mode) {
      case 'metro':
        return Icons.train_rounded;
      case 'bus':
        return Icons.directions_bus_filled_rounded;
      case 'microbus':
        return Icons.airport_shuttle_rounded;
      default:
        return Icons.directions_walk_rounded;
    }
  }
}

class JourneyTrackingPage extends StatefulWidget {
  const JourneyTrackingPage({super.key, required this.segments});

  final List<RouteSegment> segments;

  @override
  State<JourneyTrackingPage> createState() => _JourneyTrackingPageState();
}

class _JourneyTrackingPageState extends State<JourneyTrackingPage> {
  int _completedSteps = 0;

  int get _totalSteps => widget.segments.length;
  int get _currentStepDisplay => (_completedSteps + 1).clamp(1, _totalSteps);
  double get _progress => _totalSteps == 0 ? 0 : _completedSteps / _totalSteps;

  String get _currentStepLabel {
    if (_completedSteps >= _totalSteps) return 'Journey completed';
    return widget.segments[_completedSteps].title;
  }

  void _advanceStep() {
    if (_completedSteps >= _totalSteps) return;
    setState(() {
      _completedSteps++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = (_progress * 100).round();
    final inProgressText = _completedSteps >= _totalSteps
        ? 'Arrived to destination'
        : '${widget.segments[_completedSteps].title} in progress...';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2BDB),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        BackButton(color: Colors.white),
                      ],
                    ),
                    const Text(
                      'Your Journey',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Step $_currentStepDisplay of $_totalSteps',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Progress',
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                          const Spacer(),
                          Text(
                            '$progressPercent%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 7,
                          backgroundColor: const Color(0xFFE6E8EF),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFF2C230),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2C230),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.navigation_outlined, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _completedSteps >= _totalSteps
                                    ? 'Trip complete'
                                    : '$_currentStepLabel',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2B63),
                                ),
                              ),
                            ),
                            if (_completedSteps < _totalSteps)
                              const Text(
                                'in progress...',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF1F2B63),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Journey Steps',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2B63),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: widget.segments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final segment = widget.segments[index];
                            final isDone = index < _completedSteps;
                            final isCurrent = index == _completedSteps;
                            return Row(
                              children: [
                                Icon(
                                  isDone
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 16,
                                  color: isDone
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFBFC4D1),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? const Color(0xFFF2C230)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      segment.title == 'Walk'
                                          ? '${segment.title} to next point'
                                          : segment.subtitle,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDone
                                            ? Colors.grey[600]
                                            : const Color(0xFF3A4256),
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE4E7F1)),
                        ),
                        child: const Text(
                          'This is a simulated journey based on static data.\nActual conditions may vary.',
                          style: TextStyle(fontSize: 10, color: Color(0xFF667085)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _advanceStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2BDB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _completedSteps >= _totalSteps
                        ? 'Journey Finished'
                        : 'Mark Next Point Reached',
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                inProgressText,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _routePreference = 'fastest';
  String _language = 'en';
  bool _notificationsEnabled = true;
  int _bottomNavIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2BDB),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BackButton(color: Colors.white),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Customize your experience',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _settingsSectionTitle('Route Preferences'),
              _settingsCard(
                children: [
                  _selectableRow(
                    icon: Icons.flash_on_outlined,
                    text: 'Fastest Route',
                    selected: _routePreference == 'fastest',
                    onTap: () => setState(() => _routePreference = 'fastest'),
                  ),
                  _selectableRow(
                    icon: Icons.sell_outlined,
                    text: 'Cheapest Route',
                    selected: _routePreference == 'cheapest',
                    onTap: () => setState(() => _routePreference = 'cheapest'),
                  ),
                  _selectableRow(
                    icon: Icons.compare_arrows_outlined,
                    text: 'Least Transfers',
                    selected: _routePreference == 'least_transfers',
                    onTap: () =>
                        setState(() => _routePreference = 'least_transfers'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _settingsSectionTitle('Language'),
              _settingsCard(
                children: [
                  _selectableRow(
                    icon: Icons.language,
                    text: 'English',
                    selected: _language == 'en',
                    onTap: () => setState(() => _language = 'en'),
                  ),
                  _selectableRow(
                    icon: Icons.language_outlined,
                    text: 'العربية (Arabic)',
                    selected: _language == 'ar',
                    onTap: () => setState(() => _language = 'ar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _settingsCard(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_none, size: 16),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2B63),
                              ),
                            ),
                            Text(
                              'Get route updates',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _notificationsEnabled,
                        activeColor: const Color(0xFFF2C230),
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _settingsCard(
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF1F2BDB),
                        child: Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2B63),
                              ),
                            ),
                            Text(
                              'Manage your account',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (value) {
          setState(() {
            _bottomNavIndex = value;
          });
          if (value == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        selectedItemColor: const Color(0xFFF2C230),
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _settingsSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _selectableRow({
    required IconData icon,
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2C230) : const Color(0xFFF9FAFC),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? const Color(0xFF1F2B63) : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? const Color(0xFF1F2B63)
                      : const Color(0xFF374151),
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 14,
              color: selected ? const Color(0xFF1F2B63) : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
