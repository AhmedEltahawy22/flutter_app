import 'package:flutter/material.dart';
import 'package:flutter_app/metro_graph.dart';
import 'package:flutter_app/public_transport_data.dart';
import 'package:flutter_app/osm_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

class RouteSegment {
  final String mode;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final String distanceText;
  final List<LatLng> pathPoints;

  const RouteSegment({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.distanceText,
    required this.pathPoints,
  });
}

class MetroRouteResult {
  final int durationMinutes;
  final int price;
  final List<String> steps;
  final List<RouteSegment> segments;

  const MetroRouteResult({
    required this.durationMinutes,
    required this.price,
    required this.steps,
    required this.segments,
  });
}

class _Edge {
  final String from;
  final String to;
  final String routeId;
  final String nameAr;
  final String mode;
  final int duration;
  final double fare;
  final double km;
  final String? metroLine; // خط المترو الخاص بهذا الاتصال

  const _Edge({
    required this.from,
    required this.to,
    required this.routeId,
    required this.nameAr,
    required this.mode,
    required this.duration,
    required this.fare,
    required this.km,
    this.metroLine,
  });
}

class _State {
  final String node;
  final List<_Edge> path;
  final int duration;
  final double fare;
  final String? currentMetroLine; // خط المترو الحالي (لتتبع تبديل الخطوط)
  const _State(this.node, this.path, this.duration, this.fare, [this.currentMetroLine]);
}

class RoutingService {
  static bool _initialized = false;
  static final Map<String, List<_Edge>> _graph = {};

  static void _ensureInit() {
    if (_initialized) return;
    _initialized = true;
    MetroGraph.init(); // Make sure metro connections are built

    // Add bus and microbus routes (bidirectional)
    for (final r in PublicTransportData.routes) {
      if (r.fromAr.isEmpty || r.toAr.isEmpty) continue;
      final mode = (r.vehicleType == 'ميكروباص' || r.id.startsWith('MIC-')) ? 'microbus' : 'bus';
      _addEdge(_Edge(from: r.fromAr, to: r.toAr, routeId: r.id, nameAr: r.nameAr, mode: mode, duration: r.durationMinutes, fare: r.fareEgp, km: r.lengthKm));
      _addEdge(_Edge(from: r.toAr, to: r.fromAr, routeId: r.id, nameAr: r.nameAr, mode: mode, duration: r.durationMinutes, fare: r.fareEgp, km: r.lengthKm));
    }

    // Add metro connections from MetroGraph
    for (final entry in MetroGraph.connections.entries) {
      final fromId = entry.key;
      for (final toId in entry.value) {
        // تحديد الخط المشترك بين المحطتين
        final fromStation = MetroGraph.stations[fromId];
        final toStation = MetroGraph.stations[toId];
        String? sharedLine;
        if (fromStation != null && toStation != null) {
          for (final line in fromStation.lines) {
            if (toStation.lines.contains(line)) {
              sharedLine = line;
              break;
            }
          }
        }
        _addEdge(_Edge(
          from: fromId, to: toId, routeId: 'metro',
          nameAr: 'مترو الأنفاق', mode: 'metro',
          duration: 2, fare: 0, km: 1.2,
          metroLine: sharedLine,
        ));
      }
    }

    // Bridge: walk from bus regions to nearby metro stations
    const bridges = {
      'المنيرة': 'sadat',
      'السيدة زينب': 'al_sayeda_zeinab',
      'دار السلام': 'dar_el_salam',
      'الدقي': 'dokki',
      'شبرا': 'al_shohadaa',
      'شبرا الخيمة': 'shubra_el_kheima',
      'رمسيس': 'al_shohadaa',
      'الأزبكية': 'attaba',
      'باب الشعرية': 'bab_el_shaaria',
      'الجمالية': 'attaba',
      'العباسية': 'abbassia',
      'قصر النيل': 'sadat',
      'جاردن سيتي': 'sadat',
      'كورنيش النيل': 'sadat',
      'المعادي': 'maadi',
      'حلوان': 'helwan',
      'مصر القديمة': 'mar_girgis',
      'الهرم': 'giza',
      'إمبابة': 'imbaba',
      'السلام': 'ain_shams',
      'عين شمس': 'ain_shams',
      'عين شمس الشرقية': 'ain_shams',
      'المرج': 'el_marg',
      'بدر': 'el_marg',
      'النزهة': 'el_nozha',
      'عباس العقاد': 'abbassia',
      'المقطم': 'abbassia',
      'القلعة': 'al_sayeda_zeinab',
      'الهايكستب': 'el_haykestep',
      'مدينة نصر': 'fair_zone',
      // الجيزة وضواحيها (خط 2)
      'الجيزة': 'giza',
      'فيصل': 'faisal',
      'جامعة القاهرة': 'cairo_university',
      'الجامعة': 'cairo_university',
      'البحوث': 'el_bohoth',
      'المنيب': 'el_mounib',
      'ساقية مكي': 'sakiat_mekki',
      'أم المصريين': 'omm_el_misryeen',
      // المهندسين ووسط البلد (خط 2)
      'المهندسين': 'dokki',
      'العجوزة': 'dokki',
      'الأوبرا': 'opera',
      'وسط البلد': 'sadat',
      'التحرير': 'sadat',
      'ميدان التحرير': 'sadat',
      'عابدين': 'sadat',
      'محمد نجيب': 'mohamed_naguib',
      // مصر الجديدة وهليوبوليس (خط 3)
      'مصر الجديدة': 'nadi_el_shams',
      'هليوبوليس': 'heliopolis_square',
      'ميدان هليوبوليس': 'heliopolis_square',
      'المطار': 'el_nozha',
      'المطرية': 'el_matareyya',
      'حدائق الزيتون': 'hadayek_el_zaitoun',
      'حلمية الزيتون': 'helmeyet_el_zaitoun',
      // الزمالك والجزيرة
      'الزمالك': 'opera',
      'المنيل': 'al_sayeda_zeinab',
      'روض الفرج': 'road_el_farag',
      // شبرا وضواحيها
      'غمرة': 'ghamra',
      'السبتية': 'ghamra',
      'الزاوية الحمراء': 'al_shohadaa',
      // مناطق متفرقة
      'الكيت كات': 'kit_kat',
      'السودان': 'sudan',
      'الطريق الدائري': 'ring_road',
      'حدائق القبة': 'hadayek_el_zaitoun',
      'كوبري القبة': 'kobri_el_qobba',
      'سراي القبة': 'saray_el_qobba',
      'عدلي منصور': 'adly_mansour',
      'عين حلوان': 'ain_helwan',
      'وادي حوف': 'wadi_hof',
      'عزبة النخل': 'ezbet_el_nakhl',
      'منشية الصدر': 'manshiet_el_sadr',
    };

    for (final entry in bridges.entries) {
      final region = entry.key;
      final stationId = entry.value;
      if (!MetroGraph.stations.containsKey(stationId)) continue;
      final station = MetroGraph.stations[stationId]!;
      _addEdge(_Edge(from: region, to: stationId, routeId: 'walk', nameAr: 'مشي لمحطة ${station.nameAr}', mode: 'walk', duration: 7, fare: 0, km: 0.5));
      _addEdge(_Edge(from: stationId, to: region, routeId: 'walk', nameAr: 'مشي لـ $region', mode: 'walk', duration: 7, fare: 0, km: 0.5));
    }
  }

