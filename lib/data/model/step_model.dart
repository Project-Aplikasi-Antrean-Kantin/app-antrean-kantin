import 'package:flutter/widgets.dart';

class StepModel {
  final String title;
  final IconData icon;
  final TextAlign? textAlign;
  final EdgeInsets? padding;

  StepModel(
      {this.textAlign = TextAlign.center,
      this.padding,
      required this.title,
      required this.icon});
}
