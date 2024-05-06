import 'package:flutter/material.dart';
import 'package:flutter_application/components/donation_progress_bar.dart';
import 'package:flutter_application/pages/navigation_bar/navigation_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class MyTeamPage extends StatelessWidget {
  const MyTeamPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mitt lag'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular team picture at the middle top
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0XFF3C4785), // Use the blue color provided
                ),
                child: const Center(
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        AssetImage('images/stockholm-university.png'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Textbox with the donation pledge name
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Stödjer: Barncancerfonden', // Static text
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            // Container with team members names
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0XFF3C4785),
                borderRadius: BorderRadius.circular(13.0),
                gradient: const RadialGradient(
                  radius: 0.8,
                  center: Alignment(-0.5, 0.4),
                  colors: [
                    Color.fromARGB(255, 140, 90, 100), // Start color
                    Color(0xFF3C4785), // End color
                  ],
                  stops: [
                    0.15,
                    1.0,
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team Members',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  // You can populate this list dynamically from an API
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('John Doe'),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Jane Doe'),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Adam Doe'),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('James Doe'),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Carl Doe'),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const MyNavigationBar());
  }
}

// ShareHelper class remains unchanged