  static void _addEdge(_Edge e) {
    _graph.putIfAbsent(e.from, () => []).add(e);
  }

  static String normalize(String s) {
    return s.trim().toLowerCase()
        .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه').replaceAll('ى', 'ي');
  }

  static String? _findNode(String input) {
    final n = normalize(input);

    // 1. Exact match
    for (final node in _graph.keys) {
      if (normalize(node) == n) return node;
    }

    // 2. Substring match
    for (final node in _graph.keys) {
      final nn = normalize(node);
      if (nn.contains(n) || n.contains(nn)) return node;
    }

    // 3. Metro station match
    for (final s in MetroGraph.stations.values) {
      final na = normalize(s.nameAr);
      final ne = normalize(s.nameEn);
      if (na == n || ne == n || na.contains(n) || n.contains(na)) return s.id;
    }

    // 4. Fuzzy: strip trailing vowels and match prefix (handles شبرة vs شبرا)
    final stripped = n.replaceAll(RegExp(r'[اهيو]+$'), '');
    if (stripped.length >= 3) {
      for (final node in _graph.keys) {
        final nn = normalize(node).replaceAll(RegExp(r'[اهيو]+$'), '');
        if (nn == stripped || nn.startsWith(stripped) || stripped.startsWith(nn)) return node;
      }
      for (final s in MetroGraph.stations.values) {
        final na = normalize(s.nameAr).replaceAll(RegExp(r'[اهيو]+$'), '');
        if (na == stripped || na.startsWith(stripped) || stripped.startsWith(na)) return s.id;
      }
    }

    return null;
  }

