import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class SlideToConfirm extends StatefulWidget {
  final VoidCallback onConfirmed;
  final String? placeholder;
  final double fontSize;

  const SlideToConfirm({
    this.placeholder = 'Geser ke kanan',
    this.fontSize = 14,
    super.key,
    required this.onConfirmed,
  });

  @override
  State<SlideToConfirm> createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  double _dragPosition = 0;

  final double _height = 42;
  final double _thumbSize = 40;
  final double safeGap = 12;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        final double maxDrag = width - _thumbSize;

        final double drag = _dragPosition.clamp(0.0, maxDrag);

        final double filledWidth = (drag + _thumbSize).clamp(0.0, width);

        return Container(
          height: _height,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(_height / 2),
          ),
          child: Stack(
            children: [
              /// 1️⃣ Background terisi
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: filledWidth,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(_height / 2),
                ),
              ),

              /// 2️⃣ Text hitam
              _buildText(Colors.black),

              /// 3️⃣ Text putih (masked)
              ShaderMask(
                shaderCallback: (bounds) {
                  final progress = (filledWidth / bounds.width).clamp(0.0, 1.0);

                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [progress, progress],
                    colors: const [
                      Colors.white,
                      Colors.transparent,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: _buildText(Colors.white),
              ),

              /// 4️⃣ Thumb
              Positioned(
                left: drag,
                top: (_height - _thumbSize) / 2,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      final next = _dragPosition + details.delta.dx;

                      // ⛔ STOP TOTAL kalau sudah mentok
                      if (next <= 0 || next >= maxDrag) {
                        _dragPosition = next.clamp(0.0, maxDrag);
                        return;
                      }

                      _dragPosition = next;
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (_dragPosition > maxDrag * 0.4) {
                      setState(() => _dragPosition = maxDrag);
                      widget.onConfirmed();
                    } else {
                      setState(() => _dragPosition = 0);
                    }
                  },
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildText(Color color) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(left: _thumbSize - safeGap),
        padding: EdgeInsets.only(right: safeGap),
        child: Text(
          widget.placeholder ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
          style: TextStyle(
            fontSize: widget.fontSize,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
