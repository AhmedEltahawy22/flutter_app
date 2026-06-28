import 'package:flutter/material.dart';
import '../metro_graph.dart';
import '../public_transport_data.dart';

/// قائمة موحدة لكل الأماكن المتاحة في التطبيق
/// تُستخدم في Autocomplete بشاشة البحث
class PlacesData {
  PlacesData._();

  static final List<PlaceEntry> _cache = [];

  static List<PlaceEntry> get all {
    if (_cache.isNotEmpty) return _cache;
    _build();
    return _cache;
  }

  static void _build() {
    final seen = <String>{};

    void add(String name, String nameEn, PlaceType type, {double? lat, double? lng}) {
      final key = name.trim().toLowerCase();
      if (key.isEmpty || seen.contains(key)) return;
      seen.add(key);
      _cache.add(PlaceEntry(
        nameAr: name.trim(),
        nameEn: nameEn.trim(),
        type: type,
        lat: lat,
        lng: lng,
      ));
    }

    // ─── محطات المترو ───────────────────────────────────────
    for (final s in MetroGraph.stations.values) {
      add(s.nameAr, s.nameEn, PlaceType.metro, lat: s.location.latitude, lng: s.location.longitude);
    }

    // ─── مناطق الأتوبيس ──────────────────────────────────────
    for (int i = 0; i < PublicTransportData.regionsAr.length; i++) {
      final ar = PublicTransportData.regionsAr[i];
      final en = i < PublicTransportData.regionsEn.length
          ? PublicTransportData.regionsEn[i]
          : ar;
      final coords = PublicTransportData.regionCoords[ar];
      add(ar, en, PlaceType.bus, lat: coords?.latitude, lng: coords?.longitude);
    }

    // ─── مناطق إضافية شهيرة ──────────────────────────────────
    const extras = [
      ('المنيرة',          'Al-Manira',          PlaceType.region),
      ('السيدة زينب',      'Al-Sayeda Zeinab',   PlaceType.region),
      ('الدقي',            'Dokki',              PlaceType.region),
      ('المهندسين',        'Mohandessin',        PlaceType.region),
      ('العجوزة',          'Agouza',             PlaceType.region),
      ('الزمالك',          'Zamalek',            PlaceType.region),
      ('المنيل',           'Al-Manial',          PlaceType.region),
      ('جاردن سيتي',       'Garden City',        PlaceType.region),
      ('وسط البلد',        'Downtown Cairo',     PlaceType.region),
      ('التحرير',          'Tahrir',             PlaceType.region),
      ('عابدين',           'Abdin',              PlaceType.region),
      ('الجمالية',         'Al-Gamaliya',        PlaceType.region),
      ('الأزبكية',         'Al-Azbakeya',        PlaceType.region),
      ('باب الشعرية',      'Bab Al-Shaeria',     PlaceType.region),
      ('رمسيس',            'Ramses',             PlaceType.region),
      ('الجيزة',           'Giza',               PlaceType.region),
      ('الهرم',            'Haram',              PlaceType.region),
      ('فيصل',             'Faisal',             PlaceType.region),
      ('جامعة القاهرة',    'Cairo University',   PlaceType.region),
      ('الجامعة',          'University',         PlaceType.region),
      ('المنيب',           'Al-Mounib',          PlaceType.region),
      ('المعادي',          'Maadi',              PlaceType.region),
      ('حلوان',            'Helwan',             PlaceType.region),
      ('مصر القديمة',      'Old Cairo',          PlaceType.region),
      ('دار السلام',       'Dar Al-Salam',       PlaceType.region),
      ('طرة',              'Tura',               PlaceType.region),
      ('شبرا',             'Shubra',             PlaceType.region),
      ('شبرا الخيمة',      'Shubra El-Kheima',   PlaceType.region),
      ('روض الفرج',        'Rod El-Farag',       PlaceType.region),
      ('إمبابة',           'Imbaba',             PlaceType.region),
      ('كيت كات',          'Kit Kat',            PlaceType.region),
      ('مدينة نصر',        'Nasr City',          PlaceType.region),
      ('العباسية',         'Abbassia',           PlaceType.region),
      ('مصر الجديدة',      'Heliopolis',         PlaceType.region),
      ('هليوبوليس',        'Heliopolis',         PlaceType.region),
      ('النزهة',           'Al-Nozha',           PlaceType.region),
      ('المرج',            'Al-Marg',            PlaceType.region),
      ('عين شمس',          'Ain Shams',          PlaceType.region),
      ('المطرية',          'Al-Matareyya',       PlaceType.region),
      ('القلعة',           'The Citadel',        PlaceType.region),
      ('الأوبرا',          'Opera',              PlaceType.region),
      ('الطريق الدائري',   'Ring Road',          PlaceType.region),
      ('عدلي منصور',       'Adly Mansour',       PlaceType.region),
      ('السلام',           'Al-Salam City',      PlaceType.region),
      ('بدر',              'Badr City',          PlaceType.region),
      ('الهايكستب',        'El-Haykestep',       PlaceType.region),
      ('المقطم',           'Al-Moqattam',        PlaceType.region),
    ];

    for (final (ar, en, type) in extras) {
      final coords = PublicTransportData.regionCoords[ar];
      add(ar, en, type, lat: coords?.latitude, lng: coords?.longitude);
    }
  }

