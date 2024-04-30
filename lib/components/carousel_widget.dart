import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180,
          enableInfiniteScroll: true,
          autoPlay: true,
          viewportFraction: 0.96,
        ),
        items: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: Image.asset('assets/images/ads.png'),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: Image.asset('assets/images/ads.png'),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: Image.asset('assets/images/ads.png'),
          ),
        ],
      ),
    );
  }
}
