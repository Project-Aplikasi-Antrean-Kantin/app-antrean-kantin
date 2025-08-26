import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/step_model.dart';

class StepProgress extends StatefulWidget {
  final int currentStep; // step aktif
  final List<StepModel> steps; // daftar step

  const StepProgress({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  State<StepProgress> createState() => _StepProgressState();
}

class _StepProgressState extends State<StepProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    print("current step: ${widget.currentStep}");
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color getStepColor(int index) {
    if (index < widget.currentStep) {
      return AppColors.infoColor; // step yang sudah selesai
    }
    return Colors.grey; // step yang belum dicapai
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 Bagian atas: icon + garis progress
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.steps.length * 2 - 1, (index) {
            if (index.isEven) {
              // Titik step
              int stepIndex = index ~/ 2;
              final step = widget.steps[stepIndex];
              return Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                waitDuration: const Duration(microseconds: 1),
                message: step.title,
                preferBelow: true, // muncul di bawah avatar
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: getStepColor(stepIndex)),
                      child: HugeIcon(
                        icon: step.icon,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    // Positioned(
                    //   bottom: -10,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.only(
                    //           bottomLeft: Radius.circular(8),
                    //           bottomRight: Radius.circular(8)),
                    //       color: getStepColor(stepIndex),
                    //     ),
                    //     child: HugeIcon(
                    //       icon: HugeIcons.strokeRoundedArrowDown01,
                    //       size: 16,
                    //       color: Colors.white,
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              );
            } else {
              // Garis penghubung antar step
              int leftStep = index ~/ 2;
              int rightStep = leftStep + 1;

              bool isCompleted = rightStep < widget.currentStep;
              bool isActive = leftStep == widget.currentStep - 1;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 2,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      double progress = isActive ? _animation.value : 1.0;
                      return Stack(
                        children: [
                          Container(
                            height: 4,
                            color: Colors.grey[300],
                          ),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor:
                                isCompleted ? 1.0 : (isActive ? progress : 0),
                            child: Container(
                              height: 4,
                              color: AppColors.infoColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            }
          }),
        ),
      ],
    );
  }
}
