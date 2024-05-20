import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WizardDialog extends StatefulWidget {
  @override
  _WizardDialogState createState() => _WizardDialogState();
}

class _WizardDialogState extends State<WizardDialog> {
  int _currentPage = 0;
  String selectedTeam = '';
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  List<String> teams = [];
  List<String> filteredTeams = [];

  @override
  void initState() {
    super.initState();
    fetchTeamsFromAPI();
  }

  // Hämta team för sökfunktionen för API
  Future<void> fetchTeamsFromAPI() async {
    try {
      final response = await http.get(Uri.parse('https://group-15-7.pvt.dsv.su.se/app/all/teams'));
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
    // Handle the send action
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(20.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text('Tillbaka'),
                    ),
                  if (_currentPage < 3)
                    TextButton(
                      onPressed: _nextPage,
                      child: Text('Nästa'),
                    ),
                  if (_currentPage == 3)
                    TextButton(
                      onPressed: _onSend,
                      child: Text('Skicka iväg utmaningen'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPage() {
    return Column(
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
              filterSearchResults(value);
            },
          ),
        ),
        Expanded(
          child: filteredTeams.isEmpty
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

  Widget _buildTitlePage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Ange en titel på lagkampen',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: 'Ange egna tävlingar',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            'Översikt',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Valt lag: $selectedTeam'),
          Text('Titel: ${titleController.text}'),
          Text('Egna tävlingar: ${descriptionController.text}'),
        ],
      ),
    );
  }
}