enum OrderStatus {
  pesananMasuk('pesanan_masuk', 'Masuk'),
  pesananDiproses('pesanan_diproses', 'Diproses');
  // pesananMenunggu('pesanan_menunggu', 'Menunggu');

  final String value;
  final String label;

  const OrderStatus(this.value, this.label);
}
