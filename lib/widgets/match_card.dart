import 'package:flutter/material.dart';
import '../models/match_models.dart';
import '../services/EventBasedPredictor.dart';

class MatchCard extends StatelessWidget {
  final FullMatchData matchData;
  final MatchPrediction? prediction; // Add prediction parameter
  final VoidCallback onTap;

  const MatchCard({
    super.key,
    required this.matchData,
    this.prediction, // Accept prediction
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Match Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    matchData.match.startTime.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: matchData.match.status == 'live'
                          ? Colors.green
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      matchData.match.status,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Teams and Score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      matchData.homeTeam.teamName,
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${matchData.score.homeScore} - ${matchData.score.awayScore}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(matchData.awayTeam.teamName),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Predictions (if available)
              if (prediction != null) ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPredictionColumn(
                      context,
                      'Home Win',
                      prediction!.homeWinProbability,
                      Colors.blue,
                    ),
                    _buildPredictionColumn(
                      context,
                      'Draw',
                      prediction!.drawProbability,
                      Colors.orange,
                    ),
                    _buildPredictionColumn(
                      context,
                      'Away Win',
                      prediction!.awayWinProbability,
                      Colors.red,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionColumn(
    BuildContext context,
    String label,
    double probability,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(probability * 100).toStringAsFixed(2)}%',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
