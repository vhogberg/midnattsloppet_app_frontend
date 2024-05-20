import 'package:flutter/material.dart';
import 'package:flutter_application/components/my_navigation_bar.dart';
import 'package:flutter_application/components/searchable_textfield.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';

class CreateTeamPage extends StatefulWidget {
  CreateTeamPage({super.key});

  @override
  _CreateTeamPageState createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final teamNameController = TextEditingController();
  TextEditingController charityController = TextEditingController();
  final donationGoalController = TextEditingController();
  List<String> entities = [];
  List<String> filteredEntities = [];
  String? selectedCharity;
  String? username;

  @override
  void initState() {
    super.initState();
    fetchEntitiesFromAPI();
    username = SessionManager.instance.username;
  }

  Future<void> fetchEntitiesFromAPI() async {
    final response =
        await http.get(Uri.parse('https://group-15-7.pvt.dsv.su.se/app/all/charities'));
    if (response.statusCode == 200) {
      // Decode the response body using UTF-8
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        entities = List<String>.from(data);
        filteredEntities.addAll(entities);
      });
    } else {
      throw Exception('Failed to load teams from API');
    }
  }

  Future<void> registerTeam(String username, String teamName,
      String charityName, String donationGoal) async {
    final String url =
        'https://group-15-7.pvt.dsv.su.se/app/register/profile/register/team';

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

// Metod för att filtrera sökresultat
  void filterSearchResults(String query) {
    List<String> searchResults = [];
    if (query.isNotEmpty) {
      for (String charity in entities) {
        if (charity.toLowerCase().contains(query.toLowerCase())) {
          searchResults.add(charity);
        }
      }
    } else {
      searchResults.addAll(entities);
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
                const SizedBox(height: 50),
                const SizedBox(height: 20),
                Text(
                  'Skapa ett lag',
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: charityController,
                    onChanged: (value) {
                      filterSearchResults(value);
                    },
                    onTap: () async {
                      String? selectedValue =
                          await _showSearchResultsPopup(context);
                      if (selectedValue != null) {
                        setState(() {
                          charityController.text = selectedValue;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Välj en välgörenhetsorganisation',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
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
                      MaterialPageRoute(
                          builder: (context) => MyNavigationBar()),
                    );
                  },
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _showSearchResultsPopup(BuildContext context) async {
    String? selectedCharityName;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.all(20.0),
              child: WillPopScope(
                onWillPop: () async {
                  charityController.clear();
                  return true;
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8 +
                      45, // bredd pop-up
                  height:
                      MediaQuery.of(context).size.height * 0.5, // höjd pop-up
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextField(
                          controller: charityController,
                          decoration: InputDecoration(
                            hintText: 'Ange välgörenhetsorganisation...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              filterSearchResults(value);
                            });
                          },
                        ),
                      ),
                      // Generera lista av teams inuti pop-up
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredEntities.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                filteredEntities[index],
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                selectedCharityName = filteredEntities[index];
                                Navigator.pop(context);
                              },
                              selected:
                                  selectedCharity == filteredEntities[index],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    // Update the selected charity name
    setState(() {
      selectedCharity = selectedCharityName;
    });

    // Return the selected charity name
    return selectedCharityName;
  }
}
