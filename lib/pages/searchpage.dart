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
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: ListView.builder(
                  itemCount: filteredTeams.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: const Color(0XFF3C4785),
                        borderRadius: BorderRadius.circular(20.0),
                        gradient: const RadialGradient(
                          radius: 0.8,
                          center: Alignment(-0.5, 0.4),
                          colors: [
                            Color.fromARGB(255, 140, 90, 100), // Start color
                            Color(0xFF3C4785), // End color
                          ],
                          stops: [
                            0.15,
                            1.0,
                          ],
                        ),
                      ),
                      child: Text(
                        filteredTeams[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
