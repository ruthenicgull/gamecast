import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamecast/components/base_scaffold.dart';
import 'package:gamecast/models/event_model.dart';
import 'package:gamecast/models/match_model.dart'; // Assuming you have a Match model
import 'package:gamecast/components/match_card.dart'; // You can create a MatchCard widget for the match info
import 'package:gamecast/components/event_list.dart'; // A widget to display events for a match

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetching matches from Firestore
  Future<List<Match>> _fetchMatches() async {
    final snapshot = await _firestore.collection('matches').get();
    return snapshot.docs
        .map((doc) =>
            Match.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Matches",
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Match>>(
          future: _fetchMatches(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error loading matches"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No matches available"));
            }

            final matches = snapshot.data!;

            return ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];

                return MatchCard(
                  match: match, // Display the match info on the card
                  onTap: () {
                    // On card tap, navigate to the match events screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MatchEventsPage(matchId: match.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MatchEventsPage extends StatelessWidget {
  final String matchId;

  const MatchEventsPage({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Match Events",
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('matches')
              .doc(matchId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return const Center(child: Text("No events recorded yet."));
            }

            final matchData = snapshot.data!.data() as Map<String, dynamic>;
            final events = (matchData['events'] as List)
                .map((e) => MatchEvent.fromMap(e as Map<String, dynamic>))
                .toList();

            return EventList(
                events: events); // Display events using EventList widget
          },
        ),
      ),
    );
  }
}
