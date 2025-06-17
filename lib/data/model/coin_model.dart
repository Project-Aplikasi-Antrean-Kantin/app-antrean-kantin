class CoinModel {
  final bool? success;
  final int saldoKoin;

  CoinModel({
    this.success,
    required this.saldoKoin,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) => CoinModel(
        success: json["success"],
        saldoKoin: json["saldo_koin"],
      );
}
