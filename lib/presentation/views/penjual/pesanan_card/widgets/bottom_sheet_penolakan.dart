import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class BottomSheetPenolakan extends StatefulWidget {
  final Pesanan pesanan;
  const BottomSheetPenolakan({super.key, required this.pesanan});

  @override
  State<BottomSheetPenolakan> createState() => _BottomSheetPenolakanState();
}

class _BottomSheetPenolakanState extends State<BottomSheetPenolakan> {
  final textEditingController = TextEditingController();
  final kodePenolakanController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    textEditingController.dispose();
    kodePenolakanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.read<OrderProvider>();
    final pesanan = widget.pesanan;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 18,
            left: 18,
            right: 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// drag indicator
              Container(
                height: 5,
                margin: const EdgeInsets.only(
                  bottom: 20,
                  left: 150,
                  right: 150,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Center(
                child: Text(
                  'Tolak Pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.errorColor,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (pesanan.isPriority == 1)
                TextFormField(
                  controller: kodePenolakanController,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    hintText: 'Kode Penolakan (tanyakan driver)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                ),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.blackColor100,
                    width: 2,
                  ),
                ),
                height: 124,
                child: TextField(
                  controller: textEditingController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan catatan...',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              PrimaryButton(
                isLoading: _isLoading,
                borderRadius: 16,
                height: 48,
                color: AppColors.errorColor,
                child: Text(
                  'Kirim',
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteColor100,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                onPressed: () async {
                  if (textEditingController.text.isEmpty) {
                    CustomSnackbar.warning('Catatan tidak boleh kosong');
                    return;
                  }

                  if (pesanan.isPriority == 1 &&
                      kodePenolakanController.text.isEmpty) {
                    CustomSnackbar.warning('Kode penolakan tidak boleh kosong');
                    return;
                  }

                  if (kodePenolakanController.text != pesanan.kodePenolakan &&
                      pesanan.isPriority == 1) {
                    CustomSnackbar.warning('Kode penolakan salah');
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                  });

                  final success = await orderProvider.cancelOrder(
                    "token",
                    pesanan.id,
                    pesanan,
                    textEditingController.text,
                  );

                  if (success) {
                    Navigator.pop(context);
                    CustomSnackbar.success('Pesanan berhasil ditolak');
                  } else {
                    CustomSnackbar.error('Pesanan gagal ditolak');
                  }

                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future bottomSheetPenolakan(BuildContext context, Pesanan pesanan) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(15),
      ),
    ),
    builder: (context) {
      return BottomSheetPenolakan(pesanan: pesanan);
    },
  );
}
