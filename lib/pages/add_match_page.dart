import 'package:flutter/material.dart';
import '../models/match_models.dart';
import '../services/match_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamecast/widgets/add_player_dialog.dart';
import 'package:gamecast/pages/record_events_page.dart';

class AddMatchPage extends StatefulWidget {
  const AddMatchPage({super.key});

  @override
  _AddMatchPageState createState() => _AddMatchPageState();
}

class _AddMatchPageState extends State<AddMatchPage> {
  final _formKey = GlobalKey<FormState>();
  final _matchService = MatchService();
  DateTime? startTime;
  String homeTeamName = '';
  String awayTeamName = '';
  List<Player> homePlayers = [];
  List<Player> awayPlayers = [];
  bool isRecording = false;
  String? currentMatchId;

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          startTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Widget _buildPlayerList(bool isHomeTeam) {
    final players = isHomeTeam ? homePlayers : awayPlayers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHomeTeam ? 'Home Team Players' : 'Away Team Players',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: players.length + 1,
          itemBuilder: (context, index) {
            if (index == players.length) {
              return TextButton(
                onPressed: () => _addPlayer(isHomeTeam),
                child: const Text('Add Player'),
              );
            }
            final player = players[index];
            return ListTile(
              title: Text(player.name),
              subtitle: Text(
                  '${player.shirtNumber} - ${player.status.toString().split('.').last}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    if (isHomeTeam) {
                      homePlayers.removeAt(index);
                    } else {
                      awayPlayers.removeAt(index);
                    }
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _addPlayer(bool isHomeTeam) async {
    final player = await showDialog<Player>(
      context: context,
      builder: (context) => const AddPlayerDialog(),
    );

    if (player != null) {
      setState(() {
        if (isHomeTeam) {
          homePlayers.add(player);
        } else {
          awayPlayers.add(player);
        }
      });
    }
  }

  Future<void> _startMatch() async {
    if (_formKey.currentState!.validate() && startTime != null) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
  
      final match = Match(
        matchId: '', // Will be updated after creation
        startTime: startTime!,
        endTime: startTime!.add(const Duration(hours: 2)), // Default duration
        status: 'live',
      );

      final homeTeam = Team(
        teamId: '', // Will be set by Firestore
        teamName: homeTeamName,
        teamType: TeamType.home,
        players: homePlayers,
      );

      final awayTeam = Team(
        teamId: '', // Will be set by Firestore
        teamName: awayTeamName,
        teamType: TeamType.away,
        players: awayPlayers,
      );

      final score = Score(homeScore: 0, awayScore: 0);

      final fullMatchData = FullMatchData(
        match: match,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        score: score,
        events: [],
      );

      try {
        // Create match and get matchId
        final matchId = await _matchService.createMatch(fullMatchData, userId);
        
        setState(() {
          isRecording = true;
          currentMatchId = matchId; // Set the generated matchId
          match.matchId = matchId; // Update the match object
        });
      } catch (e) {
        print('Error creating match: $e');
        // Optionally show an error dialog to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Match'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(startTime?.toString() ?? 'Select Start Time'),
                onPressed: () => _selectDateTime(context),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Home Team Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                onChanged: (value) => homeTeamName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Away Team Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                onChanged: (value) => awayTeamName = value,
              ),
              const SizedBox(height: 16),
              _buildPlayerList(true),
              const SizedBox(height: 16),
              _buildPlayerList(false),
              const SizedBox(height: 24),
              if (!isRecording)
                OutlinedButton(
                  onPressed: _startMatch,
                  child: const Text('Start Match'),
                )
              else
                Column(
                  children: [
                    const Text('Recording Match Events'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (currentMatchId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecordEventsPage(
                                matchId: currentMatchId!,
                                homeTeamName: homeTeamName,
                                awayTeamName: awayTeamName,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Record Events'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}