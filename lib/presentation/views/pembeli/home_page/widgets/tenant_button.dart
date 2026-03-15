import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class TenantButton extends StatefulWidget {
  final TenantModel? yourTenant;
  final bool isScrolledEnough;
  final UserModel user;
  final bool isBusyNotInterruptYet;
  final Future<void> Function() onRefresh; // ✅ ubah ke function

  const TenantButton({
    required this.isBusyNotInterruptYet,
    required this.onRefresh,
    super.key,
    required this.yourTenant,
    required this.isScrolledEnough,
    required this.user,
  });

  @override
  State<TenantButton> createState() => _TenantButtonState();
}

class _TenantButtonState extends State<TenantButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey _targetKey = GlobalKey();
  bool isInterrupted = false;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isInterrupted = widget.isBusyNotInterruptYet;

    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.data['title']?.toString().toLowerCase();
      if (title != null && title.contains('tenant sibuk')) {
        setState(() {
          isInterrupted = true;
        });
      }
    });
  }

  void _showOverlay(BuildContext context) {
    final overlay = Overlay.of(context);

    // Cari posisi tombol di layar
    final renderBox =
        _targetKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final rect = offset & renderBox.size;

    _overlayEntry = _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // BACKDROP HITAM POLOS
          GestureDetector(
            onTap: _hidePopover,
            child: Container(
              color: AppColors.primaryColor100.withOpacity(0.5),
            ),
          ),

          // DUPLIKASI TOMBOL DI POSISI ASLINYA
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.center,
            followerAnchor: Alignment.center,
            child: GestureDetector(
              onTap: () => _hidePopover(),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: HugeIcon(
                    icon: Iconsax.lamp_on,
                    color: widget.yourTenant?.isOnline == true
                        ? widget.yourTenant?.busyUntil != null
                            ? AppColors.warningColor
                            : AppColors.successColor
                        : AppColors.errorColor,
                  ),
                ),
              ),
            ),
          ),

          // POPOVER
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 20),
            child: Material(
              borderRadius: BorderRadius.circular(20),
              color: Colors.transparent,
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                width: 240,
                padding: const EdgeInsets.all(16),
                child: Column(
                  spacing: 8,
                  mainAxisSize:
                      MainAxisSize.min, // ⬅️ penting, biar height ikut isi
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.yourTenant?.isOnline == true
                                ? widget.yourTenant?.busyUntil != null
                                    ? AppColors.warningColor
                                    : AppColors.successColor
                                : AppColors.errorColor,
                          ),
                          widget.user.isOnline == true
                              ? widget.yourTenant?.busyUntil != null
                                  ? "Tenant Sibuk"
                                  : "Tenant Buka"
                              : "Tenant Tutup",
                        ),
                        GestureDetector(
                          onTap: _hidePopover,
                          child: HugeIcon(
                              size: 24,
                              icon: Iconsax.lamp_on,
                              color: widget.yourTenant?.isOnline == true
                                  ? widget.yourTenant?.busyUntil != null
                                      ? AppColors.warningColor.withOpacity(0.5)
                                      : AppColors.successColor.withOpacity(0.5)
                                  : AppColors.errorColor.withOpacity(0.5)),
                        )
                      ],
                    ),
                    Flexible(
                        child: Text(widget.user.isOnline == true
                            ? widget.yourTenant!.busyUntil != null
                                ? 'Tenant sedang sibuk, tekan siap untuk mengubah statu menjadi buka kembali dalam 3 menit.'
                                : 'Tenant sedang buka, tenant siap menerima pesanan baru. '
                            : 'Tenant sedang tutup, tenant tidak dapat menerima  pesanan baru. ')),
                    if (widget.yourTenant?.busyUntil != null &&
                        widget.yourTenant?.isOnline == true &&
                        isInterrupted)
                      Align(
                        alignment: Alignment.centerRight,
                        child: PrimaryButton(
                            height: 32,
                            borderRadius: 16,
                            color: AppColors.warningColor,
                            child: Text("Siap",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                )),
                            width: 96,
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final statusTenant =
                                  await TenantRemoteDataSource()
                                      .updateBusy(widget.user.token);
                              if (statusTenant) {
                                prefs.remove("tenant_sibuk");

                                setState(() {});
                                Fluttertoast.showToast(
                                    msg:
                                        "Dalam 3 menit status tenantmu akan menjadi Buka",
                                    backgroundColor: AppColors.successColor,
                                    textColor: Colors.white);
                              }
                              setState(() {
                                isInterrupted = false;
                              });
                              widget.onRefresh();
                              _hidePopover();
                            }),
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hidePopover() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.user.role.contains('tenant') || widget.yourTenant == null) {
      return const SizedBox();
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _targetKey, // <--- supaya bisa tau posisi tombol
        onTap: () {
          if (_overlayEntry == null) {
            _showOverlay(context);
          } else {
            _hidePopover();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (widget.isScrolledEnough)
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: HugeIcon(
            icon: Iconsax.lamp_on,
            color: widget.yourTenant?.isOnline == true
                ? widget.yourTenant?.busyUntil != null
                    ? AppColors.warningColor
                    : AppColors.successColor
                : AppColors.errorColor,
          ),
        ),
      ),
    );
  }
}

/// Painter untuk bikin backdrop hitam dengan lubang transparan di area target
class SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  SpotlightPainter(this.targetRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.5);

    // gambar background hitam
    canvas.drawRect(Offset.zero & size, paint);

    // bikin lubang di area target
    paint.blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(targetRect.inflate(8), const Radius.circular(20)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect;
  }
}
