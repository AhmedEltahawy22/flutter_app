import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/localization.dart';
import '../models/recent_trip.dart';
import 'profile/profile_page.dart';
import 'search/search_page.dart';
import 'settings/settings_page.dart';
import 'stats/stats_page.dart';
import 'ticket/qr_ticket_page.dart';
import 'wallet/wallet_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0;
  String _userName = '';
  List<RecentTrip> _recentTrips = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('name') ?? '';
        final raw = prefs.getString('recent_trips') ?? '[]';
        _recentTrips = RecentTrip.decodeList(raw);
      });
    }
  }

  // يعيد تحميل البيانات عند الرجوع من شاشة أخرى
  void _goToProfile() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ProfilePage()));
    _loadData(); // يحدّث الاسم بعد التعديل
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          _buildHomeContent(),
          const SearchPage(),
          const WalletPage(),
          const StatsPage(),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          if (index == 0) _loadData(); // يحدّث الرحلات عند الرجوع للهوم
        },
        selectedItemColor: isDark ? const Color(0xFFF2C230) : const Color(0xFF1F2BDB),
        unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: tr(context, 'الرئيسية', 'Home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_outlined),
            activeIcon: const Icon(Icons.search),
            label: tr(context, 'بحث', 'Search'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            activeIcon: const Icon(Icons.account_balance_wallet),
            label: tr(context, 'المحفظة', 'Wallet'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart_outlined),
            activeIcon: const Icon(Icons.bar_chart_rounded),
            label: tr(context, 'إحصائيات', 'Stats'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: tr(context, 'الإعدادات', 'Settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const QRTicketPage()),
          );
        },
        backgroundColor: const Color(0xFFF2C230),
        foregroundColor: const Color(0xFF1F2B63),
        elevation: 4,
        child: const Icon(Icons.qr_code_scanner, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHomeContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(context, 'أهلاً بك،', 'Welcome back,'),
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      Text(
                        _userName.isNotEmpty
                            ? _userName
                            : tr(context, 'مستخدم', 'User'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1F2B63),
                        ),
                      ),
                    ],
                  ),
                  // Avatar يفتح صفحة البروفايل
                  GestureDetector(
                    onTap: _goToProfile,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1F2BDB),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1F2BDB).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Search Banner ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F2BDB), Color(0xFF1F2B63)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1F2BDB).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(context, 'إلى أين تريد الذهاب اليوم؟',
                          'Where to go today?'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr(context, 'ابحث عن أفضل المسارات المتاحة',
                          'Find the best available routes'),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => _bottomNavIndex = 1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2C230),
                        foregroundColor: const Color(0xFF1F2B63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(
                          tr(context, 'ابدأ البحث الآن', 'Start searching now')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ── Recent Trips ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr(context, 'الرحلات الأخيرة', 'Recent Trips'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2B63),
                    ),
                  ),
                  if (_recentTrips.isNotEmpty)
                    TextButton(
                      onPressed: () =>
                          setState(() => _bottomNavIndex = 1),
                      child: Text(
                        tr(context, 'بحث جديد', 'New Search'),
                        style: const TextStyle(
                            color: Color(0xFF1F2BDB), fontSize: 13),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // إذا كانت فيه رحلات → اعرضها | لو مفيش → رسالة فارغة
              if (_recentTrips.isEmpty)
                _buildEmptyTrips(isDark)
              else
                ...List.generate(
                  _recentTrips.length > 3 ? 3 : _recentTrips.length,
                  (i) => _buildRecentTripCard(_recentTrips[i], isDark),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Widget _buildEmptyTrips(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.route_outlined,
              size: 52, color: isDark ? Colors.grey[700] : const Color(0xFFD0D3E8)),
          const SizedBox(height: 12),
          Text(
            tr(context, 'لا توجد رحلات سابقة', 'No recent trips yet'),
            style: TextStyle(
              color: isDark ? Colors.grey[400] : const Color(0xFF9EA4B5),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tr(
              context,
              'ابحث عن مسار وابدأ رحلتك لتظهر هنا.',
              'Search for a route and start a trip to see it here.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB0B5C8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTripCard(RecentTrip trip, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.history, color: isDark ? Colors.white70 : const Color(0xFF1F2BDB)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip.fromName} ➔ ${trip.toName}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.durationMinutes} ${tr(context, "دقيقة", "min")}',
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.payments_outlined,
                        size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.price} ${tr(context, "ج.م", "EGP")}',
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}