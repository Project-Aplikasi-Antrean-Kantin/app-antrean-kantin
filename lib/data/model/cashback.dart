class Cashback {
  final int id;
  final double value;
  final int qty;
  final bool isValid;
  final String referralCode;
  final int minimalOrder;
  final int maxCashback;
  final int maxUsed;
  final DateTime endDate;
  final DateTime startDate;

  Cashback(
      {required this.id,
      required this.value,
      required this.qty,
      required this.isValid,
      required this.referralCode,
      required this.minimalOrder,
      required this.maxCashback,
      required this.maxUsed,
      required this.endDate,
      required this.startDate});

  factory Cashback.fromJson(Map<String, dynamic> json) {
    return Cashback(
      id: json['id'],
      value: json['value'],
      qty: json['quantity'],
      isValid: json['is_valid'],
      referralCode: json['referral_code'],
      minimalOrder: json['minimal_beli'],
      maxCashback: json['max_cashback'],
      maxUsed: json['max_used'],
      endDate: DateTime.parse(json['end_date']),
      startDate: DateTime.parse(json['start_date']),
    );
  }

  String toString() =>
      'Cashback(id: $id, value: $value, qty: $qty, isValid: $isValid, referralCode: $referralCode, minimalOrder: $minimalOrder, maxCashback: $maxCashback, maxUsed: $maxUsed)';
}
