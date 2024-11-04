class Match {
  final String team1;
  final String team2;
  final int score1;
  final int score2;
  final String status;
  final DateTime startTime;

  Match({
    required this.team1,
    required this.team2,
    required this.score1,
    required this.score2,
    required this.status,
    required this.startTime,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      team1: json['team1'],
      team2: json['team2'],
      score1: json['score1'],
      score2: json['score2'],
      status: json['status'],
      startTime: DateTime.parse(json['startTime']),
    );
  }
}
