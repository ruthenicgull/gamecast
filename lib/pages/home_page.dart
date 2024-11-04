import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/match_model.dart'; // Adjust according to your project structure
import 'dart:convert';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Match>> _matches;

  @override
  void initState() {
    super.initState();
    _matches = loadMatches();
  }

  Future<List<Match>> loadMatches() async {
    final String jsonString =
        await rootBundle.loadString('assets/sample_matches.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return (jsonData['matches'] as List)
        .map((matchJson) => Match.fromJson(matchJson))
        .toList();
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    // Navigate back to AuthPage after logout
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Football Matches"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout, // Call the logout function when pressed
          ),
        ],
      ),
      body: FutureBuilder<List<Match>>(
        future: _matches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No matches available"));
          }

          final matches = snapshot.data!;
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return MatchTile(match: match);
            },
          );
        },
      ),
    );
  }
}

class MatchTile extends StatelessWidget {
  final Match match;

  MatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(match.team1, style: const TextStyle(fontSize: 18)),
                Text("${match.score1} - ${match.score2}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(match.team2, style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 8),
            Text(match.status,
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Text("Start Time: ${match.startTime.toLocal()}",
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
