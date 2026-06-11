import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';

class DetailFoodHeader extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onClose;

  const DetailFoodHeader({
    Key? key,
    required this.imageUrl,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageByUrl(
          url: imageUrl,
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 3.5,
        ),
        Positioned(
          top: 24,
          left: 16,
          child: Semantics(
            identifier: 'backButton',
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
