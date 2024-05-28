// ignore_for_file: use_super_parameters, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/authentication/session_manager.dart';
import 'package:flutter_application/components/custom_app_bar.dart';
import 'package:flutter_application/components/custom_colors.dart';
import 'package:flutter_application/components/return_arrow_argument.dart';
import 'package:flutter_application/components/top_three_teams.dart';
import 'package:flutter_application/models/team.dart';
import 'package:flutter_application/pages/search_page.dart';
import 'package:flutter_application/pages/team_pages/otherteampage.dart';
import 'package:iconsax/iconsax.dart';

class LeaderboardPage extends StatefulWidget {
  final Function(int) navigateToPage;
  const LeaderboardPage({Key? key, required this.navigateToPage})
      : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Team> teams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeamsFromAPI();
  }

  Future<void> fetchTeamsFromAPI() async {
    try {
      List<Team> fetchedTeams =
          await ApiUtils.fetchTeamsWithBoxAndCompanyName();
      setState(() {
        teams = fetchedTeams;
        isLoading = false;
      });
    } catch (e) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoading = false;
      });
      print('Error fetching teams: $e');
    }
  }

  Future<void> _onTeamTap(Team team) async {
    String? username = SessionManager.instance.username;
    bool isUserInTeam = false;

    // Fetch team members
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
      // Navigate to MyTeamPage
      widget.navigateToPage(4);
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
      appBar: CustomAppBar(
        key: null,
        title: 'Topplista',
        useActionButton: true,
        actionIcon: Iconsax.search_normal_1,
        onActionPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage()),
          );
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                children: [
                  TopThreeTeams(
                    smallCircleColor: CustomColors.midnattsblue,
                    smallCircleTextColor: Colors.white,
                    crownColor: CustomColors.midnattsblue,
                    teamNameColor: Colors.black,
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: ListView.builder(
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          return TeamListItem(
                            ranking: index + 1,
                            team: teams[index],
                            onTap: _onTeamTap,
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

class TeamListItem extends StatelessWidget {
  final int ranking;
  final Team team;
  final Function(Team) onTap;

  const TeamListItem({
    super.key,
    required this.ranking,
    required this.team,
    required this.onTap,
  });

  String getFormattedRanking(int ranking) {
    return ranking.toString();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(team),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
          title: Row(
            children: [
              Text(
                getFormattedRanking(ranking),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              if (team.companyName != null)
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(
                      'images/company_logos/${team.companyName}.png'),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  team.name,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${team.fundraiserBox.toStringAsFixed(0)} kr',
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
