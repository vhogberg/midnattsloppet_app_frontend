import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/custom_navigation_bar.dart';
import 'package:flutter_application/components/dialog_utils.dart';
import 'package:flutter_application/components/search_popup.dart';
import 'package:flutter_application/session_manager.dart';

import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';

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
  String? selectedCharity;
  String? username;

  @override
  void initState() {
    super.initState();
    fetchEntities();
    username = SessionManager.instance.username;
  }

  Future<void> fetchEntities() async {
    try {
      final data = await ApiUtils.fetchCharitiesFromAPI();
      setState(() {
        entities = data;
        filteredEntities.addAll(entities);
      });
    } catch (e) {
      print('Failed to fetch entities: $e');
    }
  }

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
                      String? selectedValue = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SearchPopup(
                            filteredEntities: filteredEntities,
                            hintText: 'Välj en välgörenhetsorganisation',
                          );
                        },
                      );
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
                      DialogUtils().showGenericErrorMessageNonStatic(context, "Fel",
                          "Vänligen fyll i alla uppgifter för att fortsätta.");
                      return;
                    }
                    await ApiUtils.registerTeam(
                        username!, teamName, charity, donationGoal);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CustomNavigationBar()),
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
}
