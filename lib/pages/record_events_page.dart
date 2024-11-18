import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/match_models.dart';
import '../services/match_service.dart';

class RecordEventsPage extends StatefulWidget {
  final String matchId;
  final String homeTeamName;
  final String awayTeamName;

  const RecordEventsPage({
    super.key,
    required this.matchId,
    required this.homeTeamName,
    required this.awayTeamName,
  });

  @override
  _RecordEventsPageState createState() => _RecordEventsPageState();
}

class _RecordEventsPageState extends State<RecordEventsPage> {
  final MatchService _matchService = MatchService();
  final TextEditingController _eventMinuteController = TextEditingController();

  String? _selectedTeamName;
  String? _selectedPlayer1;
  String? _selectedPlayer2;
  EventType? _selectedEventType;

  List<Player> _homeTeamPlayers = [];
  List<Player> _awayTeamPlayers = [];
  Team? _homeTeam;
  Team? _awayTeam;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeamsAndPlayers();
  }

  Future<void> _loadTeamsAndPlayers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final matchRef =
          FirebaseFirestore.instance.collection('matches').doc(widget.matchId);

      final homeTeamDoc = await matchRef.collection('teams').doc('home').get();
      final awayTeamDoc = await matchRef.collection('teams').doc('away').get();

      if (!homeTeamDoc.exists || !awayTeamDoc.exists) {
        throw Exception("Teams not found");
      }

      final homePlayersSnapshot = await matchRef
          .collection('teams')
          .doc('home')
          .collection('players')
          .get();

      final awayPlayersSnapshot = await matchRef
          .collection('teams')
          .doc('away')
          .collection('players')
          .get();

      final homePlayers = homePlayersSnapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();

      final awayPlayers = awayPlayersSnapshot.docs
          .map((doc) => Player.fromFirestore(doc))
          .toList();

      final homeTeam = Team(
        teamId: homeTeamDoc.id,
        teamName: homeTeamDoc.data()?['team_name'] ?? '',
        teamType: TeamType.home,
        players: homePlayers,
      );

      final awayTeam = Team(
        teamId: awayTeamDoc.id,
        teamName: awayTeamDoc.data()?['team_name'] ?? '',
        teamType: TeamType.away,
        players: awayPlayers,
      );

      setState(() {
        _homeTeam = homeTeam;
        _awayTeam = awayTeam;
        _homeTeamPlayers = homePlayers;
        _awayTeamPlayers = awayPlayers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackbar('Error loading players: $e', isError: true);
    }
  }

  List<String> _getAvailablePlayers() {
    _loadTeamsAndPlayers();
    if (_selectedTeamName == null) return [];
    print("match id ${widget.matchId}");
    print("TEAM NAME: $_selectedTeamName");
    print(widget.homeTeamName);
    final players = _selectedTeamName == widget.homeTeamName
        ? _homeTeamPlayers
        : _awayTeamPlayers;

    print("Players: $players");
    return players.map((player) => player.name).toList();
  }

  Future<void> _recordEvent() async {
    if (_validateForm()) {
      try {
        final selectedTeam =
            _selectedTeamName == widget.homeTeamName ? _homeTeam! : _awayTeam!;

        final player1 = _getPlayerByName(_selectedPlayer1!);
        final player2 = _selectedPlayer2 != null
            ? _getPlayerByName(_selectedPlayer2!)
            : null;

        final event = MatchEvent(
          eventId: '', // Firestore will generate this
          eventType: _selectedEventType!,
          eventMinute: int.parse(_eventMinuteController.text),
          player1Id: player1.playerId,
          player2Id: player2?.playerId,
          teamId: selectedTeam.teamId,
        );

        await _matchService.addMatchEvent(widget.matchId, event);

        _resetForm();
        _showSnackbar('Event recorded successfully');
      } catch (e) {
        _showSnackbar('Error recording event: $e', isError: true);
      }
    }
  }

  Player _getPlayerByName(String playerName) {
    final players = _selectedTeamName == widget.homeTeamName
        ? _homeTeamPlayers
        : _awayTeamPlayers;

    return players.firstWhere(
      (player) => player.name == playerName,
      orElse: () => throw Exception('Player not found'),
    );
  }

  bool _validateForm() {
    if (_selectedTeamName == null) {
      _showSnackbar('Please select a team', isError: true);
      return false;
    }
    if (_selectedEventType == null) {
      _showSnackbar('Please select an event type', isError: true);
      return false;
    }
    if (_eventMinuteController.text.isEmpty) {
      _showSnackbar('Please enter the event minute', isError: true);
      return false;
    }
    if (_selectedPlayer1 == null) {
      _showSnackbar('Please select the primary player', isError: true);
      return false;
    }
    if (_selectedEventType == EventType.substitution &&
        _selectedPlayer2 == null) {
      _showSnackbar('Please select the substitute player', isError: true);
      return false;
    }
    return true;
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedTeamName = null;
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
            _buildDropdown<String>(
              label: 'Team',
              value: _selectedTeamName,
              items: [widget.homeTeamName, widget.awayTeamName],
              onChanged: (value) => setState(() {
                _selectedTeamName = value;
                _selectedPlayer1 = null;
                _selectedPlayer2 = null;
              }),
            ),
            _buildEventTypeDropdown(),
            TextFormField(
              controller: _eventMinuteController,
              decoration: const InputDecoration(labelText: 'Minute'),
              keyboardType: TextInputType.number,
            ),
            if (_selectedTeamName != null)
              _buildDropdown<String>(
                label: 'Primary Player',
                value: _selectedPlayer1,
                items: _getAvailablePlayers(),
                onChanged: (value) => setState(() {
                  _selectedPlayer1 = value;
                }),
              ),
            if (_selectedTeamName != null &&
                _selectedEventType == EventType.substitution)
              _buildDropdown<String>(
                label: 'Substitute Player',
                value: _selectedPlayer2,
                items: _getAvailablePlayers(),
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

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(labelText: label),
      value: value,
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(item.toString()),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildEventTypeDropdown() {
    Map<EventType, String> eventTypeNames = {
      EventType.goal: 'Goal',
      EventType.yellowCard: 'Yellow Card',
      EventType.redCard: 'Red Card',
      EventType.substitution: 'Substitution',
      EventType.foul: 'Foul',
    };

    return DropdownButtonFormField<EventType>(
      decoration: const InputDecoration(labelText: 'Event Type'),
      value: _selectedEventType,
      items: EventType.values.map((type) {
        return DropdownMenuItem<EventType>(
          value: type,
          child: Text(eventTypeNames[type] ?? ''),
        );
      }).toList(),
      onChanged: (value) => setState(() {
        _selectedEventType = value;
      }),
    );
  }

  @override
  void dispose() {
    _eventMinuteController.dispose();
    super.dispose();
  }
}
