import 'package:flutter/material.dart';
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

    notifier.value = currentState.copyWith(
      balance: currentState.balance + amount,
      transactions: [newTransaction, ...currentState.transactions],
    );
  }

  static void deduct(BuildContext context, double amount, String titleAr, String titleEn) {
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

    notifier.value = currentState.copyWith(
      balance: currentState.balance - amount,
      transactions: [newTransaction, ...currentState.transactions],
    );
  }

  static void linkCard(BuildContext context, String cardId) {
    final notifier = notifierOf(context);
    notifier.value = notifier.value.copyWith(linkedCardId: cardId);
  }
}
