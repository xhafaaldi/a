import 'package:isave/utilities/models/enums/recurring_type.dart';

class Budget {
  final String id;
  final DateTime creationDate;
  final DateTime untilDate;
  final String name;
  final double amount;
  final double totalSpent;
  final bool recurring;
  final RecurringType recurringType;

  Budget({
    required this.id,
    required this.creationDate,
    required this.untilDate,
    required this.name,
    required this.amount,
    required this.totalSpent,
    required this.recurring,
    required this.recurringType
  });

  factory Budget.fromJson(Map<String, dynamic> data) {
    return Budget(
      id: data["id"],
      creationDate: DateTime.fromMillisecondsSinceEpoch(data["creationDate"]),
      untilDate: DateTime.fromMillisecondsSinceEpoch(data["untilDate"]),
      name: data["name"],
      amount: data["amount"],
      totalSpent: data["totalSpent"],
      recurring: data["recurring"],
      recurringType: RecurringType.values.byName(data["recurringType"])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "creationDate": creationDate.millisecondsSinceEpoch,
      "untilDate": untilDate.millisecondsSinceEpoch,
      "name": name,
      "amount": amount,
      "totalSpent": totalSpent,
      "recurring": recurring,
      "recurringType": recurringType.name
    };
  }
}