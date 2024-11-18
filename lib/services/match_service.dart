import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_models.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FullMatchData>> getMatchesByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final matchesSnapshot = await _firestore
        .collection('matches')
        .where('start_time', isGreaterThanOrEqualTo: startOfDay)
        .where('start_time', isLessThan: endOfDay)
        .get();

    List<FullMatchData> matches = [];
    for (var doc in matchesSnapshot.docs) {
      final match = Match.fromFirestore(doc);
      // Fetch related data
      final homeTeamDoc = await _firestore
          .collection('matches')
          .doc(match.matchId)
          .collection('teams')
          .doc('home')
          .get();
      final awayTeamDoc = await _firestore
          .collection('matches')
          .doc(match.matchId)
          .collection('teams')
          .doc('away')
          .get();
      final scoreDoc = await _firestore
          .collection('matches')
          .doc(match.matchId)
          .collection('score')
          .doc('current')
          .get();
      final eventsSnapshot = await _firestore
          .collection('matches')
          .doc(match.matchId)
          .collection('events')
          .get();

      matches.add(FullMatchData.fromFirestore(
        matchDoc: doc,
        homeTeamDoc: homeTeamDoc,
        awayTeamDoc: awayTeamDoc,
        scoreDoc: scoreDoc,
        eventDocs: eventsSnapshot.docs,
      ));
    }
    return matches;
  }

  Future<List<FullMatchData>> getAllMatches() async {
    final matchesSnapshot = await _firestore.collection('matches').get();

    List<FullMatchData> matches = [];
    for (var doc in matchesSnapshot.docs) {
      final match = Match.fromFirestore(doc);
      // Fetch related data
      final homeTeamDoc = await _firestore
          .collection('matches')
          .doc(match.matchId)
          .collection('teams')
          .doc('home')
          .get();
      final awayTeamDoc = await _firestore
          .collection('matches')
          .doc(match.matchId)
          .collection('teams')
          .doc('away')
          .get();
      final scoreDoc = await _firestore
          .collection('matches')
          .doc(match.matchId)
          .collection('score')
          .doc('current')
          .get();
      final eventsSnapshot = await _firestore
          .collection('matches')
          .doc(match.matchId)
          .collection('events')
          .get();

      matches.add(FullMatchData.fromFirestore(
        matchDoc: doc,
        homeTeamDoc: homeTeamDoc,
        awayTeamDoc: awayTeamDoc,
        scoreDoc: scoreDoc,
        eventDocs: eventsSnapshot.docs,
      ));
    }
    return matches;
  }

  Future<void> createMatch(FullMatchData matchData, String userId) async {
    // Create match document
    final matchRef = _firestore.collection('matches').doc();
    final matchId = matchRef.id;

    await matchRef.set(matchData.match.toFirestore());

    // Create teams
    await matchRef
        .collection('teams')
        .doc('home')
        .set(matchData.homeTeam.toFirestore());
    await matchRef
        .collection('teams')
        .doc('away')
        .set(matchData.awayTeam.toFirestore());

    // Create initial score
    await matchRef
        .collection('score')
        .doc('current')
        .set(matchData.score.toFirestore());

    // Link match to user
    await _firestore.collection('userToMatches').doc(userId).set({
      'matchIds': FieldValue.arrayUnion([matchId])
    }, SetOptions(merge: true));
  }

  Future<void> addMatchEvent(String matchId, MatchEvent event) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('events')
        .add(event.toFirestore());
  }
}
