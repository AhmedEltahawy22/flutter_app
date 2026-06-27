import 'dart:io';
import 'dart:convert';

void main() {
  final gtfsDir = Directory('مسار الباصات');
  if (!gtfsDir.existsSync()) {
    print('GTFS directory "مسار الباصات" not found!');
    return;
  }

  print('Parsing stops.txt...');
  final stopsFile = File('${gtfsDir.path}/stops.txt');
  final stopsLines = stopsFile.readAsLinesSync();
  final stopsHeaders = stopsLines[0].split(',');
  final stopIdIdx = stopsHeaders.indexOf('stop_id');
  final stopNameIdx = stopsHeaders.indexOf('stop_name');
  final stopLatIdx = stopsHeaders.indexOf('stop_lat');
  final stopLonIdx = stopsHeaders.indexOf('stop_lon');

  // Map stop_id -> {name, lat, lon}
  final Map<String, Map<String, dynamic>> stops = {};
  for (int i = 1; i < stopsLines.length; i++) {
    final line = stopsLines[i].trim();
    if (line.isEmpty) continue;
    
    // Simple CSV splitter that respects quotes if any (stops.txt has names with commas sometimes)
    final parts = splitCsvLine(line);
    if (parts.length <= MathMax([stopIdIdx, stopNameIdx, stopLatIdx, stopLonIdx])) continue;
    
    final id = parts[stopIdIdx].trim();
    final name = parts[stopNameIdx].replaceAll('"', '').trim();
    final lat = double.tryParse(parts[stopLatIdx].trim()) ?? 0.0;
    final lon = double.tryParse(parts[stopLonIdx].trim()) ?? 0.0;
    
    stops[id] = {'name': name, 'lat': lat, 'lon': lon};
  }
  print('Loaded ${stops.length} stops.');

  print('Parsing trips.txt...');
  final tripsFile = File('${gtfsDir.path}/trips.txt');
  final tripsLines = tripsFile.readAsLinesSync();
  final tripsHeaders = tripsLines[0].split(',');
  final routeIdIdx = tripsHeaders.indexOf('route_id');
  final tripIdIdx = tripsHeaders.indexOf('trip_id');

  // Map route_id -> first trip_id
  final Map<String, String> routeToTrip = {};
  for (int i = 1; i < tripsLines.length; i++) {
    final line = tripsLines[i].trim();
    if (line.isEmpty) continue;
    final parts = splitCsvLine(line);
    if (parts.length <= MathMax([routeIdIdx, tripIdIdx])) continue;
    final rId = parts[routeIdIdx].trim();
    final tId = parts[tripIdIdx].trim();
    if (!routeToTrip.containsKey(rId)) {
      routeToTrip[rId] = tId;
    }
  }
  print('Mapped ${routeToTrip.length} routes to representative trips.');

  print('Parsing stop_times.txt...');
  final stopTimesFile = File('${gtfsDir.path}/stop_times.txt');
  final stopTimesLines = stopTimesFile.readAsLinesSync();
  final stopTimesHeaders = stopTimesLines[0].split(',');
  final stTripIdIdx = stopTimesHeaders.indexOf('trip_id');
  final stStopIdIdx = stopTimesHeaders.indexOf('stop_id');
  final stSeqIdx = stopTimesHeaders.indexOf('stop_sequence');

  // Map trip_id -> list of stops
  final Map<String, List<Map<String, dynamic>>> tripStops = {};
  for (int i = 1; i < stopTimesLines.length; i++) {
    final line = stopTimesLines[i].trim();
    if (line.isEmpty) continue;
    final parts = splitCsvLine(line);
    if (parts.length <= MathMax([stTripIdIdx, stStopIdIdx, stSeqIdx])) continue;
    final tId = parts[stTripIdIdx].trim();
    final sId = parts[stStopIdIdx].trim();
    final seq = int.tryParse(parts[stSeqIdx].trim()) ?? 0;
    
    // Only parse for trips we are interested in (representative trips of routes)
    if (routeToTrip.values.contains(tId)) {
      tripStops.putIfAbsent(tId, () => []).add({'stop_id': sId, 'sequence': seq});
    }
  }

  // Sort stops by sequence
  for (final tId in tripStops.keys) {
    tripStops[tId]!.sort((a, b) => (a['sequence'] as int).compareTo(b['sequence'] as int));
  }
  print('Loaded stop sequences for representative trips.');

  print('Parsing routes.txt...');
  final routesFile = File('${gtfsDir.path}/routes.txt');
  final routesLines = routesFile.readAsLinesSync();
  final routesHeaders = routesLines[0].split(',');
  final rRouteIdIdx = routesHeaders.indexOf('route_id');
  final rLongNameIdx = routesHeaders.indexOf('route_long_name');
  final rShortNameIdx = routesHeaders.indexOf('route_short_name');
  final rTypeIdx = routesHeaders.indexOf('route_type');

  final List<Map<String, dynamic>> parsedRoutes = [];
  final Set<String> regionsAr = {};
  final Set<String> regionsEn = {};
  final Map<String, List<double>> regionCoordsMap = {};

  for (int i = 1; i < routesLines.length; i++) {
    final line = routesLines[i].trim();
    if (line.isEmpty) continue;
    final parts = splitCsvLine(line);
    if (parts.length <= MathMax([rRouteIdIdx, rLongNameIdx, rShortNameIdx, rTypeIdx])) continue;
    
    final rId = parts[rRouteIdIdx].trim();
    final longName = parts[rLongNameIdx].replaceAll('"', '').trim();
    final shortName = parts[rShortNameIdx].replaceAll('"', '').trim();
    
    // Find stops for this route
    final tId = routeToTrip[rId];
    if (tId == null || !tripStops.containsKey(tId)) continue;
    
    final stopsList = tripStops[tId]!;
    if (stopsList.isEmpty) continue;
    
    final firstStopId = stopsList.first['stop_id'];
    final lastStopId = stopsList.last['stop_id'];
    
    final firstStop = stops[firstStopId];
    final lastStop = stops[lastStopId];
    
    if (firstStop == null || lastStop == null) continue;
    
    final fromEn = firstStop['name'] as String;
    final toEn = lastStop['name'] as String;
    final fromAr = translateToArabic(fromEn);
    final toAr = translateToArabic(toEn);
    
    regionsEn.add(fromEn);
    regionsEn.add(toEn);
    regionsAr.add(fromAr);
    regionsAr.add(toAr);
    
    regionCoordsMap[fromEn] = [firstStop['lat'] as double, firstStop['lon'] as double];
    regionCoordsMap[fromAr] = [firstStop['lat'] as double, firstStop['lon'] as double];
    regionCoordsMap[toEn] = [lastStop['lat'] as double, lastStop['lon'] as double];
    regionCoordsMap[toAr] = [lastStop['lat'] as double, lastStop['lon'] as double];

    // Build coordinate sequence (path points)
    final pathPoints = <Map<String, double>>[];
    for (final sInfo in stopsList) {
      final sId = sInfo['stop_id'];
      final stopObj = stops[sId];
      if (stopObj != null) {
        pathPoints.add({
          'lat': stopObj['lat'] as double,
          'lon': stopObj['lon'] as double,
        });
      }
    }

    // Determine type: Box -> Microbus, Tomnaya -> Microbus, Minibus -> Minibus (we treat as bus), CTA -> Bus
    // If route_type is 3, it is bus/transit
    String vehicleType = 'أتوبيس عادي';
    if (shortName.toLowerCase().contains('box') || shortName.toLowerCase().contains('tomnaya') || shortName.toLowerCase().contains('microbus')) {
      vehicleType = 'ميكروباص';
    } else if (shortName.toLowerCase().contains('minibus') || shortName.toLowerCase().contains('coop')) {
      vehicleType = 'أتوبيس عادي';
    }

    parsedRoutes.add({
      'id': rId,
      'nameAr': translateToArabic(longName),
      'nameEn': longName,
      'fromAr': fromAr,
      'fromEn': fromEn,
      'toAr': toAr,
      'toEn': toEn,
      'vehicleType': vehicleType,
      'numStops': stopsList.length,
      'pathPoints': pathPoints,
    });
  }

  print('Parsed ${parsedRoutes.length} valid routes.');

  print('Generating lib/public_transport_data.dart...');
  final buffer = StringBuffer();
  buffer.writeln('// Auto-generated from GTFS data');
  buffer.writeln('import \'package:latlong2/latlong.dart\';');
  buffer.writeln('');
  buffer.writeln('class PublicTransportRoute {');
  buffer.writeln('  final String id;');
  buffer.writeln('  final String nameAr;');
  buffer.writeln('  final String nameEn;');
  buffer.writeln('  final String fromAr;');
  buffer.writeln('  final String fromEn;');
  buffer.writeln('  final String toAr;');
  buffer.writeln('  final String toEn;');
  buffer.writeln('  final String zone;');
  buffer.writeln('  final String vehicleType;');
  buffer.writeln('  final double lengthKm;');
  buffer.writeln('  final int numStops;');
  buffer.writeln('  final int durationMinutes;');
  buffer.writeln('  final int frequencyMinutes;');
  buffer.writeln('  final double fareEgp;');
  buffer.writeln('  final String startTime;');
  buffer.writeln('  final String endTime;');
  buffer.writeln('  final bool isCng;');
  buffer.writeln('  final bool isAc;');
  buffer.writeln('  final bool isAccessible;');
  buffer.writeln('  final List<LatLng> pathPoints;');
  buffer.writeln('');
  buffer.writeln('  const PublicTransportRoute({');
  buffer.writeln('    required this.id,');
  buffer.writeln('    required this.nameAr,');
  buffer.writeln('    required this.nameEn,');
  buffer.writeln('    required this.fromAr,');
  buffer.writeln('    required this.fromEn,');
  buffer.writeln('    required this.toAr,');
  buffer.writeln('    required this.toEn,');
  buffer.writeln('    required this.zone,');
  buffer.writeln('    required this.vehicleType,');
  buffer.writeln('    required this.lengthKm,');
  buffer.writeln('    required this.numStops,');
  buffer.writeln('    required this.durationMinutes,');
  buffer.writeln('    required this.frequencyMinutes,');
  buffer.writeln('    required this.fareEgp,');
  buffer.writeln('    required this.startTime,');
  buffer.writeln('    required this.endTime,');
  buffer.writeln('    required this.isCng,');
  buffer.writeln('    required this.isAc,');
  buffer.writeln('    required this.isAccessible,');
  buffer.writeln('    required this.pathPoints,');
  buffer.writeln('  });');
  buffer.writeln('}');
  buffer.writeln('');
  buffer.writeln('class PublicTransportData {');
  buffer.writeln('  static const List<PublicTransportRoute> routes = [');

  for (final r in parsedRoutes) {
    buffer.writeln('    PublicTransportRoute(');
    buffer.writeln('      id: ${escapeString(r['id'])},');
    buffer.writeln('      nameAr: ${escapeString(r['nameAr'])},');
    buffer.writeln('      nameEn: ${escapeString(r['nameEn'])},');
    buffer.writeln('      fromAr: ${escapeString(r['fromAr'])},');
    buffer.writeln('      fromEn: ${escapeString(r['fromEn'])},');
    buffer.writeln('      toAr: ${escapeString(r['toAr'])},');
    buffer.writeln('      toEn: ${escapeString(r['toEn'])},');
    buffer.writeln('      zone: \'\',');
    buffer.writeln('      vehicleType: ${escapeString(r['vehicleType'])},');
    buffer.writeln('      lengthKm: 12.0,');
    buffer.writeln('      numStops: ${r['numStops']},');
    buffer.writeln('      durationMinutes: ${(r['numStops'] * 2.5).round()},');
    buffer.writeln('      frequencyMinutes: 10,');
    buffer.writeln('      fareEgp: 10.0,');
    buffer.writeln('      startTime: \'06:00\',');
    buffer.writeln('      endTime: \'23:00\',');
    buffer.writeln('      isCng: false,');
    buffer.writeln('      isAc: false,');
    buffer.writeln('      isAccessible: false,');
    buffer.write('      pathPoints: [');
    for (final p in r['pathPoints']) {
      buffer.write('LatLng(${p['lat']}, ${p['lon']}), ');
    }
    buffer.writeln('],');
    buffer.writeln('    ),');
  }

  buffer.writeln('  ];');
  buffer.writeln('');

  // Regions lists
  final listAr = regionsAr.toList()..sort();
  final listEn = regionsEn.toList()..sort();
  
  buffer.write('  static const List<String> regionsAr = [');
  buffer.write(listAr.map((s) => escapeString(s)).join(', '));
  buffer.writeln('];');

  buffer.write('  static const List<String> regionsEn = [');
  buffer.write(listEn.map((s) => escapeString(s)).join(', '));
  buffer.writeln('];');
  buffer.writeln('');

  // Region coords map
  buffer.writeln('  static const Map<String, LatLng> regionCoords = {');
  regionCoordsMap.forEach((name, coords) {
    buffer.writeln('    ${escapeString(name)}: LatLng(${coords[0]}, ${coords[1]}),');
  });
  buffer.writeln('  };');
  buffer.writeln('}');

  File('lib/public_transport_data.dart').writeAsStringSync(buffer.toString());
  print('Done! lib/public_transport_data.dart has been successfully re-generated.');
}

