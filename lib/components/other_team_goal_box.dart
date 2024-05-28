// ignore_for_file: use_super_parameters, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';

class OtherGoalBox extends StatefulWidget {
  final double height;
  final double width;
  final String teamName; // Add this parameter to accept team name

  const OtherGoalBox({
    Key? key,
    required this.height,
    required this.width,
    required this.teamName, // Required team name
  }) : super(key: key);

  @override
  _OtherGoalBoxState createState() => _OtherGoalBoxState();
}

class _OtherGoalBoxState extends State<OtherGoalBox> {
  double donationGoal = 0;

  @override
  void initState() {
    super.initState();
    fetchOtherDonationGoal();
  }

  Future<void> fetchOtherDonationGoal() async {
    try {
      double? goal = await ApiUtils.fetchOtherDonationGoal(widget.teamName);
      setState(() {
        donationGoal = goal?.toDouble() ?? 0;
      });
    } catch (e) {
      print("Error fetching donation goal: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: CustomPaint(
        painter: _GoalBoxPainter(),
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Mål',
                  style: TextStyle(
                    color: Color(0XFF3C4785),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sora',
                  ),
                ),
                Text(
                  '${donationGoal.toStringAsFixed(0)} kr',
                  style: const TextStyle(
                    color: Color(0XFF3C4785),
                    fontSize: 14,
                    fontFamily: 'Sora',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const double borderRadius = 10.0;

    Path path = Path()
      ..moveTo(borderRadius, 0)
      ..lineTo(size.width - borderRadius, 0)
      ..quadraticBezierTo(
          size.width, 0, size.width, borderRadius) // Top right corner
      ..lineTo(size.width, size.height - borderRadius)
      ..quadraticBezierTo(size.width, size.height, size.width - borderRadius,
          size.height) // Bottom right corner
      ..lineTo(borderRadius, size.height)
      ..quadraticBezierTo(
          0, size.height, 0, size.height - borderRadius) // Bottom left corner
      ..lineTo(0, borderRadius)
      ..quadraticBezierTo(0, 0, borderRadius, 0) // Top left corner
      ..close();

    path.moveTo(size.width / 2 - 5, 0);
    path.lineTo(size.width / 2, -5);
    path.lineTo(size.width / 2 + 5, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
