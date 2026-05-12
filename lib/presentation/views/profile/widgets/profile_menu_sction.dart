import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/delivery_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/provider/printer_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/edit_profil.dart';
import 'package:testgetdata/presentation/views/pembeli/list_promo_page.dart';
import 'package:testgetdata/presentation/views/pembeli/login_page.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant/menu_tenant.dart';
import 'package:testgetdata/presentation/views/penjual/edit_profile_tenant.dart';
import 'package:testgetdata/presentation/views/penjual/edit_rekening.dart';
import 'package:testgetdata/presentation/views/penjual/form_operational.dart';
import 'package:testgetdata/presentation/views/penjual/katalog_menu_page.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_bluetooth_devices.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_review.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/profile_menu_item.dart';
import 'package:testgetdata/utils/has_internet_access.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileMenuSection extends StatefulWidget {
  final UserModel user;
  final AuthProvider authProvider;

  const ProfileMenuSection({
    Key? key,
    required this.user,
    required this.authProvider,
  }) : super(key: key);

  @override
  State<ProfileMenuSection> createState() => _ProfileMenuSectionState();
}

class _ProfileMenuSectionState extends State<ProfileMenuSection>
    with WidgetsBindingObserver {
  bool isOnline = false;
  StreamSubscription<List<Printer>>? _devicesStreamSubscription;
  StreamSubscription<bool>? _bluetoothConnection;
  bool isBleTurnedOn = false;
  bool isLoadingBluetooth = false;
  final FlutterThermalPrinter printer = FlutterThermalPrinter.instance;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    isOnline = widget.user.isOnline ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final printer = Provider.of<PrinterProvider>(context, listen: false);
      if (widget.user.role.contains("tenant")) {
        startScan(printer);
      }
    });
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        widget.user.role.contains("tenant")) {
      startScan(Provider.of<PrinterProvider>(context, listen: false));
    }
  }

  void startScan(PrinterProvider printerProvider) async {
    setState(() {
      isLoadingBluetooth = true;
    });

    _devicesStreamSubscription?.cancel();
    _bluetoothConnection?.cancel();
    printer.stopScan();

    print('Mulai scan printer BLE...');

    // === Request Permission ===
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.locationWhenInUse.request().isGranted) {
      // Dengarkan status BLE (nyala/mati)
      _bluetoothConnection = printer.isBleTurnedOnStream.listen((event) async {
        print("isBleTurnedOnStream: $event");

        if (!mounted) return;
        setState(() {
          isBleTurnedOn = event;
        });

        if (event == true) {
          // ✅ Kalau Bluetooth udah nyala, baru mulai scan
          try {
            await printer.getPrinters(connectionTypes: [ConnectionType.BLE]);

            _devicesStreamSubscription =
                printer.devicesStream.listen((List<Printer> event) {
              print("Ditemukan ${event.length} perangkat:");
              for (var d in event) {
                print("- ${d.name} (${d.address})");
              }
              printerProvider.setPrinters(event);
            });
          } catch (e) {
            Fluttertoast.showToast(msg: e.toString());
          } finally {
            if (mounted) {
              setState(() {
                isLoadingBluetooth = false;
              });
            }
          }
        } else {
          // 🚫 Bluetooth belum nyala
          if (mounted) {
            Fluttertoast.showToast(
              msg: "Bluetooth belum aktif, mohon nyalakan dulu...",
            );
            // printer.turnOnBluetooth();
          }
          setState(() {
            isLoadingBluetooth = false;
          });

          // Opsional: buka dialog atau auto aktifkan
        }
      });
    } else {
      debugPrint('Bluetooth permission not granted');
      setState(() {
        isLoadingBluetooth = false;
      });
    }
  }

  @override
  void dispose() {
    _devicesStreamSubscription?.cancel();
    printer.stopScan();
    _bluetoothConnection?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void showBatteryOptimizationDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Izinkan Aplikasi Berjalan di Latar Belakang'),
            content: const Text(
              '1. Setelah halaman pengaturan aplikasi FoodLab terbuka, cari dan pilih menu "Baterai" atau "Optimasi Baterai".\n'
              '2. Pastikan opsi "Izinkan aktivitas latar belakang" atau "Jangan optimalkan" sudah diaktifkan untuk FoodLab.\n'
              '3. Jika tidak menemukan menu tersebut, cari di bagian "Baterai" pada pengaturan utama ponsel Anda.\n\n'
              'Langkah ini akan memastikan FoodLab tetap berjalan di latar belakang dan notifikasi dapat diterima secara real-time.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // AppSettings.openAppSettingsPanel(AppSettingsPanelType.volume);

                  // AppSettings.openAppSettings(
                  //     type: AppSettingsType.batteryOptimization);
                  AppSettings.openAppSettings(type: AppSettingsType.settings);
                },
                child: const Text('Buka Pengaturan'),
              ),
            ],
          );
        },
      );
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        spacing: 13,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // profil penjual
          if (widget.user.permission.contains('read katalog')) ...[
            ProfileMenuItem(
              showIconArrow: false,
              status: isOnline,
              icon: Iconsax.lamp_on,
              iconColor: isOnline ? Colors.green : Colors.red,
              onChangeToggle: (selectedStatus) async {
                final success = await widget.authProvider.updateTenantStatus(
                  widget.user.token,
                  selectedStatus,
                );
                if (success.success) {
                  isOnline
                      ? Fluttertoast.showToast(msg: 'Tenant Tutup')
                      : Fluttertoast.showToast(msg: 'Tenant Buka');
                  setState(() {
                    isOnline = selectedStatus;
                  });
                } else {
                  Fluttertoast.showToast(
                      msg: "${success.error}",
                      backgroundColor: AppColors.errorColor,
                      textColor: Colors.white);
                }
              },
              title: 'Tenant Buka',
              onTap: () {},
            ),
            Text(
              'Informasi Tenant',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: semibold,
                color: AppColors.blackColor,
              ),
            ),
            ProfileMenuItem(
              icon: Iconsax.shop,
              title: 'Profil Tenant',
              titleColor: AppColors.blackColor,
              onTap: () async {
                final internetConnection = await hasInternetAccess();
                if (!internetConnection) {
                  Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
                  return;
                }
                Navigator.of(context).push(
                  CustomPageBuilder(page: EditProfileTenant()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Iconsax.menu_board,
              title: 'Katalog Menu',
              titleColor: AppColors.blackColor,
              onTap: () async {
                final internetConnection = await hasInternetAccess();
                if (!internetConnection) {
                  Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
                  return;
                }
                Navigator.of(context).push(
                  CustomPageBuilder(page: KatalogMenu()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Iconsax.clock,
              title: 'Jam Operasional',
              titleColor: AppColors.blackColor,
              onTap: () async {
                final internetConnection = await hasInternetAccess();
                if (!internetConnection) {
                  Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
                  return;
                }
                Navigator.of(context).push(
                  CustomPageBuilder(page: FormOperational()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Iconsax.cards,
              title: 'Rekening Pencairan',
              titleColor: AppColors.blackColor,
              onTap: () async {
                final internetConnection = await hasInternetAccess();
                if (!internetConnection) {
                  Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
                  return;
                }
                Navigator.of(context).push(
                  CustomPageBuilder(page: EditRekening()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Iconsax.printer,
              title: 'Mesin Cetak',
              titleColor: AppColors.blackColor,
              onTap: () async {
                if (isLoadingBluetooth) {
                  Fluttertoast.showToast(
                      msg: "Memindai Perangkat Bluetooth...");
                  return;
                }
                if (!isBleTurnedOn) {
                  Fluttertoast.showToast(msg: "Bluetooth belum diaktifkan");

                  await printer.turnOnBluetooth();
                  return;
                }
                showBottomSheetBluetoothDevices(context);
              },
            ),
            ProfileMenuItem(
              icon: Iconsax.shop,
              title: 'Self Service',
              titleColor: AppColors.blackColor,
              onTap: () async {
                final kasirProvider =
                    Provider.of<KasirProvider>(context, listen: false);
                if (kasirProvider.tenant == null) {
                  Fluttertoast.showToast(
                      msg:
                          "Data tenant belum termuat, silahkan klik beranda terlebih dahulu");
                  return;
                }
                Navigator.push(
                    context,
                    CustomPageBuilder(
                        page: MenuTenant(
                            requiredExitCode: true,
                            url:
                                '${MasbroConstants.url}/tenants/${kasirProvider.tenant!.id.toString()}')));
              },
            )
          ],
          //profil driver
          if (widget.user.permission.contains('read driver status')) ...[
            Text(
              'Driver',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: semibold,
                color: AppColors.primaryColor,
              ),
            ),
            ProfileMenuItem(
              showIconArrow: false,
              status: isOnline,
              icon: Iconsax.lamp_on,
              onChangeToggle: (selectedStatus) async {
                final success = await widget.authProvider.updateTenantStatus(
                  widget.user.token,
                  selectedStatus,
                );
                if (success.success) {
                  isOnline
                      ? Fluttertoast.showToast(msg: 'Nonaktif')
                      : Fluttertoast.showToast(msg: 'Aktif');
                  setState(() {
                    isOnline = selectedStatus;
                  });
                } else {
                  Fluttertoast.showToast(
                      msg: "${success.error}",
                      backgroundColor: AppColors.errorColor,
                      textColor: Colors.white);
                }
              },
              title: 'Status Driver',
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],

          // profil semua user
          Text(
            'Lainnya',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: semibold,
              color: AppColors.primaryColor,
            ),
          ),

          // ProfileMenuItem(
          //   icon: Icons.app_settings_alt_outlined,
          //   title: 'Atur Izin Latar Belakang',
          //   onTap: () => showBatteryOptimizationDialog(context),
          // ),
          ProfileMenuItem(
            icon: Iconsax.call,
            title: 'Lapor Admin',
            showIconArrow: false,
            onTap: () async {
              final noKonfirmasi = widget.authProvider.settings
                  .firstWhere((setting) => setting.nama == 'nomor_konfirmasi')
                  .nilai;
              final whatsappUrl = Uri.parse('https://wa.me/${noKonfirmasi}');
              final playStoreUrl = Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.whatsapp');

              if (await canLaunchUrl(whatsappUrl)) {
                await launchUrl(whatsappUrl,
                    mode: LaunchMode.externalApplication);
              } else if (!await launchUrl(playStoreUrl,
                  mode: LaunchMode.externalApplication)) {
                throw 'Could not launch $playStoreUrl';
              }
            },
          ),
          ProfileMenuItem(
            icon: Iconsax.like_1,
            title: 'Review Aplikasi',
            showIconArrow: false,
            onTap: () async {
              showBottomSheetReview(
                user: widget.user,
                context: context,
              );
            },
          ),
          ProfileMenuItem(
            icon: Iconsax.discount_shape,
            title: 'List Voucher',
            showIconArrow: false,
            onTap: () async {
              Navigator.push(
                  context,
                  CustomPageBuilder(
                      page: ListPromoPage(
                    fromProfile: true,
                  )));
            },
          ),
          ProfileMenuItem(
            icon: Iconsax.logout_1,
            title: 'Keluar',
            showIconArrow: false,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Konfirmasi Keluar',
        message: 'Apakah Anda yakin ingin keluar?',
        showCancelButton: true,
        onOkPressed: () async {
          final internetConnection = await hasInternetAccess();
          if (!internetConnection) {
            Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
            return;
          }
          cartProvider.clearCart(false);
          await widget.authProvider.logout(widget.user.token);
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              CustomPageBuilder(
                page: LoginPage(),
              ),
              (route) => false,
            );
          }
        },
        onCancelPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showStatusBottomSheet(BuildContext context, bool isTenant) {
    bool? selectedStatus = widget.user.isOnline;

    showModalBottomSheet(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(isTenant: isTenant),
                const SizedBox(height: 15),
                _buildStatusOption(
                  isTenant: isTenant,
                  isOnline: true,
                  selectedStatus: selectedStatus,
                  onTap: () => setModalState(() => selectedStatus = true),
                ),
                const SizedBox(height: 10),
                _buildStatusOption(
                  isTenant: isTenant,
                  isOnline: false,
                  selectedStatus: selectedStatus,
                  onTap: () => setModalState(() => selectedStatus = false),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedStatus != null
                        ? () async {
                            await widget.authProvider.updateTenantStatus(
                                widget.user.token, selectedStatus!);
                            if (context.mounted) Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedStatus != null
                          ? AppColors.primaryColor
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader({required bool isTenant}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isTenant ? 'Ubah Status Tenant' : 'Ubah Status Driver',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.textColorBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              width: 0.5,
              color: widget.user.isOnline! ? Colors.green : Colors.red,
            ),
          ),
          child: Text(
            widget.user.isOnline!
                ? isTenant
                    ? 'Buka'
                    : 'Online'
                : isTenant
                    ? 'Tutup'
                    : 'Offline',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: regular,
              color: widget.user.isOnline! ? Colors.green : Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOption({
    required bool isOnline,
    required bool? selectedStatus,
    required VoidCallback onTap,
    required bool isTenant,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: selectedStatus == isOnline
              ? AppColors.primaryColor.withOpacity(0.1)
              : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selectedStatus == isOnline
                ? AppColors.primaryColor
                : Colors.grey,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textColorBlack,
                    fontWeight: semibold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isOnline
                      ? isTenant
                          ? 'Pengguna bisa langsung memesan'
                          : 'Bisa antar pesanan'
                      : isTenant
                          ? 'Pengguna belum bisa memesan dari tokomu'
                          : 'Belum bisa antar pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textColorBlack,
                  ),
                ),
              ],
            ),
            Icon(
              selectedStatus == isOnline
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selectedStatus == isOnline
                  ? AppColors.primaryColor
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
