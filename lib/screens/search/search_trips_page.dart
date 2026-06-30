import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization.dart';
import '../../metro_graph.dart';
import '../../models/trip_option.dart';
import '../../routing_service.dart';
import '../../providers/app_route_preference_scope.dart';
import '../../providers/app_language_scope.dart';
import '../../public_transport_service.dart';
import '../../public_transport_data.dart';
import '../journey/route_details_page.dart';
import '../saved/saved_routes_page.dart';
import '../settings/settings_page.dart';
import 'package:shimmer/shimmer.dart';

class SearchTripsPage extends StatefulWidget {
  const SearchTripsPage({
    super.key,
    required this.fromId,
    required this.toId,
    required this.allowedModes,
    this.fromLatLng,
    this.toLatLng,
  });

  final String fromId;
  final String toId;
  final Set<String> allowedModes;
  final LatLng? fromLatLng;
  final LatLng? toLatLng;

  @override
  State<SearchTripsPage> createState() => _SearchTripsPageState();
}
class _SearchTripsPageState extends State<SearchTripsPage> {
  int _bottomNavIndex = 0;
  bool _isLoading = true;
  List<TripOption> _allTrips = [];
  Map<TripOption, List<RouteSegment>> _tripSegments = {};
  Set<String> _savedTripTitles = {}; // ✅ المسارات المحفوظة

