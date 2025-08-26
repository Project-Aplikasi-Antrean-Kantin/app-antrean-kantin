enum OrderStatus {
  pesananMasuk(['pesanan_masuk'], 'Masuk'),
  pesananDiproses(['pesanan_diproses'], 'Diproses'),
  pesananSiapDiambil(
      ['siap_diantar', 'diantar', 'siap_diambil'], 'Pengambilan');

  final List<String> rawValues;
  final String label;

  const OrderStatus(this.rawValues, this.label);
}
