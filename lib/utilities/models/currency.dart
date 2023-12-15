class Currency {
  final String code;
  final String symbol;
  final double rate;

  Currency({
    required this.code,
    required this.symbol,
    required this.rate
  });

  factory Currency.fromJson(Map<String, dynamic> data) {
    return Currency(
      code: data["code"],
      symbol: data["symbol"],
      rate: data["rate"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "code": code,
      "symbol": symbol,
      "rate": rate
    };
  }
}