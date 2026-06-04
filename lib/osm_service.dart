import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:osm_nominatim/osm_nominatim.dart';

class OsmService {
  // 1. Geocoding: Region name to LatLng
  static Future<LatLng?> geocodeRegion(String name) async {
    try {
      final nominatim = Nominatim(userAgent: 'com.example.flutter_app');
      final results = await nominatim.searchByName(
        query: '$name, Cairo, Egypt',
        limit: 1,
      );
      if (results.isNotEmpty) {
        return LatLng(results.first.lat, results.first.lon);
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  // 2. Discovery: Find nearby stops/stations using Overpass API
  static Future<List<Map<String, dynamic>>> findNearbyStops(LatLng location, {int radius = 2000}) async {
    final query = '''
      [out:json];
      (
        node["public_transport"="stop_position"](around:$radius, ${location.latitude}, ${location.longitude});
        node["railway"="station"](around:$radius, ${location.latitude}, ${location.longitude});
        node["highway"="bus_stop"](around:$radius, ${location.latitude}, ${location.longitude});
      );
      out body;
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: query,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['elements'] ?? []);
      }
    } catch (e) {
      print('Overpass error: $e');
    }
    return [];
  }

  // 3. Multi-routing: OSRM with alternatives
  static Future<List<dynamic>> fetchOsrmRoutes(LatLng start, LatLng end) async {
    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=polyline&alternatives=true&steps=true';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['routes'] ?? [];
      }
    } catch (e) {
      print('OSRM error: $e');
    }
    return [];
  }
}
