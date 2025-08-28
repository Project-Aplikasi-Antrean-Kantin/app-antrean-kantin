import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/model/user_model.dart';

class TenantButton extends StatefulWidget {
  final TenantModel? yourTenant;
  final bool isScrolledEnough;
  final UserModel user;

  const TenantButton({
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
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // DUPLIKASI TOMBOL DI POSISI ASLINYA
          Positioned(
            left: rect.left,
            top: rect.top,
            width: rect.width,
            height: rect.height,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.yourTenant?.isOnline == true
                          ? widget.yourTenant?.busyUntil != null
                              ? AppColors.warningColor.withOpacity(0.5)
                              : AppColors.successColor.withOpacity(0.5)
                          : AppColors.errorColor
                              .withOpacity(0.5), // highlight glow
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: HugeIcon(
                  icon: widget.yourTenant?.busyUntil != null
                      ? HugeIcons.strokeRoundedAlertDiamond
                      : HugeIcons.strokeRoundedTimeSetting03,
                  color: widget.yourTenant?.isOnline == true
                      ? widget.yourTenant?.busyUntil != null
                          ? AppColors.warningColor
                          : AppColors.successColor
                      : AppColors.errorColor,
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
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // ⬅️ penting, biar height ikut isi
                  children: const [
                    Text(
                      "Dialog dengan backdrop spotlightklasfjlakjflakjfalskjdlasjdlaskjdlksajdlsjadljsaldlasjd",
                    ),
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
            icon: widget.yourTenant?.busyUntil != null
                ? HugeIcons.strokeRoundedAlertDiamond
                : HugeIcons.strokeRoundedTimeSetting03,
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
