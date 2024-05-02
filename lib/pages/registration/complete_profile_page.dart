import 'package:flutter/material.dart';
import 'package:flutter_application/pages/registration/team/team_page.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/pages/homepage.dart';

class CompleteProfilePage extends StatefulWidget {

  CompleteProfilePage({Key? key}) : super(key: key);

    @override
  _CompleteProfilePage createState() => _CompleteProfilePage();
}

class _CompleteProfilePage extends State<CompleteProfilePage> {
  final nameController = TextEditingController();
  final companyVoucherCodeController = TextEditingController();
  String? username;

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
  }

  // should perhaps be combined to one API call with the register user method?
  Future<void> completeProfile(
      String username, String name, String voucherCode) async {
    // Replace 'your_backend_url' with your actual backend URL
    final url =
        Uri.parse('https://group-15-7.pvt.dsv.su.se/app/register/profile');

    // Construct the JSON payload
    final payload = jsonEncode({
      'username': username,
      'name': name,
      'voucherCode': voucherCode,
    });

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: payload,
      );

      if (response.statusCode == 200) {
        // Handle success response
        print('Profile updated successfully');
      } else {
        // Handle error response
        print('Error: ${response.body}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
    }
  }

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
                  fit: BoxFit.fitHeight //Justera bakgrund
                  ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const SizedBox(height: 20),
                Text(
                  'Låt oss färdigställa din profil!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: nameController,
                  hintText: 'Namn',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: companyVoucherCodeController,
                  hintText: 'Företagskod',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                MyButton(
                    text: "Färdigställ profil",
                    onTap: () async {
                      final name = nameController.text;
                      final companyVoucherCode =
                          companyVoucherCodeController.text;

                      if (name.isEmpty || companyVoucherCode.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Vänligen ange ett namn och en företagskod.'),
                        ));
                        return;
                      }

                      // Call updateUser method and wait for its completion
                      try {
                        await completeProfile(
                            username!, name, companyVoucherCode);

                        // Navigate to HomePage after updateUser completes successfully
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterTeamPage()),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Failed to update user profile: $e'),
                        ));
                      }
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
