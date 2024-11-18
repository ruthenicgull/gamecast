import 'package:flutter/material.dart';
import '../models/match_models.dart';

class LineupsTab extends StatelessWidget {
  final FullMatchData matchData;

  const LineupsTab({Key? key, required this.matchData}) : super(key: key);

  Widget _buildTeamLineup(Team team) {
    final startingPlayers =
        team.players.where((p) => p.status == PlayerStatus.starting).toList();
    final substitutes =
        team.players.where((p) => p.status == PlayerStatus.substitute).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          team.teamName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Starting Lineup',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: startingPlayers.length,
          itemBuilder: (context, index) {
            final player = startingPlayers[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(player.shirtNumber.toString()),
              ),
              title: Text(player.name),
            );
          },
        ),
        SizedBox(height: 16),
        Text(
          'Substitutes',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: substitutes.length,
          itemBuilder: (context, index) {
            final player = substitutes[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(player.shirtNumber.toString()),
              ),
              title: Text(player.name),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTeamLineup(matchData.homeTeam),
          Divider(height: 32),
          _buildTeamLineup(matchData.awayTeam),
        ],
      ),
    );
  }
}
