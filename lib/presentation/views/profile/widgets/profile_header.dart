import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/edit_profil.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: true).user;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              'Akun Saya',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: Colors.grey[200],
                ),
                child: user.gambar != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: ImageByUrl(
                          key: ValueKey(user.gambar),
                          url: user.gambar!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.grey[600],
                        ),
                      ),
              ),

              const SizedBox(width: 10),

              // Flexible biar teks bisa wrap sesuai sisa space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nama,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600,
                        ),
                        softWrap: true, // penting biar bisa turun ke baris baru
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.blackColor400,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: () async {
                  final internetConnection = await hasInternetAccess();
                  if (!internetConnection) {
                    Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
                    return;
                  }
                  Navigator.push(
                      context, CustomPageBuilder(page: EditProfil()));
                },
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit02,
                    size: 32,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension CapitalizeExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
