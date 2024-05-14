import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiUtils {
  static Future<double> fetchDonations(String? username) async {
    try {
      var response = await http.get(Uri.parse(
          'https://group-15-7.pvt.dsv.su.se/app/team/$username/donatedAmount'));

      if (response.statusCode == 200) {
        double donations = double.parse(response.body);
        return donations;
      } else {
        throw Exception('Failed to fetch donations');
      }
    } catch (e) {
      print('Error fetching donations: $e');
      rethrow; // Rethrow the exception to handle it in the calling code
    }
  }

  static Future<double> fetchGoal(String? username) async {
    try {
      var response = await http.get(Uri.parse(
          'https://group-15-7.pvt.dsv.su.se/app/team/$username/donationGoal'));

      if (response.statusCode == 200) {
        double goal = double.parse(response.body);
        return goal;
      } else {
        throw Exception('Failed to fetch goal');
      }
    } catch (e) {
      print('Error fetching goal: $e');
      rethrow; // Rethrow the exception to handle it in the calling code
    }
  }

  static Future<String?> fetchTeamName(String? username) async {
    try {
      var response = await http.get(
          Uri.parse('https://group-15-7.pvt.dsv.su.se/app/user/$username'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['teamName'];
      } else {
        throw Exception('Failed to fetch team name');
      }
    } catch (e) {
      print('Error fetching team name: $e');
      rethrow; // Rethrow the exception to handle it in the calling code
    }
  }

  static Future<String?> fetchCompanyName(String? username) async {
    try {
      var response = await http.get(
          Uri.parse('https://group-15-7.pvt.dsv.su.se/app/user/$username'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['companyName'];
      } else {
        throw Exception('Failed to fetch company name');
      }
    } catch (e) {
      print('Error fetching company name: $e');
      rethrow; // Rethrow the exception to handle it in the calling code
    }
  }

  static Future<String?> fetchCharityName(String? username) async {
    try {
      var response = await http.get(
          Uri.parse('https://group-15-7.pvt.dsv.su.se/app/user/$username'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['charityName'];
      } else {
        throw Exception('Failed to fetch charity name');
      }
    } catch (e) {
      print('Error fetching charity name: $e');
      rethrow; // Rethrow the exception to handle it in the calling code
    }
  }

  static Future<int?> fetchFundraiserBox(String? username) async {
    try {
      var response = await http.get(
          Uri.parse('https://group-15-7.pvt.dsv.su.se/app/team/$username'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['fundraiserBox'];
      } else {
        throw Exception('Failed to fetch fundraiser box');
      }
    } catch (e) {
      print('Error fetching fundraiser box: $e');
      rethrow; // Rethrow the exception to handle it in the calling code
    }
  }

  static Future<List<String>?> fetchMembers(String? username) async {
    try {
      var response = await http.get(
          Uri.parse('https://group-15-7.pvt.dsv.su.se/app/team/$username'));

      if (response.statusCode == 200) {
        return List<String>.from(jsonDecode(response.body)['members']);
      } else {
        throw Exception('Failed to fetch members');
      }
    } catch (e) {
      print('Error fetching members: $e');
      rethrow; // Rethrow the exception to handle it in the calling code
    }
  }

  static Future<String?> fetchChallengeStatus(String? username) async {
    try {
      var response = await http.get(Uri.parse(
          'https://group-15-7.pvt.dsv.su.se/app/$username/challenge'));

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        var challengeStatus = responseData['status'];
        return challengeStatus;
      } else {
        throw Exception('Failed to fetch challenge status');
      }
    } catch (e) {
      print('Error fetching challenge status: $e');
      rethrow;
    }
  }
}
