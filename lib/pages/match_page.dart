import 'package:flutter/material.dart';
import '../models/match_models.dart';
import '../widgets/match_header.dart';
import '../widgets/lineups_tab.dart';
import '../widgets/stats_tab.dart';
import '../widgets/events_tab.dart';

class MatchPage extends StatelessWidget {
  final FullMatchData matchData;

  const MatchPage({super.key, required this.matchData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
      ),
      body: Column(
        children: [
          MatchHeader(matchData: matchData),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Lineups'),
                      Tab(text: 'Stats'),
                      Tab(text: 'Events'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        LineupsTab(matchData: matchData),
                        StatsTab(matchData: matchData),
                        EventsTab(matchData: matchData),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
