import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class WalletState {
  final double balance;
  final List<Transaction> transactions;
  final String? linkedCardId;

  WalletState({
    required this.balance,
    required this.transactions,
    this.linkedCardId,
  });

  WalletState copyWith({
    double? balance,
    List<Transaction>? transactions,
    String? linkedCardId,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      linkedCardId: linkedCardId ?? this.linkedCardId,
    );
  }
}

// ─── Persistence Helper ─────────────────────────────────────────────────────
class WalletPersistence {
  static const _keyBalance = 'wallet_balance';
  static const _keyTransactions = 'wallet_transactions';
  static const _keyCardId = 'wallet_card_id';

  /// تحميل بيانات المحفظة من التخزين المحلي
  static Future<WalletState> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final balance = prefs.getDouble(_keyBalance) ?? 0.0;
      final txRaw = prefs.getString(_keyTransactions) ?? '[]';
      final transactions = Transaction.decodeList(txRaw);
      final cardId = prefs.getString(_keyCardId);
      return WalletState(
        balance: balance,
        transactions: transactions,
        linkedCardId: cardId,
      );
    } catch (_) {
      return WalletState(balance: 0.0, transactions: []);
    }
  }

  /// حفظ بيانات المحفظة في التخزين المحلي (في الخلفية)
  static void save(WalletState state) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble(_keyBalance, state.balance);
      prefs.setString(
          _keyTransactions, Transaction.encodeList(state.transactions));
      if (state.linkedCardId != null && state.linkedCardId!.isNotEmpty) {
        prefs.setString(_keyCardId, state.linkedCardId!);
      } else {
        prefs.remove(_keyCardId);
      }
    });
  }
}

// ─── AppWalletScope ─────────────────────────────────────────────────────────
class AppWalletScope extends InheritedNotifier<ValueNotifier<WalletState>> {
  const AppWalletScope({
    super.key,
    required ValueNotifier<WalletState> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ValueNotifier<WalletState> notifierOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppWalletScope>();
    assert(scope != null, 'AppWalletScope not found in widget tree');
    return scope!.notifier!;
  }

  static void topUp(BuildContext context, double amount) {
    final notifier = notifierOf(context);
    final currentState = notifier.value;

    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      date: DateTime.now(),
      titleAr: 'إيداع رصيد',
      titleEn: 'Balance Top-up',
      type: TransactionType.topUp,
    );

    final newState = currentState.copyWith(
      balance: currentState.balance + amount,
      transactions: [newTransaction, ...currentState.transactions],
    );
    notifier.value = newState;
    WalletPersistence.save(newState); // حفظ تلقائي
  }

  static void deduct(
      BuildContext context, double amount, String titleAr, String titleEn) {
    final notifier = notifierOf(context);
    final currentState = notifier.value;

    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      date: DateTime.now(),
      titleAr: titleAr,
      titleEn: titleEn,
      type: TransactionType.tripDeduction,
    );

    final newState = currentState.copyWith(
      balance: currentState.balance - amount,
      transactions: [newTransaction, ...currentState.transactions],
    );
    notifier.value = newState;
    WalletPersistence.save(newState); // حفظ تلقائي
  }

  static void linkCard(BuildContext context, String cardId) {
    final notifier = notifierOf(context);
    final newState = notifier.value.copyWith(linkedCardId: cardId);
    notifier.value = newState;
    WalletPersistence.save(newState); // حفظ تلقائي
  }
}
