import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
      final placeName = await PublicTransportService.reverseGeocode(
          pos.latitude, pos.longitude);
      if (mounted) {
        _fromController.text = placeName ??
            '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
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
                    // ── FROM field ────────────────────────────────
                    _PlaceAutocomplete(
                      controller: _fromController,
                      hintAr: 'من (ابحث عن منطقة أو محطة)',
                      hintEn: 'From (Search area or station)',
                      prefixIcon: Icons.trip_origin,
                      isAr: isAr,
                      isDark: isDark,
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
                          final tmp = _fromController.text;
                          _fromController.text = _toController.text;
                          _toController.text = tmp;
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2C230).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.swap_vert_rounded,
                              color: Color(0xFF1F2B63), size: 22),
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

  const _PlaceAutocomplete({
    required this.controller,
    required this.hintAr,
    required this.hintEn,
    required this.prefixIcon,
    required this.isAr,
    required this.isDark,
    this.suffixIcon,
  });

  @override
  State<_PlaceAutocomplete> createState() => _PlaceAutocompleteState();
}

class _PlaceAutocompleteState extends State<_PlaceAutocomplete> {
  List<PlaceEntry> _suggestions = [];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final q = widget.controller.text;
    final results = PlacesData.search(q, limit: 7);
    setState(() {
      _suggestions = results;
      _showDropdown = results.isNotEmpty && q.isNotEmpty;
    });
    if (_showDropdown) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _selectSuggestion(PlaceEntry entry) {
    widget.controller.text = widget.isAr ? entry.nameAr : entry.nameEn;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.controller.text.length),
    );
    _removeOverlay();
    setState(() => _showDropdown = false);
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
        style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black87,
            fontSize: 14),
        onTap: _onTextChanged,
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