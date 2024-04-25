import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/pages/homepage.dart';

class CompleteProfilePage extends StatelessWidget {
  final String username; // Define username as a member variable

  CompleteProfilePage(this.username, {Key? key}) : super(key: key);

  final nameController = TextEditingController();
  final companyVoucherCodeController = TextEditingController();
  final confirmCompanyVoucherCodeController = TextEditingController();

  Future<String> updateUser(
      String username, String name, String companyVoucher) async {
    //try registering user
    final url =
        Uri.parse('https://group-15-7.pvt.dsv.su.se/app/register/profile');
    final credentials = {
      'username': username,
      'name': name,
      'company': companyVoucher
    };
    final jsonBody = jsonEncode(credentials);

    try {
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
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Icon(
                    Icons.lock,
                    size: 75,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Let\'s complete your profile!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: nameController,
                  hintText: 'Name',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: companyVoucherCodeController,
                  hintText: 'Voucher code',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                MyButton(
                    text: "Complete profile",
                    onTap: () {
                      final name = nameController.text;
                      final companyVoucherCode =
                          companyVoucherCodeController.text;

                      if (name.isEmpty || companyVoucherCode.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Please enter a name and a company voucher code to proceed.'),
                        ));
                        return;
                      }
                      // update user with name and get company registered form voucher code
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
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
