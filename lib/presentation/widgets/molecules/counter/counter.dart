import 'package:flutter/cupertino.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/widgets/molecules/counter/widgets/count_change.dart';
import 'package:testgetdata/presentation/widgets/molecules/counter/widgets/decrement.dart';
import 'package:testgetdata/presentation/widgets/molecules/counter/widgets/increment.dart';

class Counter extends StatelessWidget {
  final VoidCallback onDecrement;
  final int count;
  final ValueChanged<int> onCountChanged;
  final VoidCallback onIncrement;
  final double widthEachButton;
  final double heightEachButton;
  final bool withBorderSeparator;

  const Counter(
      {super.key,
      this.withBorderSeparator = false,
      this.widthEachButton = 48,
      this.heightEachButton = 48,
      required this.onDecrement,
      required this.count,
      required this.onCountChanged,
      required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primaryColor,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tombol -
            Decrement(
                onTap: onDecrement,
                height: heightEachButton,
                width: widthEachButton),

            // Counter
            CountChange(
              withBorderSeparator: withBorderSeparator,
              width: widthEachButton,
              height: heightEachButton,
              count: count,
              onChanged: onCountChanged,
            ),

            // Tombol +
            Increment(
                onTap: onIncrement,
                height: heightEachButton,
                width: widthEachButton),
          ],
        ));
  }
}