  // Dijkstra by duration
  static _State? _dijkstra(String start, String end, Set<String> modes) {
    final queue = [_State(start, [], 0, 0, null)];
    final visited = <String>{};

    while (queue.isNotEmpty) {
      queue.sort((a, b) => a.duration.compareTo(b.duration));
      final cur = queue.removeAt(0);
      if (visited.contains(cur.node)) continue;
      visited.add(cur.node);

      if (cur.node == end) return cur;

      for (final edge in _graph[cur.node] ?? <_Edge>[]) {
        if (visited.contains(edge.to)) continue;
        // Allow walk always, filter other modes
        if (edge.mode != 'walk' && !modes.contains(edge.mode)) continue;

        // حساب وقت عقوبة التبديل عند تغيير خط المترو
        int extraTime = 0;
        String? newMetroLine = cur.currentMetroLine;

        if (edge.mode == 'metro' && edge.metroLine != null) {
          if (cur.currentMetroLine != null &&
              cur.currentMetroLine != edge.metroLine) {
            // تبديل خط مترو → إضافة 5 دقائق وقت التبادل داخل المحطة التبادلية
            extraTime = 5;
          }
          newMetroLine = edge.metroLine;
        } else if (edge.mode != 'metro') {
          newMetroLine = null; // إعادة ضبط عند مغادرة المترو
        }

        queue.add(_State(
          edge.to,
          [...cur.path, edge],
          cur.duration + edge.duration + extraTime,
          cur.fare + edge.fare,
          newMetroLine,
        ));
      }
    }
    return null;
  }

  static List<MetroRouteResult> findSmartRoutes(String startInput, String endInput, {Set<String>? allowedModes}) {
    _ensureInit();
    final results = <MetroRouteResult>[];
    if (startInput.isEmpty || endInput.isEmpty) return results;

    final modes = allowedModes ?? {'bus', 'metro', 'microbus', 'train'};
    final startId = _findNode(startInput);
    final endId = _findNode(endInput);

    if (startId == null || endId == null || startId == endId) return results;

    // Option 1: Fastest (all allowed modes)
    final fastest = _dijkstra(startId, endId, modes);
    if (fastest != null && fastest.path.isNotEmpty) {
      final r = _buildResult(fastest);
      results.add(r);
    }

    // Option 2: Bus only (cheapest without metro)
    if (modes.contains('bus')) {
      final busOnly = _dijkstra(startId, endId, {'bus'});
      if (busOnly != null && busOnly.path.isNotEmpty) {
        final r = _buildResult(busOnly);
        // Only add if it's different from fastest
        if (results.isEmpty || r.durationMinutes != results.first.durationMinutes) {
          results.add(r);
        }
      }
    }

    // Option 3: Metro only (if user has metro enabled)
    if (modes.contains('metro')) {
      final metroOnly = _dijkstra(startId, endId, {'metro'});
      if (metroOnly != null && metroOnly.path.isNotEmpty) {
        final r = _buildResult(metroOnly);
        // Only add if different from existing results
        if (results.every((existing) => existing.durationMinutes != r.durationMinutes)) {
          results.add(r);
        }
      }
    }

    return results;
  }

