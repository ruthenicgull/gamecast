import 'package:flutter/material.dart';
import '../models/match_models.dart';

class EventsTab extends StatelessWidget {
  final FullMatchData matchData;

  const EventsTab({Key? key, required this.matchData}) : super(key: key);

  String _getEventDescription(MatchEvent event) {
    final team = matchData.getTeamById(event.teamId);
    final player1 =
        team.players.firstWhere((p) => p.playerId == event.player1Id);
    String description = '';

    switch (event.eventType) {
      case EventType.goal:
        description = '⚽ ${player1.name} scores for ${team.teamName}';
        break;
      case EventType.yellowCard:
        description = '🟨 ${player1.name} receives a yellow card';
        break;
      case EventType.redCard:
        description = '🟥 ${player1.name} receives a red card';
        break;
      case EventType.foul:
        description = '🤚 Foul by ${player1.name}';
        break;
      case EventType.substitution:
        if (event.player2Id != null) {
          final player2 =
              team.players.firstWhere((p) => p.playerId == event.player2Id);
          description = '🔄 ${player1.name} replaces ${player2.name}';
        }
        break;
    }

    return description;
  }

  @override
  Widget build(BuildContext context) {
    final sortedEvents = List<MatchEvent>.from(matchData.events)
      ..sort((a, b) => b.eventMinute.compareTo(a.eventMinute));

    return ListView.builder(
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${event.eventMinute}\''),
            ),
            title: Text(_getEventDescription(event)),
            subtitle: Text(matchData.getTeamById(event.teamId).teamName),
          ),
        );
      },
    );
  }
}
