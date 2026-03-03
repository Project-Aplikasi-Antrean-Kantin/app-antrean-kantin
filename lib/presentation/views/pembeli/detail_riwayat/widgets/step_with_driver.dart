import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/step_model.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/step_progress.dart';

class StepWithDriver extends StatelessWidget {
  final Pesanan pesanan;
  const StepWithDriver({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    final bool isAntar = pesanan.isAntar == 1;
    final bool isRefund = pesanan.status == 'refund_selesai';

    final List<StepModel> steps = [
      // 1️⃣ Masuk (selalu ada)
      StepModel(
        padding: const EdgeInsets.only(left: 0),
        textAlign: TextAlign.start,
        title: 'Masuk',
        icon: HugeIcons.strokeRoundedNoteDone,
      ),

      // 2️⃣ Diproses / Ditolak
      StepModel(
        padding: isAntar ? null : const EdgeInsets.only(left: 12),
        textAlign: TextAlign.start,
        title: isRefund ? 'Ditolak' : 'Diproses',
        icon: isRefund
            ? HugeIcons.strokeRoundedCancel02
            : HugeIcons.strokeRoundedPan03,
      ),

      // 3️⃣ Siap Diantar / Siap Diambil
      StepModel(
        padding: isAntar ? null : const EdgeInsets.only(left: 8),
        textAlign: TextAlign.center,
        title: isAntar ? 'Siap Diantar' : 'Siap Diambil',
        icon: HugeIcons.strokeRoundedMilkCarton,
      ),

      // 4️⃣ Diantar (khusus antar & bukan refund)
      if (isAntar)
        StepModel(
          padding: const EdgeInsets.only(left: 12),
          textAlign: TextAlign.center,
          title: 'Diantar',
          icon: HugeIcons.strokeRoundedUserRoadside,
        ),

      // 5️⃣ Selesai (selalu ada)
      StepModel(
        textAlign: TextAlign.end,
        title: 'Selesai',
        icon: HugeIcons.strokeRoundedCheckmarkBadge02,
      ),
    ];
    return Column(
      spacing: 16,
      children: [
        StepProgress(
          isRefund: pesanan.status == 'refund_selesai',
          currentStep: getCurrentStep(
            pesanan.status,
            pesanan.isAntar,
          ),
          steps: steps,
        ),
        if (pesanan.isAntar == 1 &&
            (pesanan.status == 'diantar' || pesanan.status == 'selesai'))
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 8,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: pesanan.fotoDriver != null
                        ? ImageByUrl(
                            url: pesanan.fotoDriver ?? '',
                            height: 48,
                            width: 48,
                          )
                        : Center(
                            child: Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),
                  Text(
                    pesanan.namaDriver!,
                    style: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                "Driver",
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
      ],
    );
  }

  int getCurrentStep(String status, int isAntar) {
    if (isAntar == 1) {
      switch (status) {
        case 'pesanan_masuk':
          return 1;
        case 'pesanan_diproses':
          return 2;
        case 'siap_diantar':
          return 3;
        case 'diantar':
          return 4;
        case 'selesai':
          return 5;
        case 'refund_selesai':
          return 2;
        case 'pesanan_ditolak':
          return 2;
        default:
          return 1;
      }
    } else {
      switch (status) {
        case 'pesanan_masuk':
          return 1;
        case 'pesanan_diproses':
          return 2;
        case 'siap_diambil':
          return 3;
        case 'selesai':
          return 4;
        case 'refund_selesai' || 'pesanan_ditolak':
          return 2;
        default:
          return 1;
      }
    }
  }
}