int MathMax(List<int> list) {
  int max = list[0];
  for (var val in list) {
    if (val > max) max = val;
  }
  return max;
}

List<String> splitCsvLine(String line) {
  final List<String> result = [];
  bool inQuotes = false;
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      result.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }
  result.add(buffer.toString());
  return result;
}

String escapeString(String s) {
  return "'${s.replaceAll("'", "\\'")}'";
}

String translateToArabic(String en) {
  String res = en;
  final translations = {
    '10th District Station': 'محطة الحي العاشر',
    '6th of October': '6 أكتوبر',
    '6th District': 'الحي السادس',
    'Al Souq Al Qadeem': 'السوق القديم',
    'Dolce': 'دولسي',
    'Hossary Station': 'محطة الحصري',
    'Laylat Al Qadr Station': 'محطة ليلة القدر',
    'Magda Square': 'ميدان ماجدة',
    '10th of Ramadan Station': 'محطة 10 رمضان',
    'Nasr City': 'مدينة نصر',
    'New Cairo': 'القاهرة الجديدة',
    '1st Settlement Station': 'محطة التجمع الأول',
    '7th District Station': 'محطة الحي السابع',
    '8th District': 'الحي الثامن',
    'Al tabba': 'التبة',
    'Al Shabab Entrance': 'مدخل الشباب',
    'Alf Maskan Station': 'محطة ألف مسكن',
    'Awwel Makram Ebeid': 'أول مكرم عبيد',
    'Darrasa': 'الدراسة',
    'FUE': 'جامعة المستقبل',
    'Gas (Banks Area)': 'الغاز (منطقة البنوك)',
    'Hadaba Wosta (Moqattam)': 'الهضبة الوسطى (المقطم)',
    'Moneeb Station': 'محطة المنيب',
    'New Cairo Academy': 'أكاديمية القاهرة الجديدة',
    'New Cairo Court Station': 'محطة محكمة القاهرة الجديدة',
    'New Marg Station': 'محطة المرج الجديدة',
    'Ommal Square Station': 'محطة ميدان العمال',
    'Qalyoub Exit': 'مخرج قليوب',
    'Ramses Station': 'محطة رمسيس',
    'Rehab - Gate 6': 'الرحاب - بوابة 6',
    'Zahraa Madinet Nasr': 'زهراء مدينة نصر',
    '10th of Ramadan City': 'مدينة العاشر من رمضان',
    'Al Shorouq Academy Station': 'محطة أكاديمية الشروق',
    'Abd Al Moneim Riad Station': 'محطة عبد المنعم رياض',
    'Ahmed Helmy Station': 'محطة أحمد حلمي',
    'Al Banhawi': 'البنهاوي',
    'Al Hamd Square Station': 'محطة ميدان الحمد',
    'Al Hegaz (Obour Police )': 'الحجاز (شرطة العبور)',
    'Al Sawah Square': 'ميدان السواح',
    'Al Sayeda Aisha Station': 'محطة السيدة عائشة',
    'Al Shorouq Water': 'مياه الشروق',
    'Attaba': 'العتبة',
    'Awwel Abbas': 'أول عباس',
    'Awwel Al Zawya Al Hamra Station': 'محطة أول الزاوية الحمراء',
    'Badr City': 'مدينة بدر',
    'Bashtil': 'بشتيل',
    'Haram & Marioteya Station': 'محطة الهرم والمريوطية',
    'Helwan Metro': 'مترو حلوان',
    'Helwan Station': 'محطة حلوان',
    'Hyper 1 Station': 'محطة هايبر 1',
    'Imbaba Station': 'محطة إمبابة',
    'Kafr Tohormos': 'كفر طهرمس',
    'Khanka': 'الخانكة',
    'Manshiyat Nasser Station': 'محطة منشية ناصر',
    'Marioteya & Ring Rd': 'المريوطية والدائري',
    'Matareya Square Station': 'محطة ميدان المطرية',
    'Moassasa Station': 'محطة المؤسسة',
    'Mostorod Ring Rd': 'دائري مسطرد',
    'Rabaah Al Adaweya Mosque': 'مسجد رابعة العدوية',
    'Rawda Mosque  (Obour)': 'مسجد الروضة (العبور)',
    'Salam Alexandria Station': 'محطة سلام الإسكندرية',
    'Saqr Quraish Station': 'محطة صقر قريش',
    'Shabab (Obour)': 'الشباب (العبور)',
    'Wizarat District': 'حي الوزارات',
    'New Administrative Capital': 'العاصمة الإدارية الجديدة',
    '11th District': 'الحي الحادي عشر',
    '15th of May': '15 مايو',
    'Abbasseya Station': 'محطة العباسية',
    'Giza Square Station': 'محطة ميدان الجيزة',
    'Abou Al Reesh': 'أبو الريش',
    'Abou Wafya': 'أبو وافية',
    'Al Zawya Al Hamra Station': 'محطة الزاوية الحمراء',
    'Amr Ibn El Aas Station': 'محطة عمرو بن العاص',
    'Dawaran Shubra Station': 'محطة دوران شبرا',
    'Matbaa Station': 'محطة المطبعة',
    'Mazallat Station': 'محطة المظلات',
    'Mostorod Station': 'محطة مسطرد',
    'Orabi Bridge': 'كوبري عرابي',
    '26th of July & Ring Rd': '26 يوليو والدائري',
    '3rd Settlement  (New Cairo)': 'التجمع الثالث (القاهرة الجديدة)',
    'Al Motamayez Station': 'محطة المتميز',
    'Industrial Zone 3': 'المنطقة الصناعية الثالثة',
    'Laylat Al Qadr': 'ليلة القدر',
    '7th District': 'الحي السابع',
    'Al Mostaqbal Entrance': 'مدخل المستقبل',
    'Ghamra Station': 'محطة غمرة',
    'Hadaek EL Kobba': 'حدائق القبة',
    'Lebanon Square Station': 'محطة ميدان لبنان',
    'Masaken Al Wehda': 'مساكن الوحدة',
    'Masaken Dahshour': 'مساكن دهشور',
    'Qism El Hadayek': 'قسم الحدائق',
    'Tagneed (Al Remaya)': 'تجنيد (الرماية)',
    'CIC': 'الكلية الكندية الكندية الدولية',
    'AUC': 'الجامعة الأمريكية',
    'Applied Arts': 'الفنون التطبيقية',
    'Barageel St': 'شارع البراجيل',
    'Bohooth': 'البحوث',
    'Znen (Awwel Al Eshreen)': 'زنين (أول العشرين)',
    'Metro': 'مترو',
    'Bus': 'أتوبيس',
    'Microbus': 'ميكروباص',
    'Minibus': 'ميني باص',
    'Tomnaya': 'تمناية',
    'Box': 'صندوق',
    'Train': 'قطار',
    'Walk': 'مشي',
    'Station': 'محطة',
    'Gate': 'بوابة',
    'Square': 'ميدان',
    'Bridge': 'كوبري',
  };

  translations.forEach((enKey, arVal) {
    res = res.replaceAll(enKey, arVal);
  });
  
  return res;
}
