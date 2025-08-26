class TopUpModel {
  final String kodeBayar;
  final String nominal;
  final String? biayaAdmin;
  final DateTime akhirBayar;
  final String status;
  final String? midtransId;

  TopUpModel({
    this.midtransId,
    this.biayaAdmin,
    required this.status,
    required this.kodeBayar,
    required this.nominal,
    required this.akhirBayar,
  });

  factory TopUpModel.fromJson(Map<String, dynamic> json) {
    return TopUpModel(
      status: json['status_bayar'] ?? '0',
      kodeBayar: json['kode_bayar'],
      nominal: json['nominal'],
      akhirBayar: DateTime.parse(json['tgl_akhir_tagihan']),
    );
  }

  factory TopUpModel.fromJsonQris(Map<String, dynamic> json) {
    final status = json['status_bayar'] == 'settlement' ? '1' : '0';
    print('json $json');

    return TopUpModel(
      midtransId: json['midtrans_request_id'].toString(),
      biayaAdmin: json['total_biaya_admin'].toString(),
      status: status,
      kodeBayar: json['kode_bayar'].toString(),
      nominal: json['nominal'].toString(),
      akhirBayar: DateTime.parse(
        json['tgl_akhir_tagihan'].replaceFirst(' ', 'T'),
      ),
    );
  }
  Map<String, dynamic> toJson() => {
        'kode_bayar': kodeBayar,
        'nominal': nominal,
        'total_biaya_admin': biayaAdmin ?? '',
        'midtrans_request_id': midtransId ?? '',
        'tgl_akhir_tagihan': akhirBayar.toIso8601String(),
        'status': status
      };

  @override
  String toString() {
    return 'TopUpModel{status: $status, kodeBayar: $kodeBayar, nominal: $nominal, akhirBayar: $akhirBayar midtrans:$midtransId} , biayaAdmin: $biayaAdmin';
  }
}
