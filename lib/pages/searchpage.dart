import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  List<String> teams = [];
  List<String> filteredTeams = [];

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sök lag',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Sora',
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Ange lagnamn',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _filterTeams(value); // Filter teams based on input text
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ListView.builder(
                  itemCount: filteredTeams.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          filteredTeams[index],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  void _filterTeams(String searchTerm) {
    setState(() {
      filteredTeams = teams
          .where(
              (team) => team.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
  }
}