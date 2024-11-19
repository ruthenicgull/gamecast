// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../models/match_models.dart';
// import '../pages/record_events_page.dart'; // Add import for RecordEventsPage

// class EventsTab extends StatelessWidget {
//   final FullMatchData matchData;

//   const EventsTab({super.key, required this.matchData});

//   String _getEventDescription(MatchEvent event) {
//     final team = matchData.getTeamById(event.teamId);
//     final player1 = team.players.firstWhere((p) => p.name == event.player1Id);
//     String description = '';

//     switch (event.eventType) {
//       case EventType.goal:
//         description = '⚽ ${player1.name} scores for ${team.teamName}';
//         break;
//       case EventType.yellowCard:
//         description = '🟨 ${player1.name} receives a yellow card';
//         break;
//       case EventType.redCard:
//         description = '🟥 ${player1.name} receives a red card';
//         break;
//       case EventType.foul:
//         description = '🤚 Foul by ${player1.name}';
//         break;
//       case EventType.substitution:
//         if (event.player2Id != null) {
//           final player2 =
//               team.players.firstWhere((p) => p.playerId == event.player2Id);
//           description = '🔄 ${player1.name} replaces ${player2.name}';
//         }
//         break;
//     }

//     return description;
//   }

//   void _endMatch() async {
//     // Set the status of the match to "over"
//     Match updatedMatch = matchData.match.copyWith(status: 'over');

//     // Assuming you have a method to update the match data in Firebase
//     await FirebaseFirestore.instance
//         .collection('matches') // Your collection name
//         .doc(updatedMatch.matchId) // Match document ID
//         .update({
//       'status': 'over',
//     });

//     // Optionally, you can show a confirmation or navigate away after updating
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Match ended')),
//     );

//     // Navigate back or replace the page if needed
//     Navigator.pop(context); // To return to the previous page
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sortedEvents = List<MatchEvent>.from(matchData.events)
//       ..sort((a, b) => b.eventMinute.compareTo(a.eventMinute));

//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ElevatedButton(
//             onPressed: () {
//               // Navigate to RecordEventsPage
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => RecordEventsPage(
//                     matchId: matchData.match.matchId,
//                     homeTeamName: matchData.homeTeam.teamName,
//                     awayTeamName: matchData.awayTeam.teamName,
//                     initialMatchData: matchData,
//                   ),
//                 ),
//               );
//             },
//             child: const Text('Add Event'),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: ElevatedButton(
//             onPressed: _endMatch,
//             child: const Text('End Event'),
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             itemCount: sortedEvents.length,
//             itemBuilder: (context, index) {
//               final event = sortedEvents[index];
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     child: Text('${event.eventMinute}\''),
//                   ),
//                   title: Text(_getEventDescription(event)),
//                   subtitle: Text(matchData.getTeamById(event.teamId).teamName),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/match_models.dart';
import '../pages/record_events_page.dart'; // Add import for RecordEventsPage

class EventsTab extends StatelessWidget {
  final FullMatchData matchData;

  const EventsTab({super.key, required this.matchData});

  String _getEventDescription(MatchEvent event) {
    final team = matchData.getTeamById(event.teamId);
    final player1 = team.players.firstWhere((p) => p.name == event.player1Id);
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

  void _endMatch(BuildContext context) async {
    // Create a new Match object with the status set to 'over'

    // Update the match data in Firebase
    await FirebaseFirestore.instance
        .collection('matches') // Your collection name
        .doc(matchData.match.matchId) // Match document ID
        .set({
      'status': 'over',
    });

    // Optionally, you can show a confirmation or navigate away after updating
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Match ended')),
    );

    // Navigate back or replace the page if needed
    Navigator.pop(context); // To return to the previous page
  }

  @override
  Widget build(BuildContext context) {
    final sortedEvents = List<MatchEvent>.from(matchData.events)
      ..sort((a, b) => b.eventMinute.compareTo(a.eventMinute));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              // Navigate to RecordEventsPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecordEventsPage(
                    matchId: matchData.match.matchId,
                    homeTeamName: matchData.homeTeam.teamName,
                    awayTeamName: matchData.awayTeam.teamName,
                    initialMatchData: matchData,
                  ),
                ),
              );
            },
            child: const Text('Add Event'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => _endMatch(context), // Pass context to _endMatch
            child: const Text('End Match'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedEvents.length,
            itemBuilder: (context, index) {
              final event = sortedEvents[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${event.eventMinute}\''),
                  ),
                  title: Text(_getEventDescription(event)),
                  subtitle: Text(matchData.getTeamById(event.teamId).teamName),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
