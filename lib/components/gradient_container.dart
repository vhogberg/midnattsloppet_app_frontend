import 'package:flutter/material.dart';
import 'package:flutter_application/components/custom_colors.dart';

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
        color: CustomColors.midnattsblue,
        borderRadius: BorderRadius.circular(12.0),
        gradient: RadialGradient(
          radius: 0.8,
          center: gradientAlignment,
          colors: const [
            Color.fromARGB(255, 140, 90, 100), // Start color
            Color(0xFF3C4785), // End color // midnattsblue
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
