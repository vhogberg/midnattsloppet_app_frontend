import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final double width;
  final double height;
  final AlignmentGeometry gradientAlignment;

  const GradientContainer({
    Key? key,
    required this.width,
    required this.height,
    required this.gradientAlignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0XFF3C4785),
        borderRadius: BorderRadius.circular(12.0),
        gradient: RadialGradient(
          radius: 0.8,
          center: gradientAlignment,
          colors: const [
            Color.fromARGB(255, 140, 90, 100), // Start color
            Color(0xFF3C4785), // End color
          ],
          stops: const [
            0.15,
            1.0,
          ],
        ),
      ),
    );
  }
}