  double _calculatePathDistance(List<LatLng> points) {
    double totalMeters = 0;
    final distanceCalc = const Distance();
    for (int i = 0; i < points.length - 1; i++) {
      totalMeters += distanceCalc.as(LengthUnit.Meter, points[i], points[i + 1]);
    }
    return totalMeters;
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} م';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} كم';
    }
  }

  @override
  void initState() {
    super.initState();
    _calculateRoutes();
    _loadSavedTrips();
  }

  // ✅ تحميل المسارات المحفوظة
  Future<void> _loadSavedTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_trips') ?? [];
    if (mounted) {
      setState(() => _savedTripTitles = saved.toSet());
    }
  }

  // ✅ حفظ/إلغاء حفظ مسار - مع منع تراكم الـ SnackBars
  Future<void> _toggleSaveTrip(TripOption trip) async {
    final key = '${trip.title}_${trip.durationMinutes}_${trip.price}';
    final isSaved = _savedTripTitles.contains(key);

    if (isSaved) {
      await SavedRoutesHelper.removeRoute(key);
      if (mounted) setState(() => _savedTripTitles.remove(key));
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars() // ✅ مسح القديم فوراً
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.grey[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text(
                tr(context, 'تم إلغاء حفظ المسار', 'Route removed from saved'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
      }
    } else {
      // استخراج وسائل النقل من الـ segments
      final segments = _tripSegments[trip] ?? [];
      final modes = segments
          .map((s) => s.mode)
          .toSet()
          .toList();

      await SavedRoutesHelper.saveRoute(
        key: key,
        title: trip.title,
        durationMinutes: trip.durationMinutes,
        price: trip.price,
        modes: modes,
      );
      if (mounted) setState(() => _savedTripTitles.add(key));
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars() // ✅ مسح القديم فوراً
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF1F2BDB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text(
                tr(context, '✅ تم حفظ المسار! اضغط على "محفوظات" للعرض', '✅ Route saved! Go to "Saved" tab to view'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
      }
    }
  }
  
  Future<void> _calculateRoutes() async {
    setState(() => _isLoading = true);
    _allTrips = [];
    _tripSegments = {};

    // 1. Try dynamic routing first (OSRM + Nominatim)
    try {
      final startLatLng = widget.fromLatLng ?? await PublicTransportService.geocode(widget.fromId);
      final endLatLng = widget.toLatLng ?? await PublicTransportService.geocode(widget.toId);

      if (startLatLng != null && endLatLng != null) {
        final dynamicResult = await PublicTransportService.getMultiModalRoute(
          startLatLng,
          endLatLng,
          allowedModes: widget.allowedModes,
        );
        
        final segments = <RouteSegment>[];
        if (dynamicResult['walkPoints1'] != null && dynamicResult['walkPoints1']!.isNotEmpty) {
          final startName = _getDisplayName(context, widget.fromId);
          final endName = _getClosestStopName(dynamicResult['walkPoints1']!.last);
          final distMeters = _calculatePathDistance(dynamicResult['walkPoints1']!);
          final durationMin = (distMeters / 80).round().clamp(1, 120); // 80 m/min = 4.8 km/h
          
          segments.add(RouteSegment(
            mode: 'walk',
            title: tr(context, 'مشي', 'Walk'),
            subtitle: '$startName ← $endName',
            durationMinutes: durationMin,
            distanceText: _formatDistance(distMeters),
            pathPoints: dynamicResult['walkPoints1']!,
          ));
        }
        if (dynamicResult['metroPoints'] != null && dynamicResult['metroPoints']!.isNotEmpty) {
          final startName = _getClosestStopName(dynamicResult['metroPoints']!.first);
          final endName = _getClosestStopName(dynamicResult['metroPoints']!.last);
          final distMeters = _calculatePathDistance(dynamicResult['metroPoints']!);
          final durationMin = (distMeters / 400).round().clamp(2, 120); // 400 m/min = 24 km/h
          
          segments.add(RouteSegment(
            mode: 'metro',
            title: tr(context, 'مترو الأنفاق', 'Metro'),
            subtitle: '$startName ← $endName',
            durationMinutes: durationMin,
            distanceText: _formatDistance(distMeters),
            pathPoints: dynamicResult['metroPoints']!,
          ));
        }
        if (dynamicResult['busPoints'] != null && dynamicResult['busPoints']!.isNotEmpty) {
          final startName = _getClosestStopName(dynamicResult['busPoints']!.first);
          final endName = _getDisplayName(context, widget.toId);
          final distMeters = _calculatePathDistance(dynamicResult['busPoints']!);
          final durationMin = (distMeters / 300).round().clamp(2, 120); // 300 m/min = 18 km/h
          
          segments.add(RouteSegment(
            mode: 'bus',
            title: tr(context, 'أتوبيس', 'Bus'),
            subtitle: '$startName ← $endName',
            durationMinutes: durationMin,
            distanceText: _formatDistance(distMeters),
            pathPoints: dynamicResult['busPoints']!,
          ));
        }
        if (dynamicResult['walkPoints2'] != null && dynamicResult['walkPoints2']!.isNotEmpty) {
          final startName = _getClosestStopName(dynamicResult['walkPoints2']!.first);
          final endName = _getDisplayName(context, widget.toId);
          final distMeters = _calculatePathDistance(dynamicResult['walkPoints2']!);
          final durationMin = (distMeters / 80).round().clamp(1, 120); // 80 m/min = 4.8 km/h
          
          segments.add(RouteSegment(
            mode: 'walk',
            title: tr(context, 'مشي للوجهة', 'Walk to destination'),
            subtitle: '$startName ← $endName',
            durationMinutes: durationMin,
            distanceText: _formatDistance(distMeters),
            pathPoints: dynamicResult['walkPoints2']!,
          ));
        }

        if (segments.isNotEmpty) {
          final isWalkOnly = widget.allowedModes.contains('walk') && widget.allowedModes.length == 1;
          final trip = TripOption(
            title: isWalkOnly
                ? tr(context, 'مسار مشي فقط', 'Walk Only Route')
                : tr(context, 'مسار ذكي (OSM)', 'Smart Route (OSM)'),
            durationMinutes: segments.fold(0, (s, e) => s + e.durationMinutes),
            price: isWalkOnly ? 0 : 15,
            steps: segments.map((e) => e.title).toList(),
          );
          _allTrips.add(trip);
          _tripSegments[trip] = segments;
        }
      }
    } catch (e) {
      print('Dynamic routing error: $e');
    }

    // 2. Fallback to static routing
    final smartResults = RoutingService.findSmartRoutes(
      widget.fromId,
      widget.toId,
      allowedModes: const {'bus', 'metro', 'microbus', 'train'},
    );
    
    for (final res in smartResults) {
      final trip = TripOption(
        title: res.steps.first,
        durationMinutes: res.durationMinutes,
        price: res.price,
        steps: res.steps,
      );
      _allTrips.add(trip);
      _tripSegments[trip] = res.segments;
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<TripOption> _filteredTrips(String routePreference) {
    var trips = _allTrips.where((trip) {
      final segments = _tripSegments[trip] ?? [];
      for (final seg in segments) {
        if (seg.mode == 'walk') continue;
        if (!widget.allowedModes.contains(seg.mode)) return false;
      }
      return true;
    }).toList();

    trips.sort((a, b) {
      if (routePreference == 'fastest') {
        return a.durationMinutes.compareTo(b.durationMinutes);
      }
      if (routePreference == 'cheapest') {
        if (a.price != b.price) return a.price.compareTo(b.price);
        return a.durationMinutes.compareTo(b.durationMinutes);
      }
      // least_transfers
      final segsA = (_tripSegments[a] ?? []).where((s) => s.mode != 'walk').length;
      final segsB = (_tripSegments[b] ?? []).where((s) => s.mode != 'walk').length;
      if (segsA != segsB) return segsA.compareTo(segsB);
      return a.durationMinutes.compareTo(b.durationMinutes);
    });
    return trips;
  }

  @override
  Widget build(BuildContext context) {
    final routePreference = AppRoutePreferenceScope.notifierOf(context).value;
    final trips = _filteredTrips(routePreference);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading 
          ? _buildShimmerLoading(isDark)
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopHeader(trips.length, routePreference),
                const SizedBox(height: 12),
                if (trips.isEmpty)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(tr(context, 'لا توجد مسارات مطابقة للفلاتر المختارة.', 'No routes match selected filters.')),
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
            // ✅ عرض المسارات المحفوظة
            if (_savedTripTitles.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF1F2BDB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Text(tr(context, 'لا توجد مسارات محفوظة بعد. اضغط على 🔖 لحفظ مسار.', 'No saved routes yet. Tap 🔖 to save a route.')),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Text(tr(context, 'لديك ${_savedTripTitles.length} مسار محفوظ ✅', 'You have ${_savedTripTitles.length} saved route(s) ✅')),
                ),
              );
            }
            setState(() => _bottomNavIndex = 0); // الرجوع للتاب الأول
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
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), label: tr(context, 'الرئيسية', 'Home')),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bookmark_border_rounded),
            label: tr(context, 'المحفوظات', 'Saved'),
          ),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: tr(context, 'الإعدادات', 'Settings')),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 60, height: 16, color: Colors.white),
                    const SizedBox(width: 12),
                    Container(width: 60, height: 16, color: Colors.white),
                    const SizedBox(width: 12),
                    Container(width: 60, height: 16, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(width: 40, height: 16, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Container(width: 40, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                          const SizedBox(width: 8),
                          Container(width: 40, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(width: 40, height: 16, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 12),
                Container(width: 100, height: 12, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopHeader(int tripsCount, String routePreference) {
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
                    _buildSortChip(
                      label: tr(context, 'الأسرع', 'Fastest'),
                      value: 'fastest',
                      routePreference: routePreference,
                    ),
                    _buildSortChip(
                      label: tr(context, 'الأوفر', 'Cheapest'),
                      value: 'cheapest',
                      routePreference: routePreference,
                    ),
                    _buildSortChip(
                      label: tr(context, 'أقل تبديلات', 'Least Transfers'),
                      value: 'least_transfers',
                      routePreference: routePreference,
                    ),
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
            tr(context, '$tripsCount مسار متاح', '$tripsCount routes found'),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_getDisplayName(context, widget.fromId)}  ←  ${_getDisplayName(context, widget.toId)}',
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

  String _getDisplayName(BuildContext context, String id) {
    final isAr = AppLanguageScope.notifierOf(context).value == 'ar';
    final station = MetroGraph.stations[id];
    if (station != null) {
      return isAr ? station.nameAr : station.nameEn;
    }
    return id; // Return raw input if it's not a metro station ID
  }

  String _getClosestStopName(LatLng point) {
    final isAr = AppLanguageScope.notifierOf(context).value == 'ar';
    double minDistance = double.maxFinite;
    String closestName = '';
    bool closestIsPreferredLang = false;

    bool isPreferredLanguage(String text) {
      final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
      return isAr ? hasArabic : !hasArabic;
    }

    // 1. Check Metro stations
    for (final s in MetroGraph.stations.values) {
      final dist = (s.location.latitude - point.latitude).abs() + (s.location.longitude - point.longitude).abs();
      final name = isAr ? s.nameAr : s.nameEn;
      if (dist < minDistance) {
        minDistance = dist;
        closestName = name;
        closestIsPreferredLang = isPreferredLanguage(name);
      } else if ((dist - minDistance).abs() < 0.0001) {
        if (!closestIsPreferredLang && isPreferredLanguage(name)) {
          closestName = name;
          closestIsPreferredLang = true;
        }
      }
    }

    // 2. Check Bus regions / stop coordinates from PublicTransportData.regionCoords
    for (final entry in PublicTransportData.regionCoords.entries) {
      final name = entry.key;
      final loc = entry.value;
      final dist = (loc.latitude - point.latitude).abs() + (loc.longitude - point.longitude).abs();
      
      if (dist < minDistance) {
        minDistance = dist;
        closestName = name;
        closestIsPreferredLang = isPreferredLanguage(name);
      } else if ((dist - minDistance).abs() < 0.0001) {
        if (!closestIsPreferredLang && isPreferredLanguage(name)) {
          closestName = name;
          closestIsPreferredLang = true;
        }
      }
    }

    return closestName.isNotEmpty ? closestName : (isAr ? 'محطة غير معروفة' : 'Unknown Station');
  }

  Widget _buildSortChip({
    required String label,
    required String value,
    required String routePreference,
  }) {
    final selected = routePreference == value;
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
      onSelected: (_) => AppRoutePreferenceScope.notifierOf(context).value = value,
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
    String label = tr(context, 'مشي', 'Walk');
    Color bg = const Color(0xFF9EA4B5);
    if (step.toLowerCase().contains('metro')) {
      icon = Icons.train_rounded;
      label = tr(context, 'مترو', 'Metro');
      bg = const Color(0xFFE53935);
    } else if (step.toLowerCase().contains('train')) {
      icon = Icons.directions_railway_rounded;
      label = tr(context, 'قطار', 'Train');
      bg = const Color(0xFF6A1B9A);
    } else if (step.toLowerCase().contains('bus')) {
      icon = Icons.directions_bus_filled_rounded;
      label = tr(context, 'أتوبيس', 'Bus');
      bg = const Color(0xFF1F2BDB);
    } else if (step.toLowerCase().contains('microbus')) {
      icon = Icons.airport_shuttle_rounded;
      label = tr(context, 'ميكروباص', 'Microbus');
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

  Widget _buildModeIcon(String mode) {
    final IconData icon;
    final String label;
    final Color bg;
    switch (mode) {
      case 'metro':
        icon = Icons.train_rounded;
        label = tr(context, 'مترو', 'Metro');
        bg = const Color(0xFFE53935);
        break;
      case 'bus':
        icon = Icons.directions_bus_filled_rounded;
        label = tr(context, 'أتوبيس', 'Bus');
        bg = const Color(0xFF1F2BDB);
        break;
      case 'microbus':
        icon = Icons.airport_shuttle_rounded;
        label = tr(context, 'ميكروباص', 'Microbus');
        bg = const Color(0xFF3949AB);
        break;
      case 'train':
        icon = Icons.directions_railway_rounded;
        label = tr(context, 'قطار', 'Train');
        bg = const Color(0xFF6A1B9A);
        break;
      default:
        icon = Icons.directions_walk;
        label = tr(context, 'مشي', 'Walk');
        bg = const Color(0xFF9EA4B5);
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
          Text(label, style: TextStyle(color: bg, fontSize: 11, fontWeight: FontWeight.w700)),
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
    final now = DateTime.now();
    final depH = now.hour.toString().padLeft(2, '0');
    final depM = now.minute.toString().padLeft(2, '0');
    final arrival = now.add(Duration(minutes: trip.durationMinutes));
    final arrH = arrival.hour.toString().padLeft(2, '0');
    final arrM = arrival.minute.toString().padLeft(2, '0');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tripKey = '${trip.title}_${trip.durationMinutes}_${trip.price}';
    final isSaved = _savedTripTitles.contains(tripKey);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RouteDetailsPage(
              trip: trip,
              segments: _tripSegments[trip] ?? [],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDark ? [] : [
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
                _buildTripMeta(
                  Icons.access_time_rounded,
                  tr(context, '${trip.durationMinutes} دقيقة', '${trip.durationMinutes} min'),
                ),
                const SizedBox(width: 12),
                _buildTripMeta(
                  Icons.payments_outlined,
                  tr(context, '${trip.price} ج.م', '${trip.price} EGP'),
                ),
                const SizedBox(width: 12),
                _buildTripMeta(
                  Icons.swap_horiz,
                  tr(context, '$transfers تبديل', '$transfers transfer'),
                ),
                const Spacer(),
                // ✅ زرار حفظ المسار
                GestureDetector(
                  onTap: () => _toggleSaveTrip(trip),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      key: ValueKey(isSaved),
                      color: isSaved ? const Color(0xFFF2C230) : Colors.grey,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '$depH:$depM',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1F2B63),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_tripSegments[trip] ?? [])
                        .where((seg) => seg.mode != 'walk')
                        .map((seg) => _buildModeIcon(seg.mode))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$arrH:$arrM',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1F2B63),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _localizedTripTitle(trip.title),
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

  String _localizedTripTitle(String title) {
    switch (title) {
      case 'Economy Route':
      case 'مسار اقتصادي':
        return tr(context, 'مسار اقتصادي', 'Economy Route');
      case 'Fastest Route':
      case 'أسرع مسار':
        return tr(context, 'أسرع مسار', 'Fastest Route');
      case 'Balanced Route':
      case 'مسار متوازن':
        return tr(context, 'مسار متوازن', 'Balanced Route');
      case 'Few Transfers':
      case 'أقل تبديلات':
        return tr(context, 'أقل تبديلات', 'Few Transfers');
      default:
        return title;
    }
  }

  String _localizedStepText(String step, BuildContext context) {
    final lower = step.toLowerCase();
    if (lower.startsWith('bus ')) {
      final number = step.split(' ').last;
      return tr(context, 'أتوبيس $number', 'Bus $number');
    }
    if (lower.startsWith('metro line ')) {
      final line = step.split(' ').last;
      return tr(context, 'المترو الخط $line', 'Metro Line $line');
    }
    if (lower.startsWith('train line ')) {
      final line = step.split(' ').last;
      return tr(context, 'القطار الخط $line', 'Train Line $line');
    }
    if (lower.startsWith('microbus ')) {
      final number = step.split(' ').last;
      return tr(context, 'ميكروباص $number', 'Microbus $number');
    }
    if (lower.startsWith('walk ')) {
      final minutes = step.split(' ').skip(1).join(' ');
      return tr(context, 'مشي $minutes', 'Walk $minutes');
    }
    return step;
  }
}