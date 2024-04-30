import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/searchable_textfield.dart';
import 'package:flutter_application/pages/homepage.dart';

class JoinTeamPage extends StatefulWidget {
  final String username; // Define username as a member variable

  JoinTeamPage(this.username, {super.key});

  @override
  _JoinTeamPageState createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  final teamNameController = TextEditingController();
  List<String> entities = [];
  List<String> filteredEntities = [];

  @override
  void initState() {
    super.initState();
    fetchEntitiesFromAPI();
  }

  Future<void> fetchEntitiesFromAPI() async {
    final response =
        await http.get(Uri.parse('https://group-15-7.pvt.dsv.su.se/app/all/teams'));
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
                  SearchableTextfield(
                    controller: teamNameController,
                    hintText: 'Sök efter lagnamn',
                    obscureText: false,
                    onChanged: (value) {
                      filterSearchResults(value);
                    },
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredEntities.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredEntities[index]),
                          onTap: () {
                            setState(() {
                              teamNameController.text = filteredEntities[index];
                              filteredEntities.clear();
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  MyButton(
                    text: "Anslut",
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
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
}
