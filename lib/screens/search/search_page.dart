import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:osm_nominatim/osm_nominatim.dart' as osm;
import '../../core/localization.dart';
import '../../core/places_data.dart';
import '../../providers/app_language_scope.dart';
import '../../public_transport_service.dart';
import 'search_trips_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController   = TextEditingController();
  final Set<String> _selectedModes = {'bus', 'metro'};
  bool _isLocating = false;
  PlaceType? _placeFilter; // null = كل, region = مناطق, metro/bus = محطات

  LatLng? _fromLatLng;
  LatLng? _toLatLng;

  @override
  void initState() {
    super.initState();
    // إزالة الإحداثيات إذا قام المستخدم بتعديل النص يدوياً
    _fromController.addListener(() {
      final isAr = AppLanguageScope.notifierOf(context).value == 'ar';
      final gpsLabel = isAr ? 'موقعي الحالي 📍' : 'My Location 📍';
      if (_fromController.text != gpsLabel && _fromLatLng != null) {
        _fromLatLng = null;
      }
    });
    _toController.addListener(() {
      final isAr = AppLanguageScope.notifierOf(context).value == 'ar';
      final gpsLabel = isAr ? 'موقعي الحالي 📍' : 'My Location 📍';
      if (_toController.text != gpsLabel && _toLatLng != null) {
        _toLatLng = null;
      }
    });
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLocating = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      
      // حفظ الإحداثيات الدقيقة للـ GPS
      _fromLatLng = LatLng(pos.latitude, pos.longitude);
      
      final isAr = AppLanguageScope.notifierOf(context).value == 'ar';
      final placeName = isAr ? 'موقعي الحالي 📍' : 'My Location 📍';

      if (mounted) {
        _fromController.text = placeName;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLocating = false);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final isAr     = AppLanguageScope.notifierOf(context).value == 'ar';
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2BDB),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(context, 'ابحث عن رحلتك', 'Find Your Trip'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr(context, 'اكتب اسم المنطقة أو المحطة',
                          'Type area or station name'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Search Fields Card ───────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                     // ── Filter chips ─────────────────────────────
                    Row(
                      children: [
                        Text(
                          tr(context, 'نوع البحث:', 'Search type:'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _filterChip(
                          label: tr(context, 'الكل', 'All'),
                          icon: Icons.apps_rounded,
                          isSelected: _placeFilter == null,
                          color: const Color(0xFF1F2BDB),
                          isDark: isDark,
                          onTap: () => setState(() => _placeFilter = null),
                        ),
                        const SizedBox(width: 6),
                        _filterChip(
                          label: tr(context, 'مناطق', 'Areas'),
                          icon: Icons.place_rounded,
                          isSelected: _placeFilter == PlaceType.region,
                          color: const Color(0xFF5E35B1),
                          isDark: isDark,
                          onTap: () => setState(() => _placeFilter = PlaceType.region),
                        ),
                        const SizedBox(width: 6),
                        _filterChip(
                          label: tr(context, 'محطات', 'Stations'),
                          icon: Icons.train_rounded,
                          isSelected: _placeFilter != null && _placeFilter != PlaceType.region,
                          color: const Color(0xFFE53935),
                          isDark: isDark,
                          onTap: () => setState(() => _placeFilter = PlaceType.metro),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── FROM field ────────────────────────────────
                    _PlaceAutocomplete(
                      controller: _fromController,
                      hintAr: 'من (ابحث عن منطقة أو محطة)',
                      hintEn: 'From (Search area or station)',
                      prefixIcon: Icons.trip_origin,
                      isAr: isAr,
                      isDark: isDark,
                      placeFilter: _placeFilter,
                      onSelected: (entry) {
                        if (entry.lat != null && entry.lng != null) {
                          _fromLatLng = LatLng(entry.lat!, entry.lng!);
                        } else {
                          _fromLatLng = null;
                        }
                      },
                      suffixIcon: _isLocating
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.my_location_rounded,
                                  color: Color(0xFF1F2BDB)),
                              tooltip:
                                  tr(context, 'موقعي الحالي', 'My Location'),
                              onPressed: _detectLocation,
                            ),
                    ),

                    const SizedBox(height: 4),

                    // ── Swap button ───────────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          final tmpText = _fromController.text;
                          _fromController.text = _toController.text;
                          _toController.text = tmpText;

                          final tmpLatLng = _fromLatLng;
                          _fromLatLng = _toLatLng;
                          _toLatLng = tmpLatLng;
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFFF2C230).withOpacity(0.25)
                                : const Color(0xFFF2C230).withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFFF2C230).withOpacity(0.5)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.swap_vert_rounded,
                            color: isDark ? const Color(0xFFF2C230) : const Color(0xFF1F2B63),
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ── TO field ──────────────────────────────────
                    _PlaceAutocomplete(
                      controller: _toController,
                      hintAr: 'إلى (ابحث عن منطقة أو محطة)',
                      hintEn: 'To (Search area or station)',
                      prefixIcon: Icons.place_outlined,
                      isAr: isAr,
                      isDark: isDark,
                      placeFilter: _placeFilter,
                      onSelected: (entry) {
                        if (entry.lat != null && entry.lng != null) {
                          _toLatLng = LatLng(entry.lat!, entry.lng!);
                        } else {
                          _toLatLng = null;
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    // ── Mode chips ────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        tr(context, 'خيارات المواصلات', 'Transport Options'),
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
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
                        _modeChip('bus',      context, isDark),
                        _modeChip('metro',    context, isDark),
                        _modeChip('train',    context, isDark),
                        _modeChip('microbus', context, isDark),
                        _modeChip('walk',     context, isDark),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ── Search button ─────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.search_rounded),
                        label: Text(tr(context, 'ابحث عن المسارات', 'Find Routes')),
                        onPressed: () {
                          final from = _fromController.text.trim();
                          final to   = _toController.text.trim();
                          if (from.isEmpty || to.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red.shade700,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                content: Text(
                                  tr(
                                    context,
                                    'يرجى كتابة نقطة الانطلاق والوجهة',
                                    'Please enter both origin and destination',
                                  ),
                                ),
                              ),
                            );
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SearchTripsPage(
                                fromId: from,
                                toId: to,
                                fromLatLng: _fromLatLng,
                                toLatLng: _toLatLng,
                                allowedModes: _selectedModes,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2C230),
                          foregroundColor: const Color(0xFF1F2B63),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
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

  Widget _filterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF0F3F8)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSelected ? color : (isDark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeChip(String mode, BuildContext context, bool isDark) {
    final selected = _selectedModes.contains(mode);
    final label = switch (mode) {
      'bus'      => tr(context, 'أتوبيس', 'Bus'),
      'metro'    => tr(context, 'مترو', 'Metro'),
      'train'    => tr(context, 'قطار', 'Train'),
      'microbus' => tr(context, 'ميكروباص', 'Microbus'),
      _          => tr(context, 'مشي', 'Walk'),
    };
    return FilterChip(
      label: Text(label),
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
        color: selected
            ? const Color(0xFF1F2B63)
            : (isDark ? Colors.white70 : Colors.black87),
      ),
      backgroundColor: isDark ? const Color(0xFF2D2D2D) : null,
      selectedColor: const Color(0xFFF2C230),
      checkmarkColor: const Color(0xFF1F2B63),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Autocomplete Widget
// ─────────────────────────────────────────────────────────────────────────────
class _PlaceAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final String hintAr;
  final String hintEn;
  final IconData prefixIcon;
  final bool isAr;
  final bool isDark;
  final Widget? suffixIcon;
  final PlaceType? placeFilter;
  final ValueChanged<PlaceEntry>? onSelected;

  const _PlaceAutocomplete({
    required this.controller,
    required this.hintAr,
    required this.hintEn,
    required this.prefixIcon,
    required this.isAr,
    required this.isDark,
    this.suffixIcon,
    this.placeFilter,
    this.onSelected,
  });

  @override
  State<_PlaceAutocomplete> createState() => _PlaceAutocompleteState();
}

class _PlaceAutocompleteState extends State<_PlaceAutocomplete> {
  List<PlaceEntry> _suggestions = [];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  bool _showDropdown = false;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // تأخير صغير يسمح لـ onTap بالتسجيل قبل إغلاق الـ overlay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _removeOverlay();
          setState(() => _showDropdown = false);
        }
      });
    }
  }

  void _onTextChanged() {
    if (!_focusNode.hasFocus) return;
    final q = widget.controller.text.trim();
    if (q.isEmpty) {
      _removeOverlay();
      setState(() {
        _suggestions = [];
        _showDropdown = false;
      });
      return;
    }

    // 1. البحث المحلي الفوري
    final localResults = PlacesData.search(q, limit: 5, filterType: widget.placeFilter);
    setState(() {
      _suggestions = localResults;
      _showDropdown = _suggestions.isNotEmpty;
    });
    if (_showDropdown) {
      if (_overlay != null) {
        _overlay!.markNeedsBuild();
      } else {
        _showOverlay();
      }
    } else {
      _removeOverlay();
    }

    // 2. البحث عن شوارع حقيقية عبر الإنترنت مع Debounce لمنع الضغط على السيرفر
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (q.length < 3) return; // لا نبحث إلا بعد كتابة 3 حروف
      try {
        var targetQ = q;
        if (q.contains('الحيوان') && !q.contains('الحيوانات')) {
          targetQ = q.replaceAll('الحيوان', 'الحيوانات');
        }
        
        final queryStr = Uri.encodeComponent(targetQ);
        final url = 'https://nominatim.openstreetmap.org/search?q=$queryStr&format=json&limit=5&accept-language=ar&viewbox=30.80,30.30,31.60,29.80&bounded=1';
        var response = await http.get(Uri.parse(url), headers: {'User-Agent': 'com.example.flutter_app'});
        
        List<dynamic> results = [];
        if (response.statusCode == 200) {
          results = json.decode(response.body);
        }

        // تنظيف ومحاولة أخرى إذا لم تظهر نتائج وكان هناك كلمة تعريفية
        if (results.isEmpty) {
          final cleaned = q.replaceAll(RegExp(r'^(نادي|نادى|شارع|ميدان|منطقة|محطة)\s+'), '').trim();
          if (cleaned != q && cleaned.isNotEmpty) {
            final cleanedQuery = Uri.encodeComponent(cleaned);
            final cleanedUrl = 'https://nominatim.openstreetmap.org/search?q=$cleanedQuery&format=json&limit=5&accept-language=ar&viewbox=30.80,30.30,31.60,29.80&bounded=1';
            response = await http.get(Uri.parse(cleanedUrl), headers: {'User-Agent': 'com.example.flutter_app'});
            if (response.statusCode == 200) {
              results = json.decode(response.body);
            }
          }
        }

        if (!mounted || !_focusNode.hasFocus) return;

        final onlineResults = results.map((p) {
          // تبسيط اسم المكان المعروض
          final displayName = p['display_name'] as String;
          final name = displayName.split(',').first.trim();
          final lat = double.parse(p['lat']);
          final lon = double.parse(p['lon']);
          return PlaceEntry(
            nameAr: name,
            nameEn: name,
            type: PlaceType.region,
            lat: lat,
            lng: lon,
          );
        }).toList();

        setState(() {
          final combined = [..._suggestions];
          for (final online in onlineResults) {
            // تجنب تكرار الاقتراحات
            if (!combined.any((e) => e.nameAr.toLowerCase() == online.nameAr.toLowerCase())) {
              combined.add(online);
            }
          }
          _suggestions = combined.take(7).toList();
          _showDropdown = _suggestions.isNotEmpty;
        });

        if (_showDropdown) {
          if (_overlay != null) {
            _overlay!.markNeedsBuild();
          } else {
            _showOverlay();
          }
        } else {
          _removeOverlay();
        }
      } catch (e) {
        print('Nominatim Autocomplete Error: $e');
      }
    });
  }

  void _selectSuggestion(PlaceEntry entry) {
    widget.controller.text = widget.isAr ? entry.nameAr : entry.nameEn;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.controller.text.length),
    );
    _focusNode.unfocus();
    _removeOverlay();
    setState(() => _showDropdown = false);
    widget.onSelected?.call(entry);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    _overlay = OverlayEntry(
      builder: (ctx) => Positioned(
        width: 340,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(14),
            shadowColor: Colors.black26,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF2D2D2D) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.white12
                      : const Color(0xFFE8ECF4),
                ),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color:
                      widget.isDark ? Colors.white10 : const Color(0xFFF0F3F8),
                ),
                itemBuilder: (_, i) {
                  final entry = _suggestions[i];
                  final label =
                      widget.isAr ? entry.nameAr : entry.nameEn;
                  final sublabel = widget.isAr
                      ? switch (entry.type) {
                          PlaceType.metro  => 'محطة مترو',
                          PlaceType.bus    => 'خط أتوبيس',
                          PlaceType.region => 'منطقة',
                        }
                      : switch (entry.type) {
                          PlaceType.metro  => 'Metro Station',
                          PlaceType.bus    => 'Bus Route',
                          PlaceType.region => 'Area',
                        };
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _selectSuggestion(entry),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: entry.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(entry.icon,
                                color: entry.color, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isDark
                                        ? Colors.white
                                        : const Color(0xFF1A2350),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sublabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: entry.color.withOpacity(0.85),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.north_west_rounded,
                              size: 14,
                              color: widget.isDark
                                  ? Colors.white38
                                  : Colors.grey[400]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlay!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black87,
            fontSize: 14),
        onTap: _onTextChanged,
        onSubmitted: (_) {
          _removeOverlay();
          setState(() => _showDropdown = false);
        },
        decoration: InputDecoration(
          hintText: widget.isAr ? widget.hintAr : widget.hintEn,
          hintStyle: TextStyle(
              color: widget.isDark ? Colors.grey[400] : Colors.grey[500],
              fontSize: 13),
          prefixIcon:
              Icon(widget.prefixIcon, color: const Color(0xFF1F2BDB), size: 20),
          suffixIcon: widget.suffixIcon ??
              (widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.grey, size: 18),
                      onPressed: () {
                        widget.controller.clear();
                        _removeOverlay();
                        setState(() => _showDropdown = false);
                      },
                    )
                  : null),
          filled: true,
          fillColor: widget.isDark
              ? const Color(0xFF2D2D2D)
              : const Color(0xFFF7F9FE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF1F2BDB), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}