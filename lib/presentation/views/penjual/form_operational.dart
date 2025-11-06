import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/tenant_provider.dart';
import 'package:testgetdata/presentation/widgets/time_picker.dart';

class FormOperational extends StatefulWidget {
  const FormOperational({super.key});

  @override
  State<FormOperational> createState() => _FormOperationalState();
}

class _FormOperationalState extends State<FormOperational> {
  String selectedOpenTime = '00:00:00';
  String selectedCloseTime = '00:00:00';
  bool isLoading = true;

  void handleTimeChanged(String type, String newTime) {
    setState(() {
      if (type == "open") {
        selectedOpenTime = newTime;
      } else if (type == "close") {
        selectedCloseTime = newTime;
      }
    });
  }

  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tenantProvider = context.read<TenantProvider>();
      tenantProvider
          .fetchTenantData(context.read<AuthProvider>().user.token)
          .then((_) {
        final tenantData = tenantProvider.tenant;
        setState(() {
          selectedOpenTime = tenantData?.jamBuka ?? '00:00:00';
          selectedCloseTime = tenantData?.jamTutup ?? '00:00:00';
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final tenantProvider = Provider.of<TenantProvider>(context);
    return Scaffold(
      bottomNavigationBar: SafeArea(
          child: _buildBottomNavigationBar(tenantProvider, authProvider)),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowLeft02,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Jam Operasional',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const CircularProgressIndicator()
                else ...[
                  Row(
                    children: [
                      Text('Jam Buka',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          )),
                      Text(' *',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ))
                    ],
                  ),
                  TimePicker(
                    label: "Jam Tutup",
                    selectedTime: selectedOpenTime,
                    onTimeChanged: (newTime) =>
                        handleTimeChanged("open", newTime),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Jam Tutup',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          )),
                      Text(' *',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ))
                    ],
                  ),
                  TimePicker(
                    label: "Jam Tutup",
                    selectedTime: selectedCloseTime,
                    onTimeChanged: (newTime) =>
                        handleTimeChanged("close", newTime),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(
      TenantProvider tenantProvider, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // harus ada agar shadow muncul
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent, // tidak ada shadow
                  surfaceTintColor: Colors.transparent, // hilangkan efek tint
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: Color.fromARGB(255, 68, 68, 68),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                onPressed: () => _saveProfile(tenantProvider, authProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent, // tidak ada shadow
                  surfaceTintColor: Colors.transparent, // hilangkan efek tint
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile(TenantProvider tenantProvider, AuthProvider authProvider) {
    if (selectedCloseTime == '00:00:00' || selectedOpenTime == '00:00:00') {
      Fluttertoast.showToast(
          msg: "Tolong isi dengan benar",
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return;
    }

    setState(() => isLoading = true);

    final data = {
      'nama_tenant': tenantProvider.tenant?.namaTenant,
      'nama_kavling': tenantProvider.tenant?.namaKavling,
      'jam_buka': selectedOpenTime,
      'jam_tutup': selectedCloseTime,
    };

    TenantRemoteDataSource()
        .updateProfileTenant(authProvider.user.token, data)
        .then((success) {
      if (success) {
        Fluttertoast.showToast(
            msg: 'Profil berhasil diperbarui',
            backgroundColor: Colors.green,
            textColor: Colors.white);
        Navigator.of(context).pop();
      } else {
        Fluttertoast.showToast(
            msg: 'Profil gagal diperbarui',
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    }).whenComplete(() => setState(() => isLoading = false));
  }
}
