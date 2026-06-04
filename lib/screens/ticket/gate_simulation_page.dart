import 'package:flutter/material.dart';
import '../../core/localization.dart';
import '../../providers/app_wallet_scope.dart';

class GateSimulationPage extends StatefulWidget {
  const GateSimulationPage({super.key});

  @override
  State<GateSimulationPage> createState() => _GateSimulationPageState();
}

class _GateSimulationPageState extends State<GateSimulationPage> {
  bool _isScanning = false;
  bool? _isSuccess;
  String _message = '';

  void _simulateScan(BuildContext context, WalletState walletState) async {
    setState(() {
      _isScanning = true;
      _isSuccess = null;
      _message = tr(context, 'جاري قراءة الكارت...', 'Reading card...');
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (walletState.linkedCardId == null || walletState.linkedCardId!.isEmpty) {
      setState(() {
        _isScanning = false;
        _isSuccess = false;
        _message = tr(context, 'لا يوجد كارت مربوط بالمحفظة', 'No card linked to wallet');
      });
      return;
    }

    if (walletState.balance < 8.0) {
      setState(() {
        _isScanning = false;
        _isSuccess = false;
        _message = tr(context, 'الرصيد غير كافٍ (أقل من 8 جنيهات)', 'Insufficient balance (less than 8 EGP)');
      });
      return;
    }

    // Success
    AppWalletScope.deduct(context, 8.0, 'رحلة (محاكاة)', 'Trip (Simulated)'); // Simulate an 8 EGP ride
    
    if (mounted) {
      setState(() {
        _isScanning = false;
        _isSuccess = true;
        _message = tr(context, 'تم العبور بنجاح! خصم 8.0 ج.م', 'Access granted! 8.0 EGP deducted');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text(
          tr(context, 'محاكاة البوابة الذكية', 'Smart Gate Simulation'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1F2B63),
        elevation: 0,
      ),
      body: ValueListenableBuilder<WalletState>(
        valueListenable: AppWalletScope.notifierOf(context),
        builder: (context, walletState, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.nfc_rounded,
                    size: 100,
                    color: _isScanning 
                        ? const Color(0xFFF2C230) 
                        : (_isSuccess == true 
                            ? Colors.green 
                            : (_isSuccess == false ? Colors.red : (isDark ? Colors.white54 : Colors.black26))),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _message.isEmpty 
                        ? tr(context, 'اضغط للمحاكاة وتمرير الكارت', 'Tap to simulate scanning card')
                        : _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2B63),
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: _isScanning ? null : () => _simulateScan(context, walletState),
                    icon: const Icon(Icons.tap_and_play_rounded),
                    label: Text(
                      tr(context, 'محاكاة العبور', 'Simulate Gate Entry'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F2BDB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
