enum CreditCardType {
  mastercard("Mastercard"),
  visa("Visa"),
  amex("American Express"),
  other("Other");

  final String value;
  const CreditCardType(this.value);
}