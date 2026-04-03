import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class ChatPingAction extends StatelessWidget {
  final int orderId;
  final bool isThereNewChat;
  final bool isCooldown;
  final VoidCallback onPing;
  final VoidCallback onChat;
  final bool outlined;

  const ChatPingAction({
    super.key,
    required this.orderId,
    required this.isThereNewChat,
    required this.isCooldown,
    required this.onPing,
    required this.onChat,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonPadding = outlined ? 12.0 : 8.0;

    final Color mainColor =
        outlined ? AppColors.primaryColor300 : AppColors.primaryColor;

    final ButtonStyle style = outlined
        ? OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            side: BorderSide(color: mainColor, width: 2),
            padding: EdgeInsets.all(buttonPadding),
          )
        : ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.primaryColor100,
            shape: const CircleBorder(),
            padding: EdgeInsets.all(buttonPadding),
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            outlined
                ? OutlinedButton(
                    key: Key('chatButton$orderId'),
                    style: style,
                    onPressed: onChat,
                    child: Icon(
                      Iconsax.message_text_copy,
                      size: outlined ? 24 : 20,
                      color: mainColor,
                    ),
                  )
                : ElevatedButton(
                    key: Key('chatButton$orderId'),
                    style: style,
                    onPressed: onChat,
                    child: Icon(
                      Iconsax.message,
                      size: 20,
                      color: mainColor,
                    ),
                  ),
            if (isThereNewChat)
              Positioned(
                right: 8,
                top: 4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        outlined
            ? OutlinedButton(
                key: Key('ping$orderId'),
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  side: BorderSide(
                    color: isCooldown ? Colors.grey : mainColor,
                    width: 2,
                  ),
                  padding: EdgeInsets.all(buttonPadding),
                ),
                onPressed: isCooldown ? null : onPing,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedMegaphone02,
                  color: isCooldown ? Colors.grey : mainColor,
                ),
              )
            : ElevatedButton(
                key: Key('ping$orderId'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCooldown ? Colors.grey[300] : AppColors.primaryColor100,
                  elevation: 0,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(buttonPadding),
                ),
                onPressed: isCooldown ? null : onPing,
                child: SvgPicture.asset(
                  'assets/images/megaphone.svg',
                  color: isCooldown ? Colors.grey : mainColor,
                  width: 20,
                  height: 20,
                ),
              ),
      ],
    );
  }
}
