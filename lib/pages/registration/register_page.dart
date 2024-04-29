import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/pages/login_page/login_widget.dart';
import 'package:flutter_application/pages/registration/complete_profile_page.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //TODO: move this to session manager(?)
  Future<String> registerUser(String username, String password) async {
    //try registering user
    final url = Uri.parse('https://group-15-7.pvt.dsv.su.se/app/register');
    final credentials = {'username': username, 'password': password};
    final jsonBody = jsonEncode(credentials);

    try {
      if (passwordController.text == confirmPasswordController.text) {
        final response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonBody,
        );

        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Exception('Failed to register: ${response.statusCode}');
        }
      } else {
        throw Exception("Passwords don't match");
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
                const SizedBox(height: 25),
                const SizedBox(height: 50),
                Text(
                  'Let\'s create your account!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(
                  text: "Sign Up",
                  onTap: () {
                    final username = emailController.text;
                    final password = passwordController.text;

                    // Check if username or password is empty
                    if (username.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Please enter both username and password.'),
                      ));
                      return; // Exit the function early if either field is empty
                    }

                    // Show CircularProgressIndicator while registering the user
                    showDialog(
                      context: context,
                      barrierDismissible:
                          false, // Prevent user from dismissing the dialog
                      builder: (BuildContext context) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );

                    // Proceed with registration if username and password are not empty
                    registerUser(username, password).then((response) {
                      // Close the CircularProgressIndicator dialog
                      Navigator.of(context).pop();

                      if (response == "User registered successfully") {
                        // Log in the user after successful registration
                        SessionManager.loginUser(username, password).then((_) {
                          // Navigate to CompleteProfilePage after saving session token
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CompleteProfilePage(username)),
                          );
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('Failed to save session token: $error'),
                          ));
                        });
                      } else if (response == "Username already exists" ||
                          response == "Username already exists") {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Failed to register: $response'),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Unexpected response: $response'),
                        ));
                      }
                    }).catchError((error) {
                      // Close the CircularProgressIndicator dialog
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
                        'Already have an account?',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Sign in',
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
