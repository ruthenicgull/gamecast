import 'package:flutter/material.dart';
import '../models/match_models.dart';

class MatchCard extends StatelessWidget {
  final FullMatchData matchData;
  final VoidCallback onTap;

  const MatchCard({
    Key? key,
    required this.matchData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    matchData.match.startTime.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: matchData.match.status == 'live'
                          ? Colors.green
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      matchData.match.status,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
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
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${matchData.score.homeScore} - ${matchData.score.awayScore}',
                      style: TextStyle(
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
            ],
          ),
        ),
      ),
    );
  }
}
