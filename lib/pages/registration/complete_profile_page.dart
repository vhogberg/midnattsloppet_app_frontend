import 'package:flutter/material.dart';
import 'package:flutter_application/pages/registration/team/team_page.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: 1000,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Midnattsloppet.jpg"),
                fit: BoxFit.fitHeight,
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
                  hintText: 'Användarnamn',
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

                      try {
                        await SessionManager.instance.completeProfile(
                            username!, name, companyVoucherCode);

                        // Navigate to RegisterTeamPage after profile completion
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterTeamPage()),
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
