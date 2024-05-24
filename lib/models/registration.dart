class RegistrationRequest {
  final String username;
  final String password;
  final String name;
  final String voucherCode;
  final String teamName;
  final String charityName;
  final String donationGoal;
  final bool createNewTeam;

  RegistrationRequest({
    required this.username,
    required this.password,
    required this.name,
    required this.voucherCode,
    required this.teamName,
    required this.charityName,
    required this.donationGoal,
    required this.createNewTeam,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'name': name,
      'voucherCode': voucherCode,
      'teamName': teamName,
      'charityName': charityName,
      'donationGoal': donationGoal,
      'createNewTeam': createNewTeam,
    };
  }
}
