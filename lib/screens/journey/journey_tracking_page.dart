import 'package:flutter/material.dart';
import '../../core/localization.dart';
import '../../providers/app_wallet_scope.dart';
import '../../routing_service.dart';

class JourneyTrackingPage extends StatefulWidget {
  const JourneyTrackingPage({super.key, required this.segments});

  final List<RouteSegment> segments;

  @override
  State<JourneyTrackingPage> createState() => _JourneyTrackingPageState();
}
class _JourneyTrackingPageState extends State<JourneyTrackingPage> {
  int _completedSteps = 0;
  bool _walletDeducted = false; // منع الخصم أكثر من مرة

  int get _totalSteps => widget.segments.length;
  int get _currentStepDisplay => (_completedSteps + 1).clamp(1, _totalSteps);
  double get _progress => _totalSteps == 0 ? 0 : _completedSteps / _totalSteps;

  String _currentStepLabel(BuildContext context) {
    if (_completedSteps >= _totalSteps) {
      return tr(context, 'تم إنهاء الرحلة', 'Journey completed');
    }
    return widget.segments[_completedSteps].title;
  }

  void _advanceStep() {
    if (_completedSteps >= _totalSteps) return;
    setState(() {
      _completedSteps++;
    });
    // ✅ خصم الرصيد من المحفظة عند اكتمال الرحلة
    if (_completedSteps >= _totalSteps && !_walletDeducted) {
      _walletDeducted = true;
      _deductTripFare();
    }
  }

  void _deductTripFare() {
    // حساب تكلفة الرحلة من عدد الـ segments غير المشي
    final nonWalkSegments = widget.segments.where((s) => s.mode != 'walk').length;
    final farePerSegment = 7.0; // 7 جنيه لكل وسيلة نقل
    final totalFare = nonWalkSegments > 0 ? nonWalkSegments * farePerSegment : 5.0;

    final walletNotifier = AppWalletScope.notifierOf(context);
    if (walletNotifier.value.balance >= totalFare) {
      AppWalletScope.deduct(
        context,
        totalFare,
        'أجرة رحلة',
        'Trip Fare',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1F2BDB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            tr(context, '✅ تم خصم ${totalFare.toStringAsFixed(0)} ج.م من محفظتك', '✅ ${totalFare.toStringAsFixed(0)} EGP deducted from your wallet'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            tr(context, '⚠️ رصيدك غير كافٍ، يرجى شحن المحفظة', '⚠️ Insufficient balance, please top up your wallet'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent = (_progress * 100).round();
    final inProgressText = _completedSteps >= _totalSteps
        ? tr(context, 'تم الوصول إلى الوجهة', 'Arrived to destination')
        : '${widget.segments[_completedSteps].title} ${tr(context, 'قيد التنفيذ...', 'in progress...')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2BDB),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        BackButton(color: Colors.white),
                      ],
                    ),
                    Text(
                      tr(context, 'رحلتك', 'Your Journey'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr(
                        context,
                        'الخطوة $_currentStepDisplay من $_totalSteps',
                        'Step $_currentStepDisplay of $_totalSteps',
                      ),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            tr(context, 'التقدم', 'Progress'),
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                          const Spacer(),
                          Text(
                            '$progressPercent%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 7,
                          backgroundColor: const Color(0xFFE6E8EF),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFF2C230),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2C230),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.navigation_outlined, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _completedSteps >= _totalSteps
                                    ? tr(context, 'الرحلة مكتملة', 'Trip complete')
                                    : _currentStepLabel(context),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F2B63),
                                ),
                              ),
                            ),
                            if (_completedSteps < _totalSteps)
                              Text(
                                tr(context, 'قيد التنفيذ...', 'in progress...'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF1F2B63),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        tr(context, 'خطوات الرحلة', 'Journey Steps'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2B63),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: widget.segments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final segment = widget.segments[index];
                            final isDone = index < _completedSteps;
                            final isCurrent = index == _completedSteps;
                            return Row(
                              children: [
                                Icon(
                                  isDone
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 16,
                                  color: isDone
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFBFC4D1),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? const Color(0xFFF2C230)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      segment.mode == 'walk'
                                          ? tr(
                                              context,
                                              '${segment.title} إلى النقطة التالية',
                                              '${segment.title} to next point',
                                            )
                                          : segment.subtitle,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDone
                                            ? Colors.grey[600]
                                            : const Color(0xFF3A4256),
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE4E7F1)),
                        ),
                        child: Text(
                          tr(
                            context,
                            'هذه رحلة تجريبية مبنية على بيانات ثابتة.\nقد تختلف الظروف الفعلية.',
                            'This is a simulated journey based on static data.\nActual conditions may vary.',
                          ),
                          style: TextStyle(fontSize: 10, color: Color(0xFF667085)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _advanceStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2BDB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _completedSteps >= _totalSteps
                        ? tr(context, 'تم إنهاء الرحلة', 'Journey Finished')
                        : tr(context, 'تحديد الوصول للنقطة التالية', 'Mark Next Point Reached'),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                inProgressText,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}