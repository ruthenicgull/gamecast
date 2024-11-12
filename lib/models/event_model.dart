class MatchEvent {
  final String eventType;
  final int time;
  final List<String>? players; // List of players involved if applicable
  final String team; // Team involved in the event (Home or Away)

  MatchEvent({
    required this.eventType,
    required this.time,
    required this.team, // Required team field
    this.players,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventType': eventType,
      'time': time,
      'players': players,
      'team': team, // Include team in map
    };
  }

  static MatchEvent fromMap(Map<String, dynamic> map) {
    return MatchEvent(
      eventType: map['eventType'],
      time: map['time'],
      team: map['team'], // Extract team from map
      players: List<String>.from(map['players'] ?? []),
    );
  }
}
