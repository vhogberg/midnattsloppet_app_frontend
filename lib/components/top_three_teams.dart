// ignore_for_file: use_super_parameters, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application/api_utils/api_utils.dart';
import 'package:flutter_application/components/custom_colors.dart';
import 'package:flutter_application/models/team.dart';
import 'package:iconsax/iconsax.dart';

class TopThreeTeams extends StatefulWidget {
  final Color? smallCircleColor;
  final Color? smallCircleTextColor;
  final Color? crownColor;
  final Color? teamNameColor;

  const TopThreeTeams(
      {Key? key,
      this.smallCircleColor,
      this.smallCircleTextColor,
      this.crownColor,
      this.teamNameColor})
      : super(key: key);

  @override
  _TopThreeTeamsState createState() => _TopThreeTeamsState();
}

class _TopThreeTeamsState extends State<TopThreeTeams> {
  List<Team> teams = [];
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
      if (mounted) {
        setState(() {
          teams = fetchedTeams;
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle any errors that occur during the fetch
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching teams: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color? smallCircleColor = widget.smallCircleColor;
    Color? smallCircleTextColor = widget.smallCircleTextColor;
    Color? crownColor = widget.crownColor;
    Color? teamNameColor = widget.teamNameColor;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (teams.length < 3) {
      return const SizedBox
          .shrink(); // Return an empty widget if there are less than 3 teams
    }

    List<Team> topThreeTeams = teams.take(3).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                    height: 20), // Padding to offset the second place lower
                buildTeamCircle(topThreeTeams[1], smallCircleColor,
                    smallCircleTextColor, crownColor, teamNameColor,
                    rank: 2),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                buildTeamCircle(topThreeTeams[0], smallCircleColor,
                    smallCircleTextColor, crownColor, teamNameColor,
                    isFirstPlace: true, rank: 1),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                    height: 20), // Padding to offset the third place lower
                buildTeamCircle(topThreeTeams[2], smallCircleColor,
                    smallCircleTextColor, crownColor, teamNameColor,
                    rank: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTeamCircle(Team team, Color? smallCircleColor,
      Color? smallCircleTextColor, Color? crownColor, Color? teamNameColor,
      {bool isFirstPlace = false, required int rank}) {
    double circleSize = isFirstPlace ? 80.0 : 60.0;
    double smallCircleSize = 20.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: circleSize + 30,
          width: circleSize + 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main team circle
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CustomColors.midnattsblue,
                    width: 3.0,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(5.0), // Padding around the image
                  child: Image(
                    image: AssetImage(
                        'images/company_logos/${team.companyName == "Null" ? "DefaultTeamImage" : team.companyName}.png'),
                    width: circleSize - 20,
                    height: circleSize - 20,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Crown icon
              if (isFirstPlace)
                Positioned(
                  top: -5,
                  child: Icon(
                    Iconsax.crown1,
                    color: crownColor,
                    size: 40.0,
                  ),
                ),
              // Small circle with rank
              Positioned(
                bottom: 7.0, // Adjust this value to position the small circle
                child: Container(
                  width: smallCircleSize,
                  height: smallCircleSize,
                  decoration: BoxDecoration(
                    color: smallCircleColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CustomColors.midnattsblue,
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: smallCircleTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          team.name,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: teamNameColor),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.coin,
              color: teamNameColor,
              size: 12.0,
            ),
            const SizedBox(width: 4.0),
            Text(
              //${totalDonations.toStringAsFixed(0)}
              '${team.fundraiserBox.toStringAsFixed(0)} kr',
              style: TextStyle(fontSize: 14.0, color: teamNameColor),
            ),
          ],
        ),
      ],
    );
  }
}
