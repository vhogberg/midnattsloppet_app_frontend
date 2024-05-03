import 'package:flutter/material.dart';
import 'package:flutter_application/pages/registration/team/create_team_page.dart';
import 'package:flutter_application/pages/registration/team/join_team_page.dart';

import 'package:flutter_application/components/my_button.dart';

class RegisterTeamPage extends StatelessWidget {

  RegisterTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: 1000, //Fyller ut bakgrundsbilden
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Midnattsloppet.jpg"),
                fit: BoxFit.fitHeight, //Justera bakgrund
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const SizedBox(height: 20),
                Text(
                  'Välj eller skapa ett lag',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 10),
                const SizedBox(height: 20),
                MyButton(
                    text: "Anslut till ett befintligt lag",
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => JoinTeamPage()),
                      );
                    }),
                const SizedBox(height: 20), // Add some spacing between buttons
                MyButton(
                    text: "Skapa ett lag",
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateTeamPage()),
                      );
                    }),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
