import 'package:flutter/material.dart';
import '../../core/localization.dart';
import '../../metro_graph.dart';
import '../../models/trip_option.dart';
import '../../routing_service.dart';
import '../../providers/app_route_preference_scope.dart';
import '../../providers/app_language_scope.dart';
import '../../public_transport_service.dart';
import '../journey/route_details_page.dart';
import '../settings/settings_page.dart';
import 'package:shimmer/shimmer.dart';

class SearchTripsPage extends StatefulWidget {
  const SearchTripsPage({super.key, required this.fromId, required this.toId, required this.allowedModes});

  final String fromId;
  final String toId;
  final Set<String> allowedModes;

  @override
  State<SearchTripsPage> createState() => _SearchTripsPageState();
}
class _SearchTripsPageState extends State<SearchTripsPage> {
  int _bottomNavIndex = 0;
  bool _isLoading = true;
  List<TripOption> _allTrips = [];
  Map<TripOption, List<RouteSegment>> _tripSegments = {};

  @override
  void initState() {
    super.initState();
    _calculateRoutes();
  }
  
  Future<void> _calculateRoutes() async {
    setState(() => _isLoading = true);
    _allTrips = [];
    _tripSegments = {};

    // 1. Try dynamic routing first (OSRM + Nominatim)
    try {
      final startLatLng = await PublicTransportService.geocode(widget.fromId);
      final endLatLng = await PublicTransportService.geocode(widget.toId);

      if (startLatLng != null && endLatLng != null) {
        final dynamicResult = await PublicTransportService.getMultiModalRoute(startLatLng, endLatLng);
        
        final segments = <RouteSegment>[];
        if (dynamicResult['walkPoints']!.isNotEmpty) {
          segments.add(RouteSegment(mode: 'walk', title: tr(context, 'مشي', 'Walk'), subtitle: 'إلى المحطة', durationMinutes: 5, distanceText: '0.5 كم', pathPoints: dynamicResult['walkPoints']!));
        }
        if (dynamicResult['metroPoints']!.isNotEmpty) {
          segments.add(RouteSegment(mode: 'metro', title: tr(context, 'مترو الأنفاق', 'Metro'), subtitle: 'مسار سريع', durationMinutes: 20, distanceText: '10 كم', pathPoints: dynamicResult['metroPoints']!));
        }
        if (dynamicResult['busPoints']!.isNotEmpty) {
          segments.add(RouteSegment(mode: 'bus', title: tr(context, 'أتوبيس', 'Bus'), subtitle: 'الوجهة النهائية', durationMinutes: 15, distanceText: '5 كم', pathPoints: dynamicResult['busPoints']!));
        }

        if (segments.isNotEmpty) {
          final trip = TripOption(
            title: tr(context, 'مسار ذكي (OSM)', 'Smart Route (OSM)'),
            durationMinutes: segments.fold(0, (s, e) => s + e.durationMinutes),
            price: 15,
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(tr(context, 'سيتوفر حفظ المسارات قريبا', 'Saved routes coming soon'))),
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
    // الوقت يُحسب مرة واحدة هنا قبل بناء الـ UI
    final now = DateTime.now();
    final depH = now.hour.toString().padLeft(2, '0');
    final depM = now.minute.toString().padLeft(2, '0');
    final arrival = now.add(Duration(minutes: trip.durationMinutes));
    final arrH = arrival.hour.toString().padLeft(2, '0');
    final arrM = arrival.minute.toString().padLeft(2, '0');

    final isDark = Theme.of(context).brightness == Brightness.dark;
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