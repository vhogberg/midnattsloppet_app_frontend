import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/pages/login_page/login_widget.dart';
import 'package:flutter_application/pages/registration/complete_profile_page.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:http/http.dart' as http;

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

  Future<String> registerUser(String username, String password) async {
    final url = Uri.parse('https://group-15-7.pvt.dsv.su.se/app/register');
    final credentials = {'username': username, 'password': password};
    final jsonBody = jsonEncode(credentials);

    if (passwordController.text != confirmPasswordController.text) {
      throw Exception("Passwords don't match");
    }

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonBody,
      );

      // Log response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        throw Exception('Failed to register: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
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
                Text(
                  'Låt oss skapa ditt konto!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: 'Användarnamn',
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
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

                    if (username.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Vänligen ange både användarnamn och lösenord.'),
                      ));
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );

                    registerUser(username, password).then((response) {
                      Navigator.of(context).pop();

                      if (response.contains("User registered successfully")) {
                        SessionManager.instance.loginUser(username, password).then((_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CompleteProfilePage()),
                          );
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to save session token: $error'),
                          ));
                        });
                      } else if (response.contains("Username already exists")) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Användarnamnet finns redan.'),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Unexpected response: $response'),
                        ));
                      }
                    }).catchError((error) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to register: $error'),
                      ));
                    });
                  },
                ),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Har du redan ett användarkonto?',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Text(
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
