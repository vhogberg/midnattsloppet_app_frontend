import 'package:flutter/material.dart';
import 'package:flutter_application/pages/navigation_bar/navigation_bar.dart';

class ChallengePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lagkamp'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'images/Lagkamp_image.png',
              fit: BoxFit.fitWidth,
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Sök upp lag att utmana...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPurpleBox('Tävla i donationer', 185),
                _buildPurpleBox('Tävla i tid', 185),
              ],
            ),
            const SizedBox(height: 20),
            _buildPurpleBox('Egen tävling', 500),
            const SizedBox(height: 25),
            Stack(
              children: [
                Container(
                  width: 400,
                  height: 65,
                  decoration: BoxDecoration(
                    color: const Color(0XFF3C4785),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                Positioned(
                  top: 5,
                  left: 25,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Image.asset(
                          'images/fire.png',
                          width: 35,
                          height: 35,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Start a challenge',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'images/fire.png',
                          width: 35,
                          height: 35,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Your content goes here',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MyNavigationBar(),
    );
  }

  Widget _buildPurpleBox(String text, double width) {
    return Container(
      width: width,
      height: 65,
      decoration: BoxDecoration(
        color: Color(0XFF3C4785),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
