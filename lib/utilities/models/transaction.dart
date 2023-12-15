import 'package:isave/utilities/models/enums/transaction_type.dart';
import 'package:isave/utilities/models/memo.dart';
import 'package:isave/utilities/models/wallet.dart';
import 'package:isave/utilities/models/currency.dart';

class Transaction {
  final String id;
  final DateTime date;
  final TransactionType type;
  final double amount;
  final Currency currency;
  final String title;
  final String category;
  final Wallet wallet;
  final Memo memo;
  final Wallet? toWallet;
  final Wallet? fromWallet;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.title,
    required this.type,
    required this.currency,
    required this.category,
    required this.wallet,
    required this.memo,
    this.toWallet,
    this.fromWallet
  });

  factory Transaction.fromJson(Map<String, dynamic> data) {
    return Transaction(
      id: data["id"].toString(),
      date: DateTime.fromMillisecondsSinceEpoch(data["date"]),
      amount: data["amount"],
      type: TransactionType.values.byName(data["type"]),
      title: data["title"],
      memo: Memo.fromJson(data["memo"]),
      category: data["category"],
      currency: Currency.fromJson(data["currency"]),
      wallet: Wallet.fromJson(data["wallet"]),
      toWallet: data["toWallet"] != null ? Wallet.fromJson(data["toWallet"]) : null,
      fromWallet: data["fromWallet"] != null ? Wallet.fromJson(data["fromWallet"]) : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id.toString(),
      "date": date.millisecondsSinceEpoch,
      "type": type.name,
      "amount": amount,
      "currency": currency.toJson(),
      "title": title,
      "category": category,
      "wallet": wallet.toJson(),
      "memo": memo.toJson(),
      "toWallet": toWallet?.toJson(),
      "fromWallet": fromWallet?.toJson()
    };
  }
}