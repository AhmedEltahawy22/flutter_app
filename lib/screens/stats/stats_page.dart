import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization.dart';
import '../../models/recent_trip.dart';
import '../../models/transaction.dart';
import '../../providers/app_wallet_scope.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  List<RecentTrip> _recentTrips = [];
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadTrips();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('recent_trips') ?? '[]';
    if (mounted) {
      setState(() => _recentTrips = RecentTrip.decodeList(raw));
      _animCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallet = AppWalletScope.notifierOf(context).value;

    // ── حساب الإحصائيات ─────────────────────────────────────
    final totalTrips = _recentTrips.length;
    final totalMinutes =
        _recentTrips.fold(0, (s, t) => s + t.durationMinutes);
    final totalSpentTransit =
        _recentTrips.fold(0, (s, t) => s + t.price);
    // تكلفة التاكسي التقريبية = 25 ج.م أساسي + 5 ج.م / كم (نفترض متوسط 5 كم/رحلة)
    final taxiCostEstimate = totalTrips * 50;
    final moneySaved = taxiCostEstimate - totalSpentTransit;
    // CO₂: سيارة تبعث ~120 جرام/كم، متوسط رحلة ~8كم = 960 جرام = ~1 كجم/رحلة
    final co2SavedKg = (totalTrips * 0.96).toStringAsFixed(1);
    // إجمالي الشحنات من محفظة
    final totalTopUp = wallet.transactions
        .where((t) => t.type == TransactionType.topUp)
        .fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F8),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            slivers: [
              // ── App Bar ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A2350), Color(0xFF1F2BDB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F2BDB).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bar_chart_rounded,
                          color: Color(0xFFF2C230), size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr(context, 'إحصائياتك', 'Your Statistics'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            tr(context, 'ملخص رحلاتك مع مواصلاتي',
                                'Your journey summary'),
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Main Stats Grid ────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                  ),
                  delegate: SliverChildListDelegate([
                    _StatCard(
                      icon: Icons.directions_transit_rounded,
                      iconColor: const Color(0xFF1F2BDB),
                      label: tr(context, 'إجمالي الرحلات', 'Total Trips'),
                      value: '$totalTrips',
                      unit: tr(context, 'رحلة', 'trips'),
                      isDark: isDark,
                    ),
                    _StatCard(
                      icon: Icons.schedule_rounded,
                      iconColor: const Color(0xFF9C27B0),
                      label: tr(context, 'وقت التنقل', 'Travel Time'),
                      value: totalMinutes < 60
                          ? '$totalMinutes'
                          : '${(totalMinutes / 60).toStringAsFixed(1)}',
                      unit: totalMinutes < 60
                          ? tr(context, 'دقيقة', 'min')
                          : tr(context, 'ساعة', 'hrs'),
                      isDark: isDark,
                    ),
                    _StatCard(
                      icon: Icons.payments_rounded,
                      iconColor: const Color(0xFF2E7D32),
                      label: tr(context, 'إجمالي الإنفاق', 'Total Spent'),
                      value: '$totalSpentTransit',
                      unit: tr(context, 'ج.م', 'EGP'),
                      isDark: isDark,
                    ),
                    _StatCard(
                      icon: Icons.savings_rounded,
                      iconColor: const Color(0xFFF2C230),
                      label: tr(context, 'وفّرت عن التاكسي', 'Saved vs Taxi'),
                      value: moneySaved > 0 ? '$moneySaved' : '0',
                      unit: tr(context, 'ج.م', 'EGP'),
                      isDark: isDark,
                      highlight: moneySaved > 0,
                    ),
                  ]),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── CO2 Banner ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B4F3A), Color(0xFF27AE60)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('🌿', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr(context, 'أثرك البيئي 🌍',
                                  'Your Eco Impact 🌍'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr(
                                context,
                                'وفّرت $co2SavedKg كجم CO₂ عن طريق استخدام النقل العام بدل السيارة الخاصة.',
                                'You saved $co2SavedKg kg of CO₂ by using public transit instead of a private car.',
                              ),
                              style: const TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Wallet Summary ─────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded,
                              color: Color(0xFF1F2BDB), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            tr(context, 'ملخص المحفظة', 'Wallet Summary'),
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1A2350),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _walletRow(
                        context,
                        tr(context, 'الرصيد الحالي', 'Current Balance'),
                        '${wallet.balance.toStringAsFixed(2)} ${tr(context, 'ج.م', 'EGP')}',
                        const Color(0xFF1F2BDB),
                        isDark,
                      ),
                      const Divider(height: 20),
                      _walletRow(
                        context,
                        tr(context, 'إجمالي الشحنات', 'Total Topped Up'),
                        '${totalTopUp.toStringAsFixed(2)} ${tr(context, 'ج.م', 'EGP')}',
                        Colors.green,
                        isDark,
                      ),
                      const Divider(height: 20),
                      _walletRow(
                        context,
                        tr(context, 'عدد المعاملات', 'Transactions'),
                        '${wallet.transactions.length}',
                        Colors.orange,
                        isDark,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Recent Trips List ──────────────────────────────
              if (_recentTrips.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                    child: Text(
                      tr(context, 'آخر الرحلات', 'Recent Trips'),
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF1A2350),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final trip = _recentTrips[i];
                      return Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2BDB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.route_rounded,
                                color: Color(0xFF1F2BDB),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${trip.fromName} → ${trip.toName}',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1A2350),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${trip.durationMinutes} ${tr(context, 'دقيقة', 'min')} • ${trip.price} ${tr(context, 'ج.م', 'EGP')}',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatDate(trip.date),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: _recentTrips.length,
                  ),
                ),
              ] else ...[
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.directions_transit_outlined,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          tr(context, 'لا توجد رحلات بعد!\nابدأ رحلتك الأولى الآن.',
                              'No trips yet!\nStart your first journey now.'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 14, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _walletRow(BuildContext context, String label, String value,
      Color valueColor, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;
  final bool isDark;
  final bool highlight;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.unit,
    required this.isDark,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0xFFF2C230).withOpacity(isDark ? 0.15 : 0.08)
            : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: highlight
            ? Border.all(
                color: const Color(0xFFF2C230).withOpacity(0.5), width: 1.5)
            : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A2350),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      unit,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
