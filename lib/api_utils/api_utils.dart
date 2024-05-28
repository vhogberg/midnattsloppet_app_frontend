// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter_application/models/challenge.dart';
import 'package:flutter_application/models/team.dart';
import 'package:http/http.dart' as http;

class ApiUtils {
  static const String _apiKeyHeader = 'X-API-KEY';
  static const String _apiKey =
      '8292EB40F91DCF46950913B1ECC1AB22ED3F7C7491186059D7FAF71D161D791F';
  static const String baseURL = 'https://group-15-7.pvt.dsv.su.se/app';

  static Future<http.Response> get(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {_apiKeyHeader: _apiKey},
      );
      return response;
    } catch (e) {
      print("Error making GET request to $url: $e");
      rethrow;
    }
  }

  static Future<http.Response> post(String url, dynamic body) async {
    return await http.post(
      Uri.parse(url),
      headers: {
        _apiKeyHeader: _apiKey,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: utf8.encode(jsonEncode(body)),
    );
  }

  static Future<bool> doesUserExist(String username) async {
    final url = Uri.parse('$baseURL/userExists/$username');

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as bool;
      } else {
        throw Exception('Failed to check user existence');
      }
    } catch (e) {
      throw Exception('Failed to check user existence: $e');
    }
  }

  static Future<bool> doesTeamNameExist(String teamName) async {
    final url = Uri.parse('$baseURL/teamExists/$teamName');

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as bool;
      } else {
        throw Exception('Failed to check team existence');
      }
    } catch (e) {
      throw Exception('Failed to check team existence: $e');
    }
  }

  static Future<String?> getCompanyNameByVoucherCode(String voucherCode) async {
    final url = Uri.parse('$baseURL/company/$voucherCode');
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        return response.body.isNotEmpty ? response.body : null;
      } else {
        throw Exception('Failed to fetch company name');
      }
    } catch (e) {
      throw Exception('Failed to fetch company name: $e');
    }
  }

  static Future<http.Response> acceptChallenge(
      String username, String challengingTeamName) async {
    final url = '$baseURL/$username/acceptchallenge';
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      _apiKeyHeader: _apiKey,
    };

    final body = jsonEncode({'challengingTeamName': challengingTeamName});

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to send request: $e');
    }
  }

  static Future<http.Response> declineChallenge(
      String username, String challengingTeamName) async {
    final url = '$baseURL/$username/declinechallenge';
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      _apiKeyHeader: _apiKey,
    };

    final body = jsonEncode({'challengingTeamName': challengingTeamName});

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to send request: $e');
    }
  }

  static Future<http.Response> takeBackChallenge(String username) async {
    final url = '$baseURL/$username/take-back-challenge';
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      _apiKeyHeader: _apiKey,
    };

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to send request: $e');
    }
  }

  static Future<http.Response> editChallengeDescription(
      String username, String description) async {
    final url = '$baseURL/$username/challenge/update-description';
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      _apiKeyHeader: _apiKey,
    };
    final body = jsonEncode({'description': description});

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to update description: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send request: $e');
    }
  }

  static Future<http.Response> logout(String url,
      {Map<String, String>? headers, dynamic body}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to send request: $e');
    }
  }

  static Map<String, String> _buildHeaders(
      Map<String, String>? additionalHeaders) {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      _apiKeyHeader: _apiKey,
    };
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  static Future<List<String>> fetchCharities() async {
    final response = await http.get(
      Uri.parse('$baseURL/all/charities'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load charities from API');
    }
  }

  static Future<String?> fetchCompanyNameByUsername(String username) async {
    final response = await http.get(
      Uri.parse('$baseURL/user/$username'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes));

      // Extract company name from JSON response
      if (data.containsKey('company') &&
          data['company'] is Map<String, dynamic>) {
        final companyData = data['company'] as Map<String, dynamic>;
        if (companyData.containsKey('name')) {
          return companyData['name'] as String?;
        }
      }
    } else {
      throw Exception('Failed to load user from API');
    }
    return null;
  }

  static Future<void> registerTeam(String username, String teamName,
      String charityName, String donationGoal) async {
    const String url = '$baseURL/register/profile/register/team';

    Map<String, String> requestBody = {
      'username': username,
      'teamName': teamName,
      'charityName': charityName,
      'donationGoal': donationGoal,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to register team: ${response.statusCode} ${response.body}');
    }
  }

  static Future<List<String>> fetchTeams() async {
    final response = await http.get(
      Uri.parse('$baseURL/all/teams'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load teams from API');
    }
  }

  static Future<List<String>> fetchChallengeableTeams(String username) async {
    final response = await http.get(
      Uri.parse('$baseURL/all/challengeable-teams/$username'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load teams from API');
    }
  }

  static Future<List<String>> fetchTeamsByCompany(String companyName) async {
    final response = await http.get(
      Uri.parse('$baseURL/all/teams/$companyName'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<String>.from(data);
    } else {
      throw Exception('Failed to load teams from API');
    }
  }

  static Future<void> joinTeam(String username, String teamName) async {
    const String url = '$baseURL/register/profile/join/team';

    Map<String, String> requestBody = {
      'username': username,
      'teamName': teamName,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to join team: ${response.statusCode} ${response.body}');
    }
  }

  static Future<double> fetchDonations(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username/donatedAmount'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        double donations = double.parse(response.body);
        return donations;
      } else {
        throw Exception('Failed to fetch donations');
      }
    } catch (e) {
      print('Error fetching donations: $e');
      rethrow;
    }
  }

  static Future<double> fetchGoal(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username/donationGoal'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        double goal = double.parse(response.body);
        return goal;
      } else {
        throw Exception('Failed to fetch goal');
      }
    } catch (e) {
      print('Error fetching goal: $e');
      rethrow;
    }
  }

  static Future<String?> fetchTeamName(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['name'];
      } else {
        throw Exception('Failed to fetch team name');
      }
    } catch (e) {
      print('Error fetching team name: $e');
      rethrow;
    }
  }

  static Future<String?> fetchCompanyName(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['company']['name'];
      } else {
        throw Exception('Failed to fetch company name');
      }
    } catch (e) {
      print('Error fetching company name: $e');
      rethrow;
    }
  }

  static Future<String?> fetchCharityName(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['charityOrganization']['name'];
      } else {
        throw Exception('Failed to fetch charity name');
      }
    } catch (e) {
      print('Error fetching charity name: $e');
      rethrow;
    }
  }

  static Future<double?> fetchFundraiserBox(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['fundraiserBox'];
      } else {
        throw Exception('Failed to fetch fundraiser box');
      }
    } catch (e) {
      print('Error fetching fundraiser box: $e');
      rethrow;
    }
  }

  static Future<List<String>?> fetchMembers(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/team/$username'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> membersData = data['members'];
        List<String> members =
            membersData.map((member) => member['name'].toString()).toList();
        return members;
      } else {
        throw Exception('Failed to fetch members');
      }
    } catch (e) {
      print('Error fetching members: $e');
      rethrow;
    }
  }

  static Future<List<String>> fetchChallengeStatus(String? username) async {
    try {
      var response = await http.get(
        Uri.parse('$baseURL/$username/challenge'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));

        List<String> challengeStatuses = responseData
            .map((challenge) => challenge['status'].toString())
            .toList();

        return challengeStatuses;
      } else {
        throw Exception('Failed to fetch challenge status');
      }
    } catch (e) {
      print('Error fetching challenge status: $e');
      rethrow;
    }
  }

  // Method for challenge_page to fetch activity
  static Future<List<Challenge>> fetchChallengeActivity(
      String? username) async {
    if (username == null) {
      throw Exception('Username cannot be null');
    }

    final response = await http.get(
      Uri.parse('$baseURL/$username/challenge'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
    );

    /* String title;
    String description;
    String challengerName;
    String challengedName;
    String status; */

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      List<Challenge> fetchedChallenges = [];

      for (var item in data) {
        String title = item['name'];
        String description = item['description'];
        String challengerName = item['challengerName'];
        String challengedName = item['challengedName'];
        String status = item['status'];

        fetchedChallenges.add(Challenge(
          title: title,
          description: description,
          challengerName: challengerName,
          challengedName: challengedName,
          status: status,
        ));
      }
      return fetchedChallenges;
    } else {
      throw Exception('Failed to load teams from API');
    }
  }

  // Method for challenge_page to fetch activity
  static Future<List<Challenge>> fetchActiveChallenge(String? username) async {
    if (username == null) {
      throw Exception('Username cannot be null');
    }

    final response = await http.get(
      Uri.parse('$baseURL/$username/challenge'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      List<Challenge> fetchedChallenges = [];

      for (var item in data) {
        String title = item['name'];
        String description = item['description'];
        String challengerName = item['challengerName'];
        String challengedName = item['challengedName'];
        String status = item['status'];

        fetchedChallenges.add(Challenge(
          title: title,
          description: description,
          challengerName: challengerName,
          challengedName: challengedName,
          status: status,
        ));
      }
      return fetchedChallenges;
    } else {
      throw Exception('Failed to load teams from API');
    }
  }

  static Future<List<Team>> fetchTeamsWithBoxAndCompanyName() async {
    final response = await http.get(
      Uri.parse('$baseURL/all/teamswithbox'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        _apiKeyHeader: _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      List<Team> fetchedTeams = [];

      for (var item in data) {
        String name = item['name'];
        double fundraiserBox = item['fundraiserBox'];
        String? companyName;

        if (item['company'] != null) {
          companyName = item['company']['name'];
        }

        fetchedTeams.add(Team(
          name: name,
          fundraiserBox: fundraiserBox,
          companyName: companyName,
        ));
      }

      List<Team> sortTeams(List<Team> teams) {
        teams.sort((a, b) => b.fundraiserBox.compareTo(a.fundraiserBox));
        return teams;
      }

      List<Team> sortedTeams = sortTeams(fetchedTeams);

      return sortedTeams;
    } else {
      throw Exception('Failed to load teams from API');
    }
  }

  //getters för otherteampage som tar info baserat på lagnamn ist. för username
  static const String baseUrl =
      'https://group-15-7.pvt.dsv.su.se/app/team/byTeamName/';

  static Future<String?> fetchOtherTeamName(String teamName) async {
    final String url = '$baseUrl$teamName';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        return data['name'];
      } else {
        throw Exception(
            'Failed to fetch team name: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching team name: $e');
      return null;
    }
  }

  static Future<double?> fetchOtherDonationGoal(String teamName) async {
    final String url = '$baseUrl$teamName';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        return data['donationGoal'];
      } else {
        throw Exception(
            'Failed to fetch donation goal: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching donation goal: $e');
      return null;
    }
  }

  static Future<double?> fetchOtherFundraiserBox(String teamName) async {
    final String url = '$baseUrl$teamName';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        return data['fundraiserBox'];
      } else {
        throw Exception(
            'Failed to fetch fundraiser box: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching fundraiser box: $e');
      return null;
    }
  }

  static Future<String?> fetchOtherCharityOrganization(String teamName) async {
    final String url = '$baseUrl$teamName';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        return data['charityOrganization']['name'];
      } else {
        throw Exception(
            'Failed to fetch charity organization: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching charity organization: $e');
      return null;
    }
  }

  static Future<String?> fetchOtherCompanyName(String teamName) async {
    final String url = '$baseUrl$teamName';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        return data['company']['name'];
      } else {
        throw Exception(
            'Failed to fetch company name: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching company name: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> fetchOtherMembers(String teamName) async {
    final String url = '$baseUrl$teamName';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          _apiKeyHeader: _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes));
        return data['members'];
      } else {
        throw Exception(
            'Failed to fetch team members: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching team members: $e');
      return null;
    }
  }
}

enum ChallengeStatus { pending, accepted, completed }

extension ChallengeStatusExtension on String {
  ChallengeStatus toChallengeStatus() {
    switch (toUpperCase()) {
      case 'PENDING':
        return ChallengeStatus.pending;
      case 'ACCEPTED':
        return ChallengeStatus.accepted;
      default:
        return ChallengeStatus.completed;
    }
  }
}
