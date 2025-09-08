import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/data/model/settings_model.dart';
import 'package:testgetdata/data/model/top_up_model.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';
import 'package:testgetdata/data/remote/topup_remote_data_source.dart';

class TopupProvider extends ChangeNotifier {
  List<SettingsModel> settings = [];
  String? errorMessage;
  List<String> paymentMethods = [];
  TopUpModel? topUp;
  String manualTransfer = '0';
  String namaKonfirmasi = '';
  String aktifQris = '0';
  String aktifVa = '0';
  String namaDgs = '';
  String namaMandiri = '';
  String namaJago = '';
  String noKonfirmasi = '';
  String noDgs = '';
  String noMandiri = '';
  String noJago = '';
  String namaPenerima = "";
  String _lastCopiedPaymentMethod = '';
  String get lastCopiedPaymentMethod => _lastCopiedPaymentMethod;

  Future<void> getDataTopUp(String token) async {
    try {
      paymentMethods.clear();
      settings = await PublicRemoteDataSource().getSettings();
      final settingTopUp =
          settings.firstWhere((setting) => setting.nama == 'bool_topup');
      final settingManualTransfer =
          settings.firstWhere((setting) => setting.nama == 'manual_transfer');
      print('settingTopUp: ${settingTopUp.nilai}');
      namaPenerima = "";
      noMandiri = "";

      for (var setting in settings) {
        print('setting nama: ${setting.nama} nilai: ${setting.nilai}');
        if (setting.nama == 'aktif_va') {
          aktifVa = setting.nilai;
          if (setting.nilai == '1') {
            if (!paymentMethods.contains('VA Mandiri')) {
              paymentMethods.insert(0, 'VA Mandiri');
            }
          }
        }
        if (setting.nama == 'aktif_qris') {
          aktifQris = setting.nilai;
          if (setting.nilai == '1') {
            if (!paymentMethods.contains('QRIS')) {
              paymentMethods.insert(0, 'QRIS');
            }
          }
        }
        if (settingTopUp.nilai == '1' && settingManualTransfer.nilai == '1') {
          if (setting.nama == 'nomor_konfirmasi') {
            namaKonfirmasi = setting.nama;
            noKonfirmasi = "6282188671510";
          } else if (setting.nama == 'GoPay/ShopeePay') {
            namaDgs = setting.nama;
            noDgs = setting.nilai;
            if (paymentMethods.contains(setting.nama) == false) {
              paymentMethods.add(setting.nama);
            }
          } else if (setting.nama == 'Bank Mandiri') {
            namaMandiri = setting.nama;
            noMandiri = "1480019676991";
            if (paymentMethods.contains(setting.nama) == false) {
              paymentMethods.add(setting.nama);
            }
          }
          if (setting.nama == 'nama_penerima') {
            namaPenerima = "Dukhaan Kamimpangan";
          }
        } else if (settingTopUp.nilai == '0' &&
            settingManualTransfer.nilai == '1') {
          if (setting.nama == 'nomor_konfirmasi') {
            namaKonfirmasi = setting.nama;
            noKonfirmasi = "6281218230764";
          } else if (setting.nama == 'DANA/Gopay/Shopee') {
            namaDgs = setting.nama;
            noDgs = setting.nilai;
            if (paymentMethods.contains(setting.nama) == false) {
              paymentMethods.add(setting.nama);
            }
          } else if (setting.nama == 'Bank Mandiri') {
            namaMandiri = setting.nama;
            noMandiri = "1400020906435";
            if (paymentMethods.contains(setting.nama) == false) {
              paymentMethods.add(setting.nama);
            }
          } else if (setting.nama == 'Bank Jago') {
            namaJago = setting.nama;
            noJago = setting.nilai;
            if (paymentMethods.contains(setting.nama) == false) {
              paymentMethods.add(setting.nama);
            }
          }
          if (setting.nama == 'nama_penerima') {
            namaPenerima = "Asy Syaffa Khoirunnisa";
          }
        }

        if (setting.nama == 'manual_transfer') {
          manualTransfer = setting.nilai;
        }
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

  Future<void> setTopUp() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonCurrentVa = prefs.getString('current_va');

    if (jsonCurrentVa != null) {
      final decoded = jsonDecode(jsonCurrentVa); // ini Map<String, dynamic>
      final kodeBayar = decoded['kode_bayar'] as String;
      if (kodeBayar.contains('https:')) {
        topUp = TopUpModel.fromJsonQris(decoded);
      } else {
        topUp = TopUpModel.fromJson(decoded);
      }
      print('topUp $topUp');
    }
    notifyListeners();
  }

  Future<bool> createVirtualAccount(String token, String nominal) async {
    try {
      final success = await TopupRemoteDataSource().addTopup(token, nominal);
      topUp = success;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> createQRIS(String token, String nominal) async {
    try {
      final success = await TopupRemoteDataSource().createQRIS(token, nominal);
      topUp = success;
      print('cek apakah success $topUp');
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> getVirtualAccount(String token, String kodeBayar) async {
    print('token $token, kodeBayar $kodeBayar');
    final prefs = await SharedPreferences.getInstance();
    try {
      final success = await TopupRemoteDataSource().getTopup(token, kodeBayar);
      if (success.status == "1") {
        if (prefs.containsKey('current_va')) {
          print("✅ current_va ditemukan, akan dihapus...");
          prefs.remove("current_va");
          print("✅ current_va berhasil dihapus.");
        } else {
          print("❌ current_va tidak ditemukan.");
        }
      }
      topUp = success;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> getTopUpQris(String token, String kodeMidtrans) async {
    print('token $token, kodeBayar $kodeMidtrans');
    final prefs = await SharedPreferences.getInstance();
    try {
      final success =
          await TopupRemoteDataSource().getTopUpQris(token, kodeMidtrans);
      if (success.status == "1") {
        if (prefs.containsKey('current_va')) {
          print("✅ current_va ditemukan, akan dihapus...");
          prefs.remove("current_va");
          print("✅ current_va berhasil dihapus.");
        } else {
          print("❌ current_va tidak ditemukan.");
        }
      }
      topUp = success;
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  void setLastCopiedPaymentMethod(String methodName) {
    _lastCopiedPaymentMethod = methodName;
    notifyListeners();
  }
}