  static MetroRouteResult _buildResult(_State state) {
    final steps = <String>[];
    final segments = <RouteSegment>[];
    final path = state.path;

    int i = 0;
    while (i < path.length) {
      final edge = path[i];

      if (edge.mode == 'metro') {
        // Collect all consecutive metro edges
        final stationIds = <String>[edge.from];
        int dur = 0;
        while (i < path.length && path[i].mode == 'metro') {
          stationIds.add(path[i].to);
          dur += path[i].duration;
          i++;
        }
        final points = stationIds
            .where((id) => MetroGraph.stations.containsKey(id))
            .map((id) => MetroGraph.stations[id]!.location)
            .toList();
        final fromName = MetroGraph.stations[stationIds.first]?.nameAr ?? stationIds.first;
        final toName = MetroGraph.stations[stationIds.last]?.nameAr ?? stationIds.last;
        final stops = stationIds.length - 1;
        steps.add('مترو: $fromName ← $toName ($stops محطات)');
        segments.add(RouteSegment(
          mode: 'metro',
          title: 'مترو الأنفاق',
          subtitle: '$fromName ← $toName  |  $stops محطات',
          durationMinutes: dur,
          distanceText: '${(stops * 1.2).toStringAsFixed(1)} كم',
          pathPoints: points,
        ));
      } else if (edge.mode == 'bus' || edge.mode == 'microbus') {
        final mode = edge.mode;
        final busId = edge.routeId;
        final busEdges = <_Edge>[];
        while (i < path.length && path[i].mode == mode && path[i].routeId == busId) {
          busEdges.add(path[i]);
          i++;
        }
        final dur = busEdges.fold(0, (s, e) => s + e.duration);
        final km = busEdges.fold(0.0, (s, e) => s + e.km);
        final from = busEdges.first.from;
        final to = busEdges.last.to;
        final startPt = PublicTransportData.regionCoords[from] ?? const LatLng(30.0444, 31.2357);
        final endPt = PublicTransportData.regionCoords[to] ?? const LatLng(30.0633, 31.2467);
        List<LatLng> pathPoints = [];
        final routeObjList = PublicTransportData.routes.where((r) => r.id == busId);
        if (routeObjList.isNotEmpty) {
          final rawPoints = routeObjList.first.pathPoints;
          if (rawPoints.length >= 2) {
            final firstDist = (rawPoints.first.latitude - startPt.latitude).abs() + (rawPoints.first.longitude - startPt.longitude).abs();
            final lastDist = (rawPoints.last.latitude - startPt.latitude).abs() + (rawPoints.last.longitude - startPt.longitude).abs();
            if (lastDist < firstDist) {
              pathPoints = rawPoints.reversed.toList();
            } else {
              pathPoints = rawPoints.toList();
            }
          } else {
            pathPoints = rawPoints.toList();
          }
        }
        if (pathPoints.isEmpty) {
          pathPoints = [startPt, endPt];
        }
        steps.add(mode == 'microbus' ? 'ميكروباص ${edge.nameAr}' : 'أتوبيس ${edge.nameAr}');
        segments.add(RouteSegment(
          mode: mode,
          title: mode == 'microbus' ? 'ميكروباص رقم $busId' : 'أتوبيس رقم $busId',
          subtitle: edge.nameAr,
          durationMinutes: dur,
          distanceText: '${km.toStringAsFixed(1)} كم',
          pathPoints: pathPoints,
        ));
      } else {
        // Walk
        steps.add('مشي: ${edge.nameAr}');
        segments.add(RouteSegment(
          mode: 'walk',
          title: 'مشي',
          subtitle: edge.nameAr,
          durationMinutes: edge.duration,
          distanceText: '${edge.km} كم',
          pathPoints: [],
        ));
        i++;
      }
    }

    // Add metro fare once if trip contains metro
    final hasMetro = path.any((e) => e.mode == 'metro');
    final hasBus = path.any((e) => e.mode == 'bus');
    int price = 0;
    if (hasMetro) {
      final metroStops = path.where((e) => e.mode == 'metro').length;
      price += metroStops > 16 ? 20 : metroStops > 9 ? 15 : metroStops > 4 ? 10 : 8;
    }
    if (hasBus) {
      price += path.where((e) => e.mode == 'bus').fold(0, (s, e) => s + e.fare.round());
    }

    return MetroRouteResult(
      durationMinutes: state.duration,
      price: price,
      steps: steps.isEmpty ? ['رحلة مباشرة'] : steps,
      segments: segments,
    );
  }

  static Color getRouteColor(String mode) {
    switch (mode) {
      case 'subway':
      case 'metro':
        return Colors.red;
      case 'bus':
        return Colors.blue;
      case 'walking':
      case 'walk':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  static Future<List<MetroRouteResult>> findDynamicRoutes(String startInput, String endInput) async {
    _ensureInit();
    final results = <MetroRouteResult>[];

    // 1. Geocoding
    final startCoord = await OsmService.geocodeRegion(startInput);
    final endCoord = await OsmService.geocodeRegion(endInput);

    if (startCoord == null || endCoord == null) return results;

    // 2. Multi-routing via OSRM
    final osrmRoutes = await OsmService.fetchOsrmRoutes(startCoord, endCoord);

    for (var routeData in osrmRoutes) {
      final segments = <RouteSegment>[];
      final String? encodedPolyline = routeData['geometry'];
      List<LatLng> pathPoints = [];

      if (encodedPolyline != null) {
        final decoded = decodePolyline(encodedPolyline);
        pathPoints = decoded.map((p) => LatLng(p[0].toDouble(), p[1].toDouble())).toList();
      } else {
        pathPoints = [startCoord, endCoord];
      }
      
      segments.add(RouteSegment(
        mode: 'walking',
        title: 'مسار مقترح',
        subtitle: 'عبر ${startInput}',
        durationMinutes: (routeData['duration'] / 60).round(),
        distanceText: '${(routeData['distance'] / 1000).toStringAsFixed(1)} كم',
        pathPoints: pathPoints,
      ));

      results.add(MetroRouteResult(
        durationMinutes: (routeData['duration'] / 60).round(),
        price: 0, // Needs logic for public transport pricing
        steps: ['اتبع المسار الظاهر على الخريطة'],
        segments: segments,
      ));
    }

    return results;
  }

  static MetroRouteResult? findMetroRoute(String startId, String endId) {
    _ensureInit();
    final result = _dijkstra(startId, endId, {'metro'});
    if (result == null || result.path.isEmpty) return null;
    return _buildResult(result);
  }
}

