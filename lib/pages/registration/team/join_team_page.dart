import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/components/my_navigation_bar.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String? username; // plockas från sessionmanager

  @override
  void initState() {
    super.initState();
    filteredTeams.addAll(teams);
    fetchEntitiesFromAPI();
    username = SessionManager.instance.username;
  }

  Future<void> fetchEntitiesFromAPI() async {
    final response = await http
        .get(Uri.parse('https://group-15-7.pvt.dsv.su.se/app/all/teams'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        teams = List<String>.from(data);
        filteredTeams.addAll(teams);
      });
    } else {
      throw Exception('Failed to load teams from API');
    }
  }

// Metod för att filtrera sökresultat
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

  Future<void> joinTeam(String username, String teamName) async {
    final String url =
        'https://group-15-7.pvt.dsv.su.se/app/register/profile/join/team';

    Map<String, String> requestBody = {
      'username': username,
      'teamName': teamName,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Team joined successfully');
    } else if (response.statusCode == 400) {
      print('Team name already exists');
    } else {
      print('Failed to register team');
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
                fit: BoxFit.fitHeight, //Justera bakgrund
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
                  // Sökfältknapp (copied from the first build method)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        filterSearchResults(value);
                      },
                      onTap: () async {
                        String? selectedValue =
                            await _showSearchResultsPopup(context);
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
                      joinTeam(username!, teamName);
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
      ),
    );
  }

  Future<String?> _showSearchResultsPopup(BuildContext context) async {
    String? selectedTeamName;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.all(20.0),
              child: WillPopScope(
                onWillPop: () async {
                  searchController.clear();
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
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Ange lagnamn...',
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
                          itemCount: filteredTeams.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                filteredTeams[index],
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                selectedTeamName = filteredTeams[index];
                                Navigator.pop(context);
                              },
                              selected: selectedTeam == filteredTeams[index],
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

    // Update the selected team name
    setState(() {
      selectedTeam = selectedTeamName;
    });

    // Return the selected team name
    return selectedTeamName;
  }
}
