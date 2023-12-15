import 'package:flutter/material.dart';

import 'package:isave/utilities/models/currency.dart';
import 'package:isave/utilities/models/enums/credit_card_type.dart';
import 'package:isave/utilities/models/enums/wallet_type.dart';

import 'package:get/get.dart';

class Wallet {
  final String id;
  final String name;
  final WalletType type;
  final double amount;
  final Color color;
  final Currency currency;
  final CreditCardType? creditCardType;

  Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.color,
    required this.currency,
    this.creditCardType
  });

  factory Wallet.fromJson(Map<String, dynamic> data) {
    return Wallet(
      id: data["id"].toString(),
      name: data["name"],
      type: WalletType.values.byName(data["type"].toString().camelCase!.removeAllWhitespace),
      amount: data["amount"],
      color: Color(data["color"]),
      currency: Currency.fromJson(data["currency"]),
      creditCardType: CreditCardType.values.firstWhere(
        (c) => data["creditCardType"] != null
          ? (c.value == data["creditCardType"])
          : false,
        orElse: () => CreditCardType.other
      )
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id.toString(),
      "name": name.toString(),
      "type": type.value,
      "amount": amount,
      "color": color.value,
      "currency": currency.toJson(),
      "creditCardType": creditCardType?.value
    };
  }
}