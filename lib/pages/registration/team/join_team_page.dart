import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/my_navigation_bar.dart';
import 'package:flutter_application/components/search_popup.dart';
import 'package:flutter_application/session_manager.dart';

import 'package:flutter_application/components/my_button.dart';

class JoinTeamPage extends StatefulWidget {
  JoinTeamPage({super.key});

  @override
  _JoinTeamPageState createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  TextEditingController searchController = TextEditingController();
  List<String> teams = [];
  List<String> filteredTeams = [];
  String? selectedTeam;
  String? username;

  @override
  void initState() {
    super.initState();
    filteredTeams.addAll(teams);
    fetchTeams();
    username = SessionManager.instance.username;
  }

  Future<void> fetchTeams() async {
    try {
      final data = await ApiUtils.fetchTeamsFromAPI();
      setState(() {
        teams = data;
        filteredTeams.addAll(teams);
      });
    } catch (e) {
      print('Failed to fetch teams: $e');
    }
  }

  void filterSearchResults(String query) {
    List<String> searchResults = [];
    if (query.isNotEmpty) {
      for (String team in teams) {
        if (team.toLowerCase().contains(query.toLowerCase())) {
          searchResults.add(team);
        }
      }
    } else {
      searchResults.addAll(teams);
    }
    setState(() {
      filteredTeams = searchResults;
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'Gå med i ett lag',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        filterSearchResults(value);
                      },
                      onTap: () async {
                        String? selectedValue = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SearchPopup(
                              filteredEntities: filteredTeams,
                              hintText: 'Välj ett lag',
                            );
                          },
                        );
                        if (selectedValue != null) {
                          setState(() {
                            searchController.text = selectedValue;
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
                        hintText: 'Välj ett lag att ansluta till',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),
                  MyButton(
                    text: "Anslut",
                    onTap: () async {
                      final teamName = searchController.text;

                      if (teamName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Vänligen fyll i alla uppgifter för att fortsätta.'),
                        ));
                        return;
                      }
                      try {
                        await ApiUtils.joinTeam(username!, teamName);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyNavigationBar()),
                        );
                      } catch (e) {
                        print('Failed to join team: $e');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Failed to join team.'),
                        ));
                      }
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
