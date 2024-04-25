import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String username; // Define username as a member variable

  const HomePage(this.username, {Key? key}) : super(key: key);

  // Method to sign the user out
  void signUserOut(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () =>
                signUserOut(context), // Call signUserOut method on press
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Text("Logged in as: $username"), // Access username here
      ),
    );
  }
}
