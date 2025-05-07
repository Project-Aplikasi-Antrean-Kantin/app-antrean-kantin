import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/views/pembeli/edit_profil.dart';
import 'package:testgetdata/presentation/views/penjual/edit_profile_tenant.dart';
import 'package:testgetdata/presentation/views/penjual/katalog_menu_page.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/profile_menu_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(context, user),
            _buildMenuSection(context, user, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20),
      decoration: BoxDecoration(color: AppColors.primaryColor),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              'Akun Saya',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: AppColors.textColorwhite,
                fontWeight: semibold,
              ),
            ),
          ),
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(80),
              color: Colors.grey[200],
            ),
            child: user.gambar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: Image.network(
                      user.gambar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey[600],
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // Gambar selesai dimuat
                        }
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[400]!,
                          highlightColor: Colors.grey[200]!,
                          child: Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(80),
                              color: Colors.grey[300],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey[600],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              children: [
                Text(
                  _capitalizeFirstLetter(user.nama),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: medium,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user.email,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
      BuildContext context, UserModel user, AuthProvider authProvider) {
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
              onTap: () => _showTenantStatusBottomSheet(context, authProvider),
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
              if (result == true && mounted) {
                await authProvider.fetchUserData(user.token);
              }
            },
          ),
          ProfileMenuItem(
            icon: Icons.logout,
            title: 'Keluar',
            showIconArrow: false,
            onTap: () => _showLogoutDialog(context, authProvider, user.token),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(
      BuildContext context, AuthProvider authProvider, String token) async {
    showDialog(
      context: context,
      builder: (context) => CustomAlertDialog(
        title: 'Konfirmasi Keluar',
        message: 'Apakah Anda yakin ingin keluar?',
        showCancelButton: true,
        onOkPressed: () async {
          await authProvider.logout(token);
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
        onCancelPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showTenantStatusBottomSheet(
      BuildContext context, AuthProvider authProvider) {
    bool? selectedStatus = authProvider.user.isOnline;

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
              _buildTenantStatusHeader(authProvider),
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
                              authProvider.user.token, selectedStatus!);
                          if (mounted) Navigator.pop(context);
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

  Widget _buildTenantStatusHeader(AuthProvider authProvider) {
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
              color: authProvider.user.isOnline! ? Colors.green : Colors.red,
            ),
          ),
          child: Text(
            authProvider.user.isOnline! ? 'Buka' : 'Tutup',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: regular,
              color: authProvider.user.isOnline! ? Colors.green : Colors.red,
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

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
