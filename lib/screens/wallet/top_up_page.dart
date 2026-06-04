import 'package:flutter/material.dart';
import '../../core/localization.dart';
import '../../providers/app_wallet_scope.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _amountController = TextEditingController();
  int _selectedMethodIndex = 0;

  final List<Map<String, dynamic>> _methods = [
    {
      'icon': Icons.credit_card,
      'titleAr': 'بطاقة ائتمان',
      'titleEn': 'Credit Card',
    },
    {
      'icon': Icons.account_balance_wallet,
      'titleAr': 'المحافظ الإلكترونية',
      'titleEn': 'E-Wallets (Vodafone Cash, etc.)',
    },
    {
      'icon': Icons.account_balance,
      'titleAr': 'تحويل بنكي',
      'titleEn': 'Bank Transfer',
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _processPayment() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, 'الرجاء إدخال المبلغ', 'Please enter an amount'))),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, 'الرجاء إدخال مبلغ صحيح', 'Please enter a valid amount'))),
      );
      return;
    }

    // Process top up locally (mocking backend call)
    AppWalletScope.topUp(context, amount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr(context, 'تم شحن الرصيد بنجاح!', 'Top-up successful!')),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(); // Return to wallet page
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F8),
      appBar: AppBar(
        title: Text(
          tr(context, 'شحن الرصيد', 'Top Up Balance'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1F2B63),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(context, 'المبلغ المراد شحنه (جنيه)', 'Amount to Top Up (EGP)'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1F2B63),
                ),
              ),
              const SizedBox(height: 12),
              Container(
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
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                    prefixIcon: const Icon(Icons.payments_outlined, color: Color(0xFF1F2BDB)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [20, 50, 100, 200].map((val) {
                  return ActionChip(
                    label: Text('+$val'),
                    backgroundColor: const Color(0xFF1F2BDB).withOpacity(0.1),
                    labelStyle: const TextStyle(color: Color(0xFF1F2BDB), fontWeight: FontWeight.bold),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      final current = double.tryParse(_amountController.text) ?? 0;
                      _amountController.text = (current + val).toStringAsFixed(0);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Text(
                tr(context, 'طريقة الدفع', 'Payment Method'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1F2B63),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(_methods.length, (index) {
                final method = _methods[index];
                final isSelected = _selectedMethodIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMethodIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1F2BDB) : Colors.transparent,
                        width: 2,
                      ),
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
                        Icon(method['icon'], color: isSelected ? const Color(0xFF1F2BDB) : Colors.grey[600]),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            tr(context, method['titleAr'], method['titleEn']),
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Color(0xFF1F2BDB)),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2C230),
                  foregroundColor: const Color(0xFF1F2B63),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size.fromHeight(52),
                  elevation: 4,
                  shadowColor: const Color(0xFFF2C230).withOpacity(0.4),
                ),
                child: Text(
                  tr(context, 'تأكيد الدفع', 'Confirm Payment'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
