import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  List<String> teams = [
    'Team 1',
    'Team 2',
    'Team 3',
    'Team 4',
    'Team 5',
    'Team 6',
    'Team 7',
    'Team 8',
    'Team 9',
    'Team 10',
    'Team 11',
    'Team 12',
    'Team 13',
    'Team 14',
    'Team 15',
    'Team 16',
    'Team 17',
    'Team 18',
    'Team 19',
    'Team 20',
    'Team 21',
    'Team 22',
    'Team 23',
    'Team 24',
    'Team 25',
    'Team 26',
    'Team 27',
    'Team 28',
    'Team 29',
    'Team 30',
  ];
  List<String> filteredTeams = [];

  @override
  void initState() {
    super.initState();
    filteredTeams = teams;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
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
              decoration: InputDecoration(
                labelText: 'Ange lagnamn',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _filterTeams(value); // Filter teams based on input text
              },
            ),
            SizedBox(height: 20),
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
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      padding: EdgeInsets.all(10.0),
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
                        style: TextStyle(
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

  void _filterTeams(String searchTerm) {
    setState(() {
      filteredTeams = teams
          .where((team) =>
              team.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
  }
}
