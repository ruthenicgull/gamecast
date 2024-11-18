import 'package:flutter/material.dart';
import '../models/match_models.dart';

class StatsTab extends StatelessWidget {
  final FullMatchData matchData;

  const StatsTab({Key? key, required this.matchData}) : super(key: key);

  Map<String, Map<String, int>> _calculateStats() {
    final homeStats = {
      'goals': 0,
      'yellowCards': 0,
      'redCards': 0,
      'fouls': 0,
      'substitutions': 0,
    };
    final awayStats = Map<String, int>.from(homeStats);

    for (var event in matchData.events) {
      final stats =
          event.teamId == matchData.homeTeam.teamId ? homeStats : awayStats;
      switch (event.eventType) {
        case EventType.goal:
          stats['goals'] = (stats['goals'] ?? 0) + 1;
          break;
        case EventType.yellowCard:
          stats['yellowCards'] = (stats['yellowCards'] ?? 0) + 1;
          break;
        case EventType.redCard:
          stats['redCards'] = (stats['redCards'] ?? 0) + 1;
          break;
        case EventType.foul:
          stats['fouls'] = (stats['fouls'] ?? 0) + 1;
          break;
        case EventType.substitution:
          stats['substitutions'] = (stats['substitutions'] ?? 0) + 1;
          break;
      }
    }

    return {
      'home': homeStats,
      'away': awayStats,
    };
  }

  Widget _buildStatRow(String label, int homeValue, int awayValue) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              homeValue.toString(),
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              awayValue.toString(),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(matchData.homeTeam.teamName),
              Text(matchData.awayTeam.teamName),
            ],
          ),
          SizedBox(height: 24),
          _buildStatRow(
              'Goals', stats['home']!['goals']!, stats['away']!['goals']!),
          _buildStatRow('Yellow Cards', stats['home']!['yellowCards']!,
              stats['away']!['yellowCards']!),
          _buildStatRow('Red Cards', stats['home']!['redCards']!,
              stats['away']!['redCards']!),
          _buildStatRow(
              'Fouls', stats['home']!['fouls']!, stats['away']!['fouls']!),
          _buildStatRow('Substitutions', stats['home']!['substitutions']!,
              stats['away']!['substitutions']!),
        ],
      ),
    );
  }
}
