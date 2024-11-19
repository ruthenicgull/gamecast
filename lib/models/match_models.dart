// lib/models/match_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum TeamType { home, away }

enum PlayerStatus { starting, substitute }

enum EventType { goal, yellowCard, redCard, substitution, foul }

// Match Model
class Match {
  String matchId;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // live, past, upcoming

  Match({
    required this.matchId,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory Match.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Match(
      matchId: doc.id,
      startTime: (data['start_time'] as Timestamp).toDate(),
      endTime: (data['end_time'] as Timestamp).toDate(),
      status: data['status'] ?? 'upcoming', // Provide default value
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
      'status': status,
    };
  }
}

// Team Model
class Team {
  final String teamId;
  final String teamName;
  final TeamType teamType; // Using enum instead of String
  final List<Player> players;

  Team({
    required this.teamId,
    required this.teamName,
    required this.teamType,
    this.players = const [],
  });

  factory Team.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<dynamic>? playersData = data['players'] as List<dynamic>?;

    return Team(
      teamId: doc.id,
      teamName: data['team_name'] ?? '',
      teamType: TeamType.values.firstWhere(
        (e) => e.toString() == 'TeamType.${data['team_type']}',
        orElse: () => TeamType.home,
      ),
      players: playersData?.map((playerData) {
            // Convert the player data map to Player object
            return Player.fromMap(
              playerData as Map<String, dynamic>,
              playerData['player_id'] ?? '', // Pass the player ID from the map
            );
          }).toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'team_name': teamName,
      'team_type': teamType.name,
      'players': players
          .map((player) => {
                ...player.toFirestore(),
                'player_id':
                    player.playerId, // Include the player ID in the map
              })
          .toList(),
    };
  }
}

// Player Model
class Player {
  final String playerId;
  final String name;
  final int shirtNumber;
  final PlayerStatus status;

  Player({
    required this.playerId,
    required this.name,
    required this.shirtNumber,
    required this.status,
  });

  factory Player.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Player(
      playerId: doc.id,
      name: data['name'] ?? '',
      shirtNumber: data['shirt_number'] ?? 0,
      status: PlayerStatus.values.firstWhere(
        (e) => e.toString() == 'PlayerStatus.${data['status']}',
        orElse: () => PlayerStatus.substitute,
      ),
    );
  }

  factory Player.fromMap(Map<String, dynamic> data, String playerId) {
    return Player(
      playerId: playerId,
      name: data['name'] ?? '',
      shirtNumber: data['shirt_number'] ?? 0,
      status: PlayerStatus.values.firstWhere(
        (e) => e.toString() == 'PlayerStatus.${data['status']}',
        orElse: () => PlayerStatus.substitute,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'shirt_number': shirtNumber,
      'status': status.name, // Use .name to store enum as a string
    };
  }
}

// Score Model
class Score {
  final int homeScore;
  final int awayScore;

  Score({
    required this.homeScore,
    required this.awayScore,
  });

  factory Score.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Score(
      homeScore: data['home_score'],
      awayScore: data['away_score'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'home_score': homeScore,
      'away_score': awayScore,
    };
  }
}

// Event Model
class MatchEvent {
  String? eventId;
  final EventType eventType;
  final int eventMinute;
  final String player1Id;
  final String? player2Id;
  final String teamId;

  MatchEvent({
    this.eventId,
    required this.eventType,
    required this.eventMinute,
    required this.player1Id,
    this.player2Id,
    required this.teamId,
  });

  factory MatchEvent.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MatchEvent(
      eventId: doc.id,
      eventType: EventType.values.firstWhere(
        (e) => e.toString() == 'EventType.${data['event_type']}',
        orElse: () => EventType.foul,
      ),
      eventMinute: data['event_time'],
      player1Id: data['player_1_id'] ?? '',
      player2Id: data['player_2_id'],
      teamId: data['team_id'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'event_type': eventType.name,
      'event_time': eventMinute,
      'player_1_id': player1Id,
      'player_2_id': player2Id,
      'team_id': teamId,
    };
  }
}

// Full Match Data Model (Aggregates all data)
class FullMatchData {
  final Match match;
  final Team homeTeam;
  final Team awayTeam;
  final Score score;
  final List<MatchEvent> events;

  FullMatchData({
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
    required this.score,
    required this.events,
  });

  // Helper methods
  Team getTeamById(String teamId) {
    return teamId == "home" ? homeTeam : awayTeam;
  }

  List<MatchEvent> getTeamEvents(String teamId) {
    return events.where((event) => event.teamId == teamId).toList();
  }

  List<Player> getTeamPlayers(String teamId) {
    return getTeamById(teamId).players;
  }

  factory FullMatchData.fromFirestore({
    required DocumentSnapshot matchDoc,
    required DocumentSnapshot homeTeamDoc,
    required DocumentSnapshot awayTeamDoc,
    required DocumentSnapshot scoreDoc,
    required List<DocumentSnapshot> eventDocs,
  }) {
    return FullMatchData(
      match: Match.fromFirestore(matchDoc),
      homeTeam: Team.fromFirestore(homeTeamDoc),
      awayTeam: Team.fromFirestore(awayTeamDoc),
      score: Score.fromFirestore(scoreDoc),
      events: eventDocs.map((doc) => MatchEvent.fromFirestore(doc)).toList(),
    );
  }
}
