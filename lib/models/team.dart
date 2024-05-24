class Team {
  final String name;
  final double fundraiserBox;
  final String? companyName;

  Team({
    required this.name, 
    required this.fundraiserBox,
    this.companyName,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['name'],
      fundraiserBox: json['fundraiserBox'],
      companyName: json['company'] != null ? json['company']['name'] : null,
    );
  }
}
