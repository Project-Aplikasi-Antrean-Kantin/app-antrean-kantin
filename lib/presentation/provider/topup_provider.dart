import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/settings_model.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';

class TopupProvider extends ChangeNotifier {
  List<SettingsModel> settings = [];

  String namaKonfirmasi = '';
  String namaDgs = '';
  String namaMandiri = '';
  String namaJago = '';
  String noKonfirmasi = '';
  String noDgs = '';
  String noMandiri = '';
  String noJago = '';

  Future<void> getDataTopUp(String token) async {
    try {
      // Ambil data dari PublicRemoteDataSource
      settings = await PublicRemoteDataSource().getOngkir(token);

      // Cari ongkos_kirim dan biaya_layanan dari settings
      for (var setting in settings) {
        if (setting.nama == 'nomor_konfirmasi') {
          // ongkir = setting.nilai;
          namaKonfirmasi = setting.nama;
          noKonfirmasi = setting.nilai;
          // noKonfirmasi = int.parse(setting.nilai);
        } else if (setting.nama == 'DANA/Gopay/Shopee') {
          namaDgs = setting.nama;
          noDgs = setting.nilai;
        } else if (setting.nama == 'Bank Mandiri') {
          namaMandiri = setting.nama;
          noMandiri = setting.nilai;
        } else if (setting.nama == 'Bank Jago') {
          namaJago = setting.nama;
          noJago = setting.nilai;
        }
        // Jika jumlahItem juga ada di settings, tambahkan logika serupa
        // else if (setting.nama == 'jumlah_item') {
        //   jumlahItem = setting.nilai;
        // }
      }

      // Beritahu UI bahwa data telah berubah
      notifyListeners();
    } catch (e) {
      // Tangani error, misalnya set nilai default
      noKonfirmasi = '';
      noDgs = '';
      notifyListeners();
      debugPrint('Error fetching settings: $e');
    }
  }
}
