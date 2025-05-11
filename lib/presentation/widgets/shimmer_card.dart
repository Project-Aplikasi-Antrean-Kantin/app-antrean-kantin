import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 150,
                height: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.grey, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 100, height: 14, color: Colors.white),
                  Container(width: 80, height: 14, color: Colors.white),
                ],
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Container(width: 120, height: 14, color: Colors.white),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.grey, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 100, height: 14, color: Colors.white),
                      Container(width: 80, height: 14, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 80, height: 16, color: Colors.white),
                      Container(width: 80, height: 16, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
