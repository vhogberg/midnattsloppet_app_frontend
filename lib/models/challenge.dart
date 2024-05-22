class Challenge {
  final String title;
  final String description;
  final String challengerName;
  final String challengedName;
  final String status;

  Challenge({
    required this.title,
    required this.description,
    required this.challengerName,
    required this.challengedName,
    required this.status,
  });

    factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      title: json['title'],
      description: json['description'],
      challengerName: json['challengerName'],
      challengedName: json['challengedName'],
      status: json['status'],
    );
  }

  @override
  String toString() {
    return 'Challenge(title: $title, description: $description, challengerName: $challengerName, challengedName: $challengedName, status: $status)';
  }
}