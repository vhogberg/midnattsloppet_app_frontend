import 'package:flutter/material.dart';
import 'package:flutter_application/components/dialog_utils.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/pages/login_page/login_widget.dart';
import 'package:flutter_application/pages/registration/complete_profile_page.dart';
import 'package:flutter_application/session_manager.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? username;

  @override
  void initState() {
    super.initState();
    username = SessionManager.instance.username;
  }

  bool isValidEmail(String email) {
    // Define the email pattern
    String emailRegex = r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$';
    RegExp regex = RegExp(emailRegex);
    return regex.hasMatch(email);
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
                const SizedBox(height: 25),
                const SizedBox(height: 50),
                const Text(
                  'Låt oss skapa ditt konto!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: 'E-postadress',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Lösenord',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Bekräfta lösenord',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [],
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(
                  text: "Skapa konto",
                  onTap: () {
                    final username = emailController.text;
                    final password = passwordController.text;
                    final confirmPassword = confirmPasswordController.text;

                    if (username.isEmpty || password.isEmpty) {
                      DialogUtils().showGenericErrorMessageNonStatic(context, "Fel",
                          'Vänligen ange både e-postadress och lösenord.');
                      return;
                    }

                    if (!isValidEmail(username)) {
                      DialogUtils().showGenericErrorMessageNonStatic(context, "Fel",
                          'Vänligen ange en giltig e-postadress.');
                      return;
                    }

                    if (password != confirmPassword) {
                      DialogUtils().showGenericErrorMessageNonStatic(context, "Fel",
                          'Lösenorden matchar inte.');
                      return;
                    }
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );

                    SessionManager.instance
                        .registerUser(username, password)
                        .then((response) {
                      Navigator.of(context).pop();

                      if (response.contains("User registered successfully")) {
                        SessionManager.instance
                            .loginUser(username, password)
                            .then((_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CompleteProfilePage()),
                          );
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('Failed to save session token: $error'),
                          ));
                        });
                      } else if (response.contains("Username already exists")) {
                        DialogUtils().showGenericErrorMessageNonStatic(context, "Fel",
                            "E-postadressen är redan kopplat till ett konto.");
                      } else {
                        DialogUtils().showGenericErrorMessageNonStatic(
                            context, "Fel", "Okänt fel.");
                      }
                    }).catchError((error) {
                      DialogUtils().showGenericErrorMessageNonStatic(
                          context, "Fel", "Registreringen misslyckades.");
                    });
                  },
                ),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Har du redan ett användarkonto?',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Logga in',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
