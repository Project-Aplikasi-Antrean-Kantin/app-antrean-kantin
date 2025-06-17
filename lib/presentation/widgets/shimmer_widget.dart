import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class ShimmerLoadingWidget extends StatelessWidget {
  final int itemCount;
  final bool showContainer;
  final bool showContainerTitle;
  final bool shimmerContainerHome;
  final bool shimmerContainerImage;
  final double itemHeight;
  final double containerHeight;
  final double containerTittleHeight;
  final double heightContainerImage;
  final double widhtContainerImage;
  final EdgeInsets padding;
  final EdgeInsets marginContainer;
  final EdgeInsets marginContainerTitle;
  final BorderRadiusGeometry borderRadiusList;
  final BorderRadiusGeometry borderRadiusContainer;
  final BorderRadiusGeometry borderRadiusContainerTitle;

  const ShimmerLoadingWidget({
    super.key,
    this.itemCount = 4,
    this.showContainer = false,
    this.showContainerTitle = false,
    this.shimmerContainerHome = false,
    this.shimmerContainerImage = false,
    this.itemHeight = 100,
    this.containerHeight = 50,
    this.containerTittleHeight = 50,
    this.heightContainerImage = 0,
    this.widhtContainerImage = 0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    this.marginContainer = const EdgeInsets.only(bottom: 10),
    this.marginContainerTitle = const EdgeInsets.only(bottom: 10),
    this.borderRadiusContainer = const BorderRadius.all(Radius.circular(20)),
    this.borderRadiusContainerTitle =
        const BorderRadius.all(Radius.circular(20)),
    this.borderRadiusList = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      padding: padding,
      child: Column(
        children: [
          if (showContainer)
            Container(
              margin: marginContainer,
              height: containerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300]!,
                borderRadius: borderRadiusContainer,
              ),
            ),
          if (showContainerTitle)
            Container(
              margin: marginContainerTitle,
              height: containerTittleHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300]!,
                borderRadius: borderRadiusContainerTitle,
              ),
            ),
          if (shimmerContainerHome)
            Column(
              children: List.generate(
                itemCount,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    period: const Duration(seconds: 3),
                    child: Container(
                      height: itemHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: borderRadiusList,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (shimmerContainerImage)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: heightContainerImage,
                width: widhtContainerImage,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
