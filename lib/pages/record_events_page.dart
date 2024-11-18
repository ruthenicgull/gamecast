// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/match_models.dart';
import '../services/match_service.dart';

class RecordEventsPage extends StatefulWidget {
  final String matchId;
  final String homeTeam;
  final String awayTeam;

  const RecordEventsPage({
    super.key,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  _RecordEventsPageState createState() => _RecordEventsPageState();
}

class _RecordEventsPageState extends State<RecordEventsPage> {
  final _matchService = MatchService();
  final _eventMinuteController = TextEditingController();

  String? _selectedTeam;
  String? _selectedPlayer1;
  String? _selectedPlayer2;
  EventType? _selectedEventType;

  List<String> _homeTeamPlayers = [];
  List<String> _awayTeamPlayers = [];

  @override
  void initState() {
    super.initState();
    _fetchTeamPlayers();
  }

  Future<void> _fetchTeamPlayers() async {
    // In a real app, you'd fetch players from Firestore using the match ID
    // This is a placeholder implementation
    setState(() {
      _homeTeamPlayers = ['Player 1', 'Player 2', 'Player 3'];
      _awayTeamPlayers = ['Player 4', 'Player 5', 'Player 6'];
    });
  }

  void _recordEvent() async {
    if (_validateForm()) {
      // Find the team ID based on the selected team name
      final teamId =
          _selectedTeam == widget.homeTeam ? 'home_team_id' : 'away_team_id';

      final event = MatchEvent(
        eventId: '', // Will be set by Firestore
        eventType: _selectedEventType!,
        eventMinute: int.parse(_eventMinuteController.text),
        player1Id: _selectedPlayer1 ?? '',
        player2Id: _selectedPlayer2,
        teamId: teamId,
      );

      await _matchService.addMatchEvent(widget.matchId, event);

      // Clear form after recording
      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event Recorded Successfully')),
      );
    }
  }

  bool _validateForm() {
    if (_selectedTeam == null) {
      _showValidationError('Please select a team');
      return false;
    }
    if (_selectedEventType == null) {
      _showValidationError('Please select an event type');
      return false;
    }
    if (_eventMinuteController.text.isEmpty) {
      _showValidationError('Please enter the minute');
      return false;
    }
    if (_selectedPlayer1 == null) {
      _showValidationError('Please select the primary player');
      return false;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedTeam = null;
      _selectedPlayer1 = null;
      _selectedPlayer2 = null;
      _selectedEventType = null;
      _eventMinuteController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Match Events'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Team'),
              value: _selectedTeam,
              items: [widget.homeTeam, widget.awayTeam]
                  .map((team) => DropdownMenuItem(
                        value: team,
                        child: Text(team),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedTeam = value;
                // Reset players when team changes
                _selectedPlayer1 = null;
                _selectedPlayer2 = null;
              }),
            ),
            DropdownButtonFormField<EventType>(
              decoration: InputDecoration(labelText: 'Event Type'),
              value: _selectedEventType,
              items: EventType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedEventType = value;
              }),
            ),
            TextFormField(
              controller: _eventMinuteController,
              decoration: const InputDecoration(labelText: 'Minute'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Primary Player'),
              value: _selectedPlayer1,
              items: (_selectedTeam == widget.homeTeam
                      ? _homeTeamPlayers
                      : _awayTeamPlayers)
                  .map<DropdownMenuItem<String>>((player) => DropdownMenuItem(
                        value: player,
                        child: Text(player),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedPlayer1 = value;
              }),
            ),
            // Optional second player for events like substitution
            if (_selectedEventType == EventType.substitution)
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Substitute Player'),
                value: _selectedPlayer2,
                items: (_selectedTeam == widget.homeTeam
                        ? _homeTeamPlayers
                        : _awayTeamPlayers)
                    .map<DropdownMenuItem<String>>((player) => DropdownMenuItem(
                          value: player,
                          child: Text(player),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedPlayer2 = value;
                }),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _recordEvent,
              child: const Text('Record Event'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eventMinuteController.dispose();
    super.dispose();
  }
}
