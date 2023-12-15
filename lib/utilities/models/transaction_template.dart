import 'package:isave/utilities/models/enums/transaction_type.dart';
import 'package:isave/utilities/models/memo.dart';
import 'package:isave/utilities/models/wallet.dart';

class TransactionTemplate {
  final String id;
  final String name;
  final double amount;
  final TransactionType transactionType;
  final String title;
  final String category;
  final Wallet wallet;
  final Memo memo;

  TransactionTemplate({
    required this.id,
    required this.name,
    required this.amount,
    required this.transactionType,
    required this.title,
    required this.category,
    required this.wallet,
    required this.memo
  });

  factory TransactionTemplate.fromJson(Map<String, dynamic> data) {
    return TransactionTemplate(
      id: data["id"],
      name: data["name"],
      amount: data["amount"],
      transactionType: TransactionType.values.byName(data["transactionType"]),
      title: data["description"],
      category: data["category"],
      wallet: Wallet.fromJson(data["wallet"]),
      memo: Memo.fromJson(data["memo"])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "amount": amount,
      "transactionType": transactionType.name,
      "description": title,
      "category": category,
      "wallet": wallet.toJson(),
      "memo": memo.toJson()
    };
  }
}