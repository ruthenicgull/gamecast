import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/match_models.dart';
import '../pages/record_events_page.dart';

class EventsTab extends StatefulWidget {
  final FullMatchData matchData;

  const EventsTab({super.key, required this.matchData});

  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  bool _canEditMatch = false;
  bool _isLoading = true;
  bool _isAddingEvent = false; // Track if an event is being added

  @override
  void initState() {
    super.initState();
    _checkUserAccess();
  }

  Future<void> _checkUserAccess() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _canEditMatch = false;
        _isLoading = false;
      });
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('userToMatches')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      final List<dynamic> matchIds = userDoc.data()?['matchIds'] ?? [];
      setState(() {
        _canEditMatch = matchIds.contains(widget.matchData.match.matchId);
        _isLoading = false;
      });
    } else {
      setState(() {
        _canEditMatch = false;
        _isLoading = false;
      });
    }
  }

  void _endMatch(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(widget.matchData.match.matchId)
        .update({
      'status': 'over',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Match ended')),
    );

    Navigator.pop(context);
  }

  String _getEventDescription(MatchEvent event) {
    final team = widget.matchData.getTeamById(event.teamId);
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
              team.players.firstWhere((p) => p.name == event.player2Id);
          description = '🔄 ${player1.name} replaces ${player2.name}';
        }
        break;
    }

    return description;
  }

  // Method to handle event addition with loading state
  void _addEvent() async {
    setState(() {
      _isAddingEvent = true; // Show loading indicator
    });

    // Simulate a delay for event addition (use real event addition logic here)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isAddingEvent = false; // Hide loading indicator once done
    });

    // Navigate to RecordEventsPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordEventsPage(
          matchId: widget.matchData.match.matchId,
          homeTeamName: widget.matchData.homeTeam.teamName,
          awayTeamName: widget.matchData.awayTeam.teamName,
          initialMatchData: widget.matchData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedEvents = List<MatchEvent>.from(widget.matchData.events)
      ..sort((a, b) => b.eventMinute.compareTo(a.eventMinute));

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (_canEditMatch)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isAddingEvent
                  ? null
                  : _addEvent, // Disable button while adding
              child: _isAddingEvent
                  ? const CircularProgressIndicator()
                  : const Text('Add Event'),
            ),
          ),
        if (_canEditMatch)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _endMatch(context),
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
                  subtitle:
                      Text(widget.matchData.getTeamById(event.teamId).teamName),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
