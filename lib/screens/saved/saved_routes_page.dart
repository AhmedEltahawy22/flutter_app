import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/localization.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class SavedRoute {
  final String key;        // unique key for deletion
  final String title;      // e.g. "مترو الخط 2 + باص 356"
  final int durationMinutes;
  final int price;
  final List<String> modes; // ["metro", "bus", "walk"]
  final DateTime savedAt;

  SavedRoute({
    required this.key,
    required this.title,
    required this.durationMinutes,
    required this.price,
    required this.modes,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'title': title,
        'durationMinutes': durationMinutes,
        'price': price,
        'modes': modes,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedRoute.fromJson(Map<String, dynamic> j) => SavedRoute(
        key: j['key'] as String,
        title: j['title'] as String,
        durationMinutes: j['durationMinutes'] as int,
        price: j['price'] as int,
        modes: List<String>.from(j['modes'] as List),
        savedAt: DateTime.parse(j['savedAt'] as String),
      );

  /// تحويل الـ key القديم (string) إلى SavedRoute كاملة للـ backward compatibility
  static SavedRoute fromLegacyKey(String key) {
    final parts = key.split('_');
    final price = parts.length >= 3 ? int.tryParse(parts.last) ?? 0 : 0;
    final duration = parts.length >= 2 ? int.tryParse(parts[parts.length - 2]) ?? 0 : 0;
    final title = parts.length >= 3
        ? parts.sublist(0, parts.length - 2).join(' ')
        : key;
    return SavedRoute(
      key: key,
      title: title,
      durationMinutes: duration,
      price: price,
      modes: [],
      savedAt: DateTime.now(),
    );
  }

  static String encodeList(List<SavedRoute> list) =>
      jsonEncode(list.map((r) => r.toJson()).toList());

  static List<SavedRoute> decodeList(String raw) {
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => SavedRoute.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class SavedRoutesPage extends StatefulWidget {
  const SavedRoutesPage({super.key});

  @override
  State<SavedRoutesPage> createState() => _SavedRoutesPageState();
}

class _SavedRoutesPageState extends State<SavedRoutesPage>
    with SingleTickerProviderStateMixin {
  List<SavedRoute> _savedRoutes = [];
  bool _isLoading = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadSaved();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    // محاولة تحميل البيانات الجديدة (JSON كاملة)
    final richRaw = prefs.getString('saved_routes_rich') ?? '';
    if (richRaw.isNotEmpty) {
      final routes = SavedRoute.decodeList(richRaw);
      if (mounted) {
        setState(() {
          _savedRoutes = routes;
          _isLoading = false;
        });
        _animCtrl.forward(from: 0);
      }
      return;
    }

    // Backward compatibility: تحويل الـ keys القديمة
    final oldKeys = prefs.getStringList('saved_trips') ?? [];
    if (oldKeys.isNotEmpty) {
      final routes = oldKeys.map(SavedRoute.fromLegacyKey).toList();
      // حفظهم بالصيغة الجديدة
      await prefs.setString('saved_routes_rich', SavedRoute.encodeList(routes));
      if (mounted) {
        setState(() {
          _savedRoutes = routes;
          _isLoading = false;
        });
        _animCtrl.forward(from: 0);
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = false);
      _animCtrl.forward(from: 0);
    }
  }

  Future<void> _deleteRoute(SavedRoute route) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = _savedRoutes.where((r) => r.key != route.key).toList();
    await prefs.setString('saved_routes_rich', SavedRoute.encodeList(updated));

    // مسح من الـ list القديمة أيضاً للـ consistency
    final oldKeys = prefs.getStringList('saved_trips') ?? [];
    oldKeys.remove(route.key);
    await prefs.setStringList('saved_trips', oldKeys);

    if (mounted) {
      setState(() => _savedRoutes = updated);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.grey[800],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
            content: Text(
              tr(context, 'تم حذف المسار من المحفوظات', 'Route removed from saved'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr(context, 'مسح الكل', 'Clear All')),
        content: Text(tr(
            context,
            'هتحذف كل المسارات المحفوظة. متأكد؟',
            'This will delete all saved routes. Are you sure?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr(context, 'إلغاء', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              tr(context, 'مسح الكل', 'Clear All'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_routes_rich');
      await prefs.remove('saved_trips');
      setState(() => _savedRoutes = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F8),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F2B63), Color(0xFF1F2BDB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F2BDB).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark_rounded,
                          color: Color(0xFFF2C230), size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr(context, 'المسارات المحفوظة', 'Saved Routes'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _savedRoutes.isEmpty
                                  ? tr(context, 'لا توجد مسارات محفوظة بعد',
                                      'No saved routes yet')
                                  : tr(context,
                                      '${_savedRoutes.length} مسار محفوظ',
                                      '${_savedRoutes.length} saved route(s)'),
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (_savedRoutes.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_sweep_rounded,
                              color: Colors.white70),
                          tooltip: tr(context, 'مسح الكل', 'Clear All'),
                          onPressed: _clearAll,
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Content ─────────────────────────────────────────────────────
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: Color(0xFF1F2BDB),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                )
              else if (_savedRoutes.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState(isDark))
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildRouteCard(
                          _savedRoutes[index], isDark),
                      childCount: _savedRoutes.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _buildEmptyState(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2C230).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              size: 42,
              color: Color(0xFFF2C230),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            tr(context, 'لا توجد مسارات محفوظة', 'No Saved Routes'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A2350),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tr(
              context,
              'ابحث عن مسار واضغط على 🔖 لحفظه هنا للرجوع إليه بسهولة.',
              'Search for a route and tap 🔖 to save it here for quick access.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9EA4B5),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Route Card ─────────────────────────────────────────────────────────────
  Widget _buildRouteCard(SavedRoute route, bool isDark) {
    return Dismissible(
      key: Key(route.key),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => _deleteRoute(route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // ── Icon ──
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF2C230).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.bookmark_rounded,
                color: Color(0xFFF2C230),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // ── Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A2350),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _metaChip(
                        Icons.access_time_rounded,
                        '${route.durationMinutes} ${tr(context, "د", "min")}',
                        const Color(0xFF9C27B0),
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      _metaChip(
                        Icons.payments_rounded,
                        '${route.price} ${tr(context, "ج.م", "EGP")}',
                        const Color(0xFF2E7D32),
                        isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // وسائل النقل
                  if (route.modes.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: route.modes.map((m) => _modeIcon(m)).toList(),
                    ),
                ],
              ),
            ),

            // ── Delete button ──
            IconButton(
              onPressed: () => _deleteRoute(route),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.red, size: 20),
              tooltip: tr(context, 'حذف', 'Delete'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _modeIcon(String mode) {
    final Map<String, Map<String, dynamic>> modes = {
      'metro': {'icon': Icons.subway_rounded, 'color': const Color(0xFF1F2BDB)},
      'bus': {'icon': Icons.directions_bus_rounded, 'color': const Color(0xFFE65100)},
      'walk': {'icon': Icons.directions_walk_rounded, 'color': const Color(0xFF27AE60)},
      'microbus': {'icon': Icons.airport_shuttle_rounded, 'color': const Color(0xFF8D6E63)},
      'tram': {'icon': Icons.tram_rounded, 'color': const Color(0xFFFF6F00)},
    };
    final data = modes[mode] ??
        {'icon': Icons.directions_rounded, 'color': Colors.grey};
    return Icon(data['icon'] as IconData,
        size: 18, color: data['color'] as Color);
  }
}

// ─── Helper: save a route from SearchTripsPage ─────────────────────────────
class SavedRoutesHelper {
  static Future<void> saveRoute({
    required String key,
    required String title,
    required int durationMinutes,
    required int price,
    required List<String> modes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_routes_rich') ?? '[]';
    final routes = SavedRoute.decodeList(raw);

    // منع التكرار
    if (routes.any((r) => r.key == key)) return;

    routes.insert(
      0,
      SavedRoute(
        key: key,
        title: title,
        durationMinutes: durationMinutes,
        price: price,
        modes: modes,
        savedAt: DateTime.now(),
      ),
    );
    await prefs.setString('saved_routes_rich', SavedRoute.encodeList(routes));

    // تحديث الـ list القديمة للـ compatibility
    final oldKeys = prefs.getStringList('saved_trips') ?? [];
    if (!oldKeys.contains(key)) {
      oldKeys.insert(0, key);
      await prefs.setStringList('saved_trips', oldKeys);
    }
  }

  static Future<void> removeRoute(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_routes_rich') ?? '[]';
    final routes = SavedRoute.decodeList(raw)
        .where((r) => r.key != key)
        .toList();
    await prefs.setString('saved_routes_rich', SavedRoute.encodeList(routes));

    final oldKeys = prefs.getStringList('saved_trips') ?? [];
    oldKeys.remove(key);
    await prefs.setStringList('saved_trips', oldKeys);
  }

  static Future<bool> isRouteSaved(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getStringList('saved_trips') ?? [];
    return keys.contains(key);
  }
}
