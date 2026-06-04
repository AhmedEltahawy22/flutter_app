import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/localization.dart';
import '../../metro_graph.dart';
import '../../providers/app_language_scope.dart';
import '../../public_transport_data.dart';
import '../../public_transport_service.dart';
import 'search_trips_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}
class _SearchPageState extends State<SearchPage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
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
      final placeName = await PublicTransportService.reverseGeocode(pos.latitude, pos.longitude);
      if (mounted) {
        _fromController.text = placeName ?? '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      tr(context, 'اختار نقطة البداية والوجهة', 'Choose start and destination'),
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
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDark ? [] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Pure Free Text Field
                    TextField(
                      controller: _fromController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: tr(context, 'من (اكتب اسم المكان)', 'From (Type place name)'),
                        hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        prefixIcon: const Icon(Icons.trip_origin, color: Color(0xFF1F2BDB)),
                        suffixIcon: _isLocating
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : IconButton(
                                icon: const Icon(Icons.my_location_rounded, color: Color(0xFF1F2BDB)),
                                tooltip: tr(context, 'موقعي الحالي', 'My Location'),
                                onPressed: _detectLocation,
                              ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF7F9FE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Pure Free Text Field
                    TextField(
                      controller: _toController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: tr(context, 'إلى (اكتب اسم المكان)', 'To (Type place name)'),
                        hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        prefixIcon: const Icon(Icons.place_outlined, color: Color(0xFF1F2BDB)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF7F9FE),
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
                        _modeChip('bus', context, isDark),
                        _modeChip('metro', context, isDark),
                        _modeChip('train', context, isDark),
                        _modeChip('microbus', context, isDark),
                        _modeChip('walk', context, isDark),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final from = _fromController.text.trim();
                          final to = _toController.text.trim();
                          if (from.isEmpty || to.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red.shade700,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                content: Text(
                                  tr(context, 'يرجى كتابة نقطة الانطلاق والوجهة',
                                      'Please enter both origin and destination'),
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
                        ),
                        child: Text(tr(context, 'ابحث عن المسارات', 'Find Routes')),
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

  List<DropdownMenuEntry<String>> _getSearchEntries(BuildContext context) {
    final Set<String> uniqueNames = {};
    final List<DropdownMenuEntry<String>> entries = [];
    final isAr = AppLanguageScope.notifierOf(context).value == 'ar';

    // Add Metro stations
    for (final s in MetroGraph.stations.values) {
      final name = isAr ? s.nameAr : s.nameEn;
      final label = isAr ? '$name (مترو)' : '$name (Metro)';
      if (!uniqueNames.contains(label)) {
        uniqueNames.add(label);
        entries.add(DropdownMenuEntry(value: s.id, label: label));
      }
    }

    // Add Bus regions
    final busRegions =
        isAr ? PublicTransportData.regionsAr : PublicTransportData.regionsEn;
    for (final region in busRegions) {
      final label = isAr ? '$region (أتوبيس)' : '$region (Bus)';
      if (!uniqueNames.contains(label)) {
        uniqueNames.add(label);
        entries.add(DropdownMenuEntry(value: region, label: label));
      }
    }
    return entries;
  }



  Widget _modeChip(String mode, BuildContext context, bool isDark) {
    final selected = _selectedModes.contains(mode);
    final label = switch (mode) {
      'bus' => tr(context, 'أتوبيس', 'Bus'),
      'metro' => tr(context, 'مترو', 'Metro'),
      'train' => tr(context, 'قطار', 'Train'),
      'microbus' => tr(context, 'ميكروباص', 'Microbus'),
      _ => tr(context, 'مشي', 'Walk'),
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
        color: selected ? const Color(0xFF1F2B63) : (isDark ? Colors.white70 : Colors.black87),
      ),
      backgroundColor: isDark ? const Color(0xFF2D2D2D) : null,
      selectedColor: const Color(0xFFF2C230),
      checkmarkColor: const Color(0xFF1F2B63),
    );
  }
}