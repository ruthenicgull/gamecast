import 'package:flutter/material.dart';
import '../models/match_models.dart';

class LineupsTab extends StatelessWidget {
  final FullMatchData matchData;

  const LineupsTab({super.key, required this.matchData});

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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Starting Lineup',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
        const SizedBox(height: 16),
        const Text(
          'Substitutes',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTeamLineup(matchData.homeTeam),
          const Divider(height: 32),
          _buildTeamLineup(matchData.awayTeam),
        ],
      ),
    );
  }
}
