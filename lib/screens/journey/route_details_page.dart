import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization.dart';
import '../../metro_graph.dart';
import '../../models/recent_trip.dart';
import '../../models/trip_option.dart';
import '../../routing_service.dart';
import 'journey_tracking_page.dart';

class RouteDetailsPage extends StatelessWidget {
  const RouteDetailsPage({super.key, required this.trip, required this.segments});

  final TripOption trip;
  final List<RouteSegment> segments;

  @override
  Widget build(BuildContext context) {
    final transfers = trip.steps.length > 1 ? trip.steps.length - 1 : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F8),
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
                  Text(
                    tr(context, 'تفاصيل المسار', 'Route Details'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _headerMeta(tr(context, '${trip.durationMinutes} دقيقة', '${trip.durationMinutes} min')),
                      const SizedBox(width: 10),
                      _headerMeta(tr(context, '${trip.price} ج.م', '${trip.price} EGP')),
                      const SizedBox(width: 10),
                      _headerMeta(tr(context, '$transfers تبديل', '$transfers transfer')),
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
                  children: [
                    _routeSketchCard(context),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        itemCount: segments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 2),
                        itemBuilder: (context, index) {
                          final segment = segments[index];
                          return _segmentTile(segment, isLast: index == segments.length - 1);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: ElevatedButton.icon(
                onPressed: () async {
                  // ── حفظ الرحلة في السجل المحلي ──
                  if (segments.isNotEmpty) {
                    final fromSeg = segments.first;
                    final toSeg = segments.last;
                    final newTrip = RecentTrip(
                      fromName: fromSeg.title,
                      toName: toSeg.subtitle,
                      durationMinutes: trip.durationMinutes,
                      price: trip.price,
                      date: DateTime.now(),
                    );
                    final prefs = await SharedPreferences.getInstance();
                    final raw = prefs.getString('recent_trips') ?? '[]';
                    final existing = RecentTrip.decodeList(raw);
                    existing.insert(0, newTrip);
                    if (existing.length > 5) existing.removeLast();
                    await prefs.setString('recent_trips', RecentTrip.encodeList(existing));
                  }
                  // ── الانتقال لشاشة التتبع ──
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JourneyTrackingPage(segments: segments),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.navigation_outlined),
                label: Text(tr(context, 'ابدأ الرحلة', 'Start Journey')),
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

  Widget _routeSketchCard(BuildContext context) {
    final startPoint = const LatLng(29.9792, 31.1342); // Pyramids area start
    final endPoint = const LatLng(30.1219, 31.4056);   // Airport

    final polylines = <Polyline>[];
    final markerPoints = <LatLng>[];

    for (final segment in segments) {
      if (segment.pathPoints.isNotEmpty) {
        polylines.add(
          Polyline(
            points: segment.pathPoints,
            color: _modeColor(segment.mode),
            strokeWidth: 5.0,
            isDotted: segment.mode == 'walk',
          ),
        );
        markerPoints.add(segment.pathPoints.first);
        markerPoints.add(segment.pathPoints.last);
      }
    }

    final initialCenter = markerPoints.isNotEmpty ? markerPoints.first : const LatLng(30.0500, 31.2500);

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: Theme.of(context).brightness == Brightness.dark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 12.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_app',
            ),
            PolylineLayer(
              polylines: polylines,
            ),
            MarkerLayer(
              markers: [
                if (markerPoints.isNotEmpty)
                  Marker(
                    point: markerPoints.first,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 3),
                      ),
                    ),
                  ),
                if (markerPoints.isNotEmpty)
                  Marker(
                    point: markerPoints.last,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 3),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _modeLabel(BuildContext context, String mode) {
    switch (mode) {
      case 'metro':
        return tr(context, 'مترو', 'Metro');
      case 'train':
        return tr(context, 'قطار', 'Train');
      case 'bus':
        return tr(context, 'أتوبيس', 'Bus');
      case 'microbus':
        return tr(context, 'ميكروباص', 'Microbus');
      default:
        return tr(context, 'مشي', 'Walk');
    }
  }

  Widget _segmentTile(RouteSegment segment, {required bool isLast}) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
                color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E4EA),
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
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${segment.durationMinutes} دقيقة',
                  style: const TextStyle(
                    color: Color(0xFF1F2BDB),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  segment.distanceText,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    });
  }

  Color _modeColor(String mode) {
    switch (mode) {
      case 'metro':
        return const Color(0xFFE53935);
      case 'train':
        return const Color(0xFF6A1B9A);
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
      case 'train':
        return Icons.directions_railway_rounded;
      case 'bus':
        return Icons.directions_bus_filled_rounded;
      case 'microbus':
        return Icons.airport_shuttle_rounded;
      default:
        return Icons.directions_walk_rounded;
    }
  }
}