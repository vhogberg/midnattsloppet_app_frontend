import 'package:flutter/material.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/pages/homepage.dart';
import 'package:flutter_application/pages/registration/register_page.dart';
import 'package:flutter_application/session_manager.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: 950, //Fyller ut bakgrundsbilden
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/Midnattsloppet.jpg"),
                  fit: BoxFit.fitHeight //Justera bakgrund
                  ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome back, you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(
                  text: "Sign In",
                  onTap: () {
                    final username = emailController.text;
                    final password = passwordController.text;

                    // Check if username or password is empty
                    if (username.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Please enter both username and password.'),
                      ));
                      return; // Exit the function early if either field is empty
                    }

                    // Proceed with login if username and password are not empty
                    SessionManager.loginUser(username, password)
                        .then((sessionToken) {
                      if (sessionToken != null) {
                        // Save session token and navigate to home page
                        SessionManager.saveSessionToken(sessionToken).then((_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        });
                      } else {
                        // Handle login failure
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              'Failed to login: User not found or invalid credentials.'),
                        ));
                      }
                    }).catchError((error) {
                      // Handle login error
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to login: $error'),
                      ));
                    });
                  },
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()),
                        );
                      },
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