  /// البحث عن الأماكن بنص معطى (يدعم العربي والإنجليزي)
  /// [filterType]: null = الكل، PlaceType.region = مناطق فقط، PlaceType.metro = محطات فقط
  static List<PlaceEntry> search(String query, {int limit = 8, PlaceType? filterType}) {
    if (query.trim().length < 1) return [];
    final q = query.trim().toLowerCase()
        .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه').replaceAll('ى', 'ي');

    final results = all.where((p) {
      // تطبيق الفلتر
      if (filterType == PlaceType.region && p.type != PlaceType.region) return false;
      if (filterType == PlaceType.metro && p.type == PlaceType.region) return false;

      final ar = p.nameAr.toLowerCase()
          .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
          .replaceAll('ة', 'ه').replaceAll('ى', 'ي');
      final en = p.nameEn.toLowerCase();
      return ar.contains(q) || en.contains(q);
    }).toList();

    // ترتيب: المناطق أولاً، ثم المطابقة من أول الكلمة
    int typePriority(PlaceType t) => switch (t) {
      PlaceType.region => 0,
      PlaceType.metro  => 1,
      PlaceType.bus    => 2,
    };

    results.sort((a, b) {
      final aAr = a.nameAr.toLowerCase()
          .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
          .replaceAll('ة', 'ه').replaceAll('ى', 'ي');
      final bAr = b.nameAr.toLowerCase()
          .replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا')
          .replaceAll('ة', 'ه').replaceAll('ى', 'ي');
      final aStarts = aAr.startsWith(q) ? 0 : 1;
      final bStarts = bAr.startsWith(q) ? 0 : 1;
      // أولاً: المطابقة من أول الكلمة
      final startCmp = aStarts.compareTo(bStarts);
      if (startCmp != 0) return startCmp;
      // ثانياً: المناطق قبل المحطات
      return typePriority(a.type).compareTo(typePriority(b.type));
    });

    return results.take(limit).toList();
  }
}

enum PlaceType { metro, bus, region }

class PlaceEntry {
  final String nameAr;
  final String nameEn;
  final PlaceType type;
  final double? lat;
  final double? lng;

  const PlaceEntry({
    required this.nameAr,
    required this.nameEn,
    required this.type,
    this.lat,
    this.lng,
  });

  IconData get icon => switch (type) {
        PlaceType.metro  => Icons.train_rounded,
        PlaceType.bus    => Icons.directions_bus_rounded,
        PlaceType.region => Icons.place_rounded,
      };

  Color get color => switch (type) {
        PlaceType.metro  => const Color(0xFFE53935),
        PlaceType.bus    => const Color(0xFF1F2BDB),
        PlaceType.region => const Color(0xFF5E35B1),
      };
}
