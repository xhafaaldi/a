class Goal {
  final String id;
  final DateTime creationDate;
  final DateTime targetDate;
  final String name;
  final double amount;

  Goal({
    required this.id,
    required this.creationDate,
    required this.targetDate,
    required this.name,
    required this.amount
  });

  factory Goal.fromJson(Map<String, dynamic> data) {
    return Goal(
      id: data["id"],
      creationDate: DateTime.fromMillisecondsSinceEpoch(data["creationDate"]),
      targetDate: DateTime.fromMillisecondsSinceEpoch(data["targetDate"]),
      name: data["name"],
      amount: data["amount"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "creationDate": creationDate.millisecondsSinceEpoch,
      "targetDate": targetDate.millisecondsSinceEpoch,
      "name": name,
      "amount": amount
    };
  }
}