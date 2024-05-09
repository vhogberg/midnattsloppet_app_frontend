import 'package:flutter/material.dart';
import 'package:flutter_application/components/donation_progress_bar.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application/components/custom_app_bar.dart';

class MyTeamPage extends StatelessWidget {
  const MyTeamPage({Key? key}) : super(key: key);

  static const List<String> teamMembers = [
    'John Doe',
    'Jane Doe',
    'Adam Doe',
    'James Doe',
    'Carl Doe',
  ];

  // Method to generate ListTiles dynamically based on team members list
  List<Widget> generateTeamList() {
    return teamMembers.map((member) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: const Icon(
            Icons.person,
            color: Colors.black, // Change the icon color to blue
          ),
          title: Text(
            member,
            style: const TextStyle(
              color: Colors.black, // Change text color to black
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        key: null,
        title: 'Mitt lag',
        // teampage ska ha en logout-knapp till höger, så detta nedan sätts "true"
        useActionButton: true,
        // logout knapp från Iconsax bilbiotek
        actionIcon: Iconsax.logout_1,
        // kalla på onActionPressed metoden också, använd sessionmanager för att logga ut
        onActionPressed: () {
          SessionManager.instance.signUserOut(context);
        },
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
                  radius: 74,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      AssetImage('images/stockholm-university.png'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
// Textbox with the donation pledge name
// import via API?
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                'Stödjer: Barncancerfonden', // Static text
                style: TextStyle(fontSize: 16),
              ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Team Members',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                // Generate ListTiles dynamically
                ...generateTeamList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
