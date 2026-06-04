import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/localization.dart';
import '../../providers/app_wallet_scope.dart';
import 'gate_simulation_page.dart';

class QRTicketPage extends StatefulWidget {
  const QRTicketPage({super.key});

  @override
  State<QRTicketPage> createState() => _QRTicketPageState();
}

class _QRTicketPageState extends State<QRTicketPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  final TextEditingController _cardController = TextEditingController();
  bool _isLinking = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _linkCard(BuildContext context, String? currentCardId) async {
    if (_cardController.text.trim().isEmpty) return;
    setState(() => _isLinking = true);
    await Future.delayed(const Duration(milliseconds: 800)); // simulate linking
    if (mounted) {
      AppWalletScope.linkCard(context, _cardController.text.trim());
      setState(() => _isLinking = false);
      _cardController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            tr(context, '✅ تم ربط الكارت بنجاح!', '✅ Card linked successfully!'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  void _unlinkCard(BuildContext context) {
    AppWalletScope.linkCard(context, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2350),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          tr(context, 'تذكرة العبور', 'Boarding Pass'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<WalletState>(
        valueListenable: AppWalletScope.notifierOf(context),
        builder: (context, walletState, _) {
          final hasLinkedCard =
              walletState.linkedCardId != null &&
              walletState.linkedCardId!.isNotEmpty;
          final hasBalance = walletState.balance >= 8.0;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // ── NFC CARD SECTION ──────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: hasLinkedCard
                            ? [const Color(0xFF1B4F3A), const Color(0xFF27AE60)]
                            : [const Color(0xFF2C3672), const Color(0xFF3D4FA0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (hasLinkedCard
                                  ? Colors.green
                                  : const Color(0xFF3D4FA0))
                              .withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: hasLinkedCard
                        ? _buildLinkedCardView(context, walletState)
                        : _buildLinkCardForm(context),
                  ),

                  const SizedBox(height: 24),

                  // ── QR CODE SECTION ──────────────────────────────────────
                  _buildQrSection(context, walletState, hasBalance),

                  const SizedBox(height: 20),

                  // ── INFO TEXT ─────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.white60, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tr(
                              context,
                              'سيتم خصم الأجرة تلقائياً حسب مسافة رحلتك عند الخروج.',
                              'Fare will be deducted automatically based on your travel distance upon exit.',
                            ),
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GateSimulationPage()),
          );
        },
        backgroundColor: const Color(0xFF1F2BDB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.nfc_rounded),
        label: Text(tr(context, 'محاكاة البوابة', 'Gate Sim')),
      ),
    );
  }

  // ── Widget: Linked Card ───────────────────────────────────────────────────
  Widget _buildLinkedCardView(BuildContext context, WalletState walletState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.nfc_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(context, 'كارت النقل الذكي مربوط', 'Smart Transit Card Linked'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${walletState.linkedCardId}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.white, size: 28),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(color: Colors.white24),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr(context, 'الرصيد المتاح (مترو + أتوبيس)', 'Available Balance (Metro & Bus)'),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            Text(
              '${walletState.balance.toStringAsFixed(2)} ${tr(context, 'ج.م', 'EGP')}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _unlinkCard(context),
          child: Text(
            tr(context, 'إلغاء ربط الكارت', 'Unlink Card'),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // ── Widget: Link Card Form ────────────────────────────────────────────────
  Widget _buildLinkCardForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.nfc_rounded, color: Colors.white70, size: 28),
            ),
            const SizedBox(width: 14),
            Text(
              tr(context, 'ربط كارت النقل الذكي (NFC)', 'Link Smart Transit Card (NFC)'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          tr(
            context,
            'اربط كارتك بالمحفظة لخصم الأجرة تلقائياً سواء في المترو أو الأتوبيس.',
            'Link your card to the wallet to automatically deduct fares on metro and buses.',
          ),
          style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cardController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                  LengthLimitingTextInputFormatter(20),
                ],
                style: const TextStyle(color: Colors.white, letterSpacing: 1.5),
                decoration: InputDecoration(
                  hintText: tr(context, 'رقم الكارت (مثال: A1B2-C3D4)', 'Card ID (e.g. A1B2-C3D4)'),
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _isLinking
                  ? null
                  : () => _linkCard(
                      context, AppWalletScope.notifierOf(context).value.linkedCardId),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                decoration: BoxDecoration(
                  color: _isLinking ? Colors.white24 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLinking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        tr(context, 'ربط', 'Link'),
                        style: const TextStyle(
                          color: Color(0xFF1A2350),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Widget: QR Code ───────────────────────────────────────────────────────
  Widget _buildQrSection(
      BuildContext context, WalletState walletState, bool hasBalance) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _pulseAnimation.value, child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: const Color(0xFFF2C230).withOpacity(0.25),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_2_rounded,
                    color: Color(0xFF1F2B63), size: 20),
                const SizedBox(width: 8),
                Text(
                  tr(context, 'وسيلة العبور البديلة', 'Alternative Digital Pass'),
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1F2B63),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tr(context, 'امسح الكود عند البوابة', 'Scan at the gate'),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            // QR
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF3F4F8), width: 3),
              ),
              child: QrImageView(
                data: 'MOCK_USER_TOKEN_123456789',
                version: QrVersions.auto,
                size: 180.0,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF1F2B63),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF1F2BDB),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(thickness: 1.5, height: 1.5, color: isDark ? Colors.white12 : const Color(0xFFF3F4F8)),
            const SizedBox(height: 20),
            // Balance row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr(context, 'رصيدك الحالي', 'Current Balance'),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  '${walletState.balance.toStringAsFixed(2)} ${tr(context, 'ج.م', 'EGP')}',
                  style: TextStyle(
                    color: hasBalance ? Colors.green : Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (!hasBalance) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.red, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tr(
                          context,
                          'رصيدك لا يكفي للرحلة، يرجى شحن المحفظة.',
                          'Insufficient balance, please top up your wallet.',
                        ),
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
