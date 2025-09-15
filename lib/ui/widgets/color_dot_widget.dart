import 'package:flutter/material.dart';

class ColorDotWidget extends StatelessWidget {
  const ColorDotWidget(this.color, {super.key});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: 12, backgroundColor: color);
  }
}
