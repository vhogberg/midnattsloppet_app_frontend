// ignore_for_file: use_super_parameters, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/authentication/session_manager.dart';

class GoalBox extends StatefulWidget {
  final double height;
  final double width;

  const GoalBox({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  _GoalBoxState createState() => _GoalBoxState();
}

class _GoalBoxState extends State<GoalBox> {
  double donationGoal = 0;
  String? username;

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
    fetchGoal();
  }

  Future<void> fetchGoal() async {
    try {
      double goal = await ApiUtils.fetchGoal(username);
      setState(() {
        donationGoal = goal;
      });
    } catch (e) {
      print("Error");
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

    const double borderRadius = 10.0; // Adjust the radius for rounded edges

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
