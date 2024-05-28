// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_application/authentication/session_manager.dart';
import 'package:flutter_application/components/custom_navigation_bar.dart';
import 'package:flutter_application/components/dialog_utils.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/components/registration_wizard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear the text fields when the login page is initialized
    _usernameController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: 1000, // Fyller ut bakgrundsbilden
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Midnattsloppet.jpg"),
                fit: BoxFit.fitHeight, // Justera bakgrund
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Välkommen!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _usernameController,
                  hintText: 'E-postadress',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _passwordController,
                  hintText: 'Lösenord',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                ),
                const SizedBox(height: 25),
                MyButton(
                  text: "Logga in",
                  onTap: () {
                    final username = _usernameController.text;
                    final password = _passwordController.text;

                    // Check if username or password is empty
                    if (username.isEmpty || password.isEmpty) {
                      DialogUtils().showGenericErrorMessageNonStatic(
                          context,
                          "Fel",
                          "Vänligen ange både e-postadress och lösenord.");
                      return; // Exit the function early if either field is empty
                    }

                    // Proceed with login if username and password are not empty
                    SessionManager.instance
                        .loginUser(username, password)
                        .then((sessionToken) {
                      // Save session token and navigate to home page
                      SessionManager.instance
                          .saveSessionToken(sessionToken)
                          .then((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CustomNavigationBar(
                                    selectedPage: 0,
                                  )),
                        );
                      });
                    }).catchError((error) {
                      DialogUtils().showGenericErrorMessageNonStatic(
                          context,
                          "Fel",
                          "Inloggningen misslyckades, vänligen försök igen.");
                    });
                  },
                ),
                const SizedBox(height: 25),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                ),
                //Semi-transparent white box
                Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return RegistrationWizardDialog();
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: 275,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Inget konto? Registrera dig nu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Sora',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
