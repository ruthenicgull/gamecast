import 'package:flutter/material.dart';
import 'package:gamecast/pages/add_match_page.dart';
import 'package:gamecast/pages/match_page.dart';
import '../widgets/match_card.dart';
import '../services/match_service.dart';
import 'package:gamecast/models/match_models.dart';

class MatchesPage extends StatefulWidget {
  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final MatchService _matchService = MatchService();
  DateTime selectedDate = DateTime.now();
  List<FullMatchData> matches = [];

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    final matchesList = await _matchService.getMatchesByDate(selectedDate);
    setState(() {
      matches = matchesList;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadMatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matches'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddMatchPage()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            return MatchCard(
              matchData: matches[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchPage(matchData: matches[index]),
                ),
              ),
            );
          }),
    );
  }
}
