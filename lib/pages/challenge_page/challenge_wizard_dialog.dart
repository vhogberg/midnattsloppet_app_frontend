import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WizardDialog extends StatefulWidget {
  @override
  _WizardDialogState createState() => _WizardDialogState();
}

class _WizardDialogState extends State<WizardDialog> {
  int _currentPage = 0;
  String? selectedTeam;
  String? userTeam;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  List<String> teams = [];
  List<String> filteredTeams = [];

  @override
  void initState() {
    super.initState();
    fetchTeamsFromAPI();
    fetchUserTeam(); // används för titel på lagkamp, t.ex "mitt lag vs nordea lag 7", mitt lag ersätts med användarens lag.
  }

  // hantera wizard steg
  void _nextPage() {
    setState(() {
      if (_currentPage < 3) {
        _currentPage++;
      }
    });
  }

  void _previousPage() {
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      }
    });
  }

  // skicka iväg utmaning, logik tbi
  void _onSend() {
    Navigator.pop(context);
  }

  void _handleGoBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8 + 60, // bredd på wizard
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentPage,
                children: [
                  _buildSearchPage(),
                  _buildTitlePage(),
                  _buildDescriptionPage(),
                  _buildOverviewPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage == 0)
                    ElevatedButton(
                      onPressed: _handleGoBack,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // textfärg
                        backgroundColor: Colors.grey, // knappfärg
                      ),
                      child: Text('Tillbaka'),
                    ),
                  if (_currentPage > 0)
                    ElevatedButton(
                      onPressed: _previousPage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // textfärg
                        backgroundColor: Colors.grey, // knappfärg
                      ),
                      child: Text('Tillbaka'),
                    ),

                  if (_currentPage < 3)
                    Spacer(), // Spacer så att "nästa"-knappen alltid är på höger sida.
                  if (_currentPage < 3)
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // textfärg
                        backgroundColor: const Color(0XFF3C4785), // knappfärg
                      ),
                      child: Text('Nästa'),
                    ),
                  if (_currentPage == 3)
                    ElevatedButton(
                      onPressed: _onSend,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // textfärg
                        backgroundColor: Colors.green, // knappfärg
                      ),
                      child: Text('Skicka till $selectedTeam'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Wizard steg 1, sök efter ett lag.
  Widget _buildSearchPage() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            '1. Välj lag:',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sora',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Ange lagnamn...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              filterSearchResults(value);
            },
          ),
        ),
        Expanded(
          child: filteredTeams
                  .isEmpty // om det inte finns några lag i challengeable teams API endpoint
              ? Center(child: Text('Inga lag finns att utmana!'))
              : ListView.builder(
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
                        setState(() {
                          selectedTeam = filteredTeams[index];
                        });
                      },
                      selected: selectedTeam == filteredTeams[index],
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Hämta team för sökfunktionen för API
  Future<void> fetchTeamsFromAPI() async {
    try {
      final response = await http
          .get(Uri.parse('https://group-15-7.pvt.dsv.su.se/app/all/teams'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          teams = List<String>.from(data.map((item) => item as String));
          filteredTeams = List.from(teams);
        });
        print('Teams fetched: $teams');
      } else {
        throw Exception('Failed to load teams from API');
      }
    } catch (error) {
      print('Error fetching teams: $error');
    }
  }

  // Metod för att filtrera sökresultat
  void filterSearchResults(String query) {
    setState(() {
      filteredTeams = teams
          .where((team) => team.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Wizard steg 2, titel på lagkamp
  Widget _buildTitlePage() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              '2. Ange titel:',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Sora',
              ),
            ),
          ),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: userTeam != null
                  ? '${userTeam!} vs ${selectedTeam ?? ''}' // lokala användarens lag vs valt lag i listan
                  : 'Mitt lag vs ${selectedTeam ?? ''}', // tror inte detta behövs, men används för fall då användare inte är med i ett lag
              border: OutlineInputBorder(),
            ),
          )
        ],
      ),
    );
  }

  // Wizard steg 3, ange egna utmaningar
  Widget _buildDescriptionPage() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              '3. Ange utmaningar',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Sora',
              ),
            ),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: 'Ange egna handgjorda utmaningar',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  // Wizard steg 4, översikt och skicka iväg utmaning
  Widget _buildOverviewPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 4, 
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10), 
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Översikt',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ListTile(
                title: const Text(
                  'Valt lag:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  selectedTeam ?? 'Inget lag valt',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              ListTile(
                title: const Text(
                  'Titel:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  titleController.text,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              ListTile(
                title: const Text(
                  'Egna tävlingar:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  descriptionController.text,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // hämta användarens lag de är med i 
  Future<void> fetchUserTeam() async {
    try {
      // Replace 'username' with the actual username
      String? username = 'username';
      String? teamName = await fetchTeamName(username);
      setState(() {
        userTeam = teamName;
      });
    } catch (e) {
      print('Error fetching user team: $e');
    }
  }

  // hämta användarens lag de är med i stödmetod
  static Future<String?> fetchTeamName(String? username) async {
    try {
      var response = await http.get(
          Uri.parse('https://group-15-7.pvt.dsv.su.se/app/team/$username'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return data['name'];
      } else {
        throw Exception('Failed to fetch team name');
      }
    } catch (e) {
      print('Error fetching team name: $e');
      rethrow;
    }
  }
}
