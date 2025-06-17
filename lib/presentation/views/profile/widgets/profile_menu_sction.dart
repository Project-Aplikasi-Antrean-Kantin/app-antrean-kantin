import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/edit_profil.dart';
import 'package:testgetdata/presentation/views/pembeli/login_page.dart';
import 'package:testgetdata/presentation/views/penjual/edit_profile_tenant.dart';
import 'package:testgetdata/presentation/views/penjual/katalog_menu_page.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/profile_menu_item.dart';

class ProfileMenuSection extends StatelessWidget {
  final UserModel user;
  final AuthProvider authProvider;

  const ProfileMenuSection({
    Key? key,
    required this.user,
    required this.authProvider,
  }) : super(key: key);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // profil penjual
          if (user.permission.contains('read katalog')) ...[
            Text(
              'Penjual',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: semibold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            ProfileMenuItem(
              icon: Icons.storefront_outlined,
              title: 'Edit Profil Tenant',
              titleColor: AppColors.textColorBlack,
              onTap: () => Navigator.of(context).push(
                CustomPageBuilder(page: EditProfileTenant()),
              ),
            ),
            ProfileMenuItem(
              icon: Icons.library_books_outlined,
              title: 'Katalog Menu',
              titleColor: AppColors.textColorBlack,
              onTap: () => Navigator.of(context).push(
                CustomPageBuilder(page: KatalogMenu()),
              ),
            ),
            ProfileMenuItem(
              status: user.isOnline,
              icon: Icons.access_time_outlined,
              iconColor: user.isOnline! ? Colors.green : Colors.red,
              title: 'Status Tenant',
              onTap: () => _showTenantStatusBottomSheet(context),
            ),
            const SizedBox(height: 20),
          ],

          // profil semua user
          Text(
            'Pengaturan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: semibold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          ProfileMenuItem(
            icon: Icons.account_circle_outlined,
            title: 'Edit Profil',
            onTap: () async {
              final result = await Navigator.of(context).push(
                CustomPageBuilder(page: const EditProfil()),
              );
              if (result == true && context.mounted) {
                await authProvider.fetchUserData(user.token);
              }
            },
          ),
          // ProfileMenuItem(
          //   icon: Icons.app_settings_alt_outlined,
          //   title: 'Atur Izin Latar Belakang',
          //   onTap: () => showBatteryOptimizationDialog(context),
          // ),
          ProfileMenuItem(
            icon: Icons.logout,
            title: 'Keluar',
            showIconArrow: false,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Konfirmasi Keluar',
        message: 'Apakah Anda yakin ingin keluar?',
        showCancelButton: true,
        onOkPressed: () async {
          await authProvider.logout(user.token);
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

  void _showTenantStatusBottomSheet(BuildContext context) {
    bool? selectedStatus = user.isOnline;

    showModalBottomSheet(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTenantStatusHeader(),
              const SizedBox(height: 15),
              _buildStatusOption(
                isOnline: true,
                selectedStatus: selectedStatus,
                onTap: () => setModalState(() => selectedStatus = true),
              ),
              const SizedBox(height: 10),
              _buildStatusOption(
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
                          await authProvider.updateTenantStatus(
                              user.token, selectedStatus!);
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
    );
  }

  Widget _buildTenantStatusHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Ubah Status Tenant',
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
              color: user.isOnline! ? Colors.green : Colors.red,
            ),
          ),
          child: Text(
            user.isOnline! ? 'Buka' : 'Tutup',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: regular,
              color: user.isOnline! ? Colors.green : Colors.red,
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
                      ? 'Pengguna bisa langsung memesan'
                      : 'Pengguna belum bisa memesan dari tokomu',
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
