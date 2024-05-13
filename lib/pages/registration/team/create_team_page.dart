import 'package:flutter/material.dart';
import 'package:flutter_application/components/searchable_textfield.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/pages/homepage.dart';

class CreateTeamPage extends StatefulWidget {

  CreateTeamPage({super.key});

  @override
  _CreateTeamPageState createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final teamNameController = TextEditingController();
  final charityController = TextEditingController();
  final donationGoalController = TextEditingController();
  List<String> entities = [];
  List<String> filteredEntities = [];
  String? username;

  @override
  void initState() {
    super.initState();
    // Access the username from the SessionManager
    username = SessionManager.instance.username;
  }

  Future<void> fetchEntitiesFromAPI() async {
    final response = await http
        .get(Uri.parse('https://group-15-7.pvt.dsv.su.se/app/all/charities'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        entities = List<String>.from(data);
        filteredEntities.addAll(entities);
      });
    } else {
      throw Exception('Failed to load entities from API');
    }
  }

  Future<void> registerTeam(String username, String teamName, String charityName, String donationGoal) async {
    final String url ='https://group-15-7.pvt.dsv.su.se/app/register/profile/register/team';

    Map<String, String> requestBody = {
      'username': username,
      'teamName': teamName,
      'charityName': charityName,
      'donationGoal': donationGoal,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Team registered successfully');
    } else if (response.statusCode == 400) {
      print('Team name already exists');
    } else {
      print('Failed to register team: ${response.statusCode}');
      print('Response body: ${response.body}');
      // Handle other error cases here, such as 500 Internal Server Error
    }
  }


  void filterSearchResults(String query) {
    List<String> searchResults = [];
    if (query.isNotEmpty) {
      for (String entity in entities) {
        if (entity.toLowerCase().contains(query.toLowerCase())) {
          searchResults.add(entity);
        }
      }
    }
    setState(() {
      filteredEntities = searchResults;
    });
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
                  'Välj eller skapa ett lag',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: teamNameController,
                  hintText: 'Vänligen ange ett lagnamn',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                SearchableTextfield(
                  controller: charityController,
                  hintText: 'Vänligen ange välgörenhetsorganisation',
                  obscureText: false,
                  onChanged: (value) {
                    filterSearchResults(value);
                  },
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: donationGoalController,
                  hintText: 'Vänligen ange ett donationsmål i SEK',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 25),
                MyButton(
                    text: "Skapa lag",
                    onTap: () async {
                      final teamName = teamNameController.text;
                      final charity = charityController.text;
                      final donationGoal = donationGoalController.text;

                      if (teamName.isEmpty ||
                          charity.isEmpty ||
                          donationGoal.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Vänligen fyll i alla uppgifter för att fortsätta.'),
                        ));
                        return;
                      }
                      registerTeam(username!, teamName, charity, donationGoal);
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
