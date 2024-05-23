import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/models/team.dart';
import 'package:flutter_application/pages/myteampage.dart';
import 'package:flutter_application/pages/otherteampage.dart';
import 'package:flutter_application/session_manager.dart';
import 'package:flutter_application/components/return_arrow_argument.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  List<Team> teams = [];
  List<Team> filteredTeams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    try {
      List<Team> fetchedTeams =
          await ApiUtils.fetchTeamsWithBoxAndCompanyName();
      setState(() {
        teams = fetchedTeams;
        filteredTeams = fetchedTeams;
        isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch teams: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterTeams(String searchTerm) {
    setState(() {
      filteredTeams = teams
          .where((team) =>
              team.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
  }

  Future<void> _onTeamTap(Team team) async {
    String? username = SessionManager.instance.username;
    bool isUserInTeam = false;

    try {
      List<dynamic>? teamMembers = await ApiUtils.fetchOtherMembers(team.name);
      if (teamMembers != null) {
        isUserInTeam =
            teamMembers.any((member) => member['username'] == username);
      }
    } catch (e) {
      print('Error fetching team members: $e');
    }

    if (isUserInTeam) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtherTeamPage(team: team),
          settings: RouteSettings(
            arguments: ReturnArrowArgument(showReturnArrow: true),
          ),
        ),
      );
    } else {
      // Navigate to OtherTeamPage with the team details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtherTeamPage(team: team),
          settings: RouteSettings(
            arguments: ReturnArrowArgument(showReturnArrow: true),
          ),
        ),
      );
    }
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
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ListView.builder(
                        itemCount: filteredTeams.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () => _onTeamTap(filteredTeams[index]),
                            child: Container(
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
                                title: Row(children: [
                                  Text(
                                    filteredTeams[index].name,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (filteredTeams[index].companyName != null)
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.white,
                                      backgroundImage: AssetImage(
                                          'images/company_logos/${filteredTeams[index].companyName}.png'),
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                      '${filteredTeams[index].fundraiserBox}kr'),
                                ]),
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
}
