class Match {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final DateTime matchDateTime;
  final List<dynamic> events;

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchDateTime,
    required this.events,
  });

  // Modify fromMap to accept an id parameter
  factory Match.fromMap(Map<String, dynamic> map, {required String id}) {
    return Match(
      id: id, // Use the provided document ID
      homeTeam: map['home'],
      awayTeam: map['away'],
      matchDateTime: DateTime.parse(map['matchDateTime']),
      events: List.from(map['events']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'home': homeTeam,
      'away': awayTeam,
      'matchDateTime': matchDateTime.toIso8601String(),
      'events': events,
    };
  }
}
