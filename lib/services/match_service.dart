// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/match_models.dart';

// class MatchService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<List<FullMatchData>> getMatchesByDate(DateTime date) async {
//     final startOfDay = DateTime(date.year, date.month, date.day);
//     final endOfDay = startOfDay.add(const Duration(days: 1));

//     final matchesSnapshot = await _firestore
//         .collection('matches')
//         .where('start_time', isGreaterThanOrEqualTo: startOfDay)
//         .where('start_time', isLessThan: endOfDay)
//         .get();

//     List<FullMatchData> matches = [];
//     for (var doc in matchesSnapshot.docs) {
//       final match = Match.fromFirestore(doc);
//       // Fetch related data
//       final homeTeamDoc = await _firestore
//           .collection('matches')
//           .doc(match.matchId)
//           .collection('teams')
//           .doc('home')
//           .get();
//       final awayTeamDoc = await _firestore
//           .collection('matches')
//           .doc(match.matchId)
//           .collection('teams')
//           .doc('away')
//           .get();
//       final scoreDoc = await _firestore
//           .collection('matches')
//           .doc(match.matchId)
//           .collection('score')
//           .doc('current')
//           .get();
//       final eventsSnapshot = await _firestore
//           .collection('matches')
//           .doc(match.matchId)
//           .collection('events')
//           .get();

//       matches.add(FullMatchData.fromFirestore(
//         matchDoc: doc,
//         homeTeamDoc: homeTeamDoc,
//         awayTeamDoc: awayTeamDoc,
//         scoreDoc: scoreDoc,
//         eventDocs: eventsSnapshot.docs,
//       ));
//     }
//     return matches;
//   }

//   Future<List<FullMatchData>> getAllMatches() async {
//     final matchesSnapshot = await _firestore.collection('matches').get();

//     List<FullMatchData> matches = [];
//     for (var doc in matchesSnapshot.docs) {
//       final match = Match.fromFirestore(doc);
//       // Fetch related data
//       final homeTeamDoc = await _firestore
//           .collection('matches')
//           .doc(match.matchId)
//           .collection('teams')
//           .doc('home')
//           .get();
//       final awayTeamDoc = await _firestore
//           .collection('matches')
//           .doc(match.matchId)
//           .collection('teams')
//           .doc('away')
//           .get();
//       final scoreDoc = await _firestore
//           .collection('matches')
//           .doc(match.matchId)
//           .collection('score')
//           .doc('current')
//           .get();
//       final eventsSnapshot = await _firestore
//           .collection('matches')
//           .doc(match.matchId)
//           .collection('events')
//           .get();

//       matches.add(FullMatchData.fromFirestore(
//         matchDoc: doc,
//         homeTeamDoc: homeTeamDoc,
//         awayTeamDoc: awayTeamDoc,
//         scoreDoc: scoreDoc,
//         eventDocs: eventsSnapshot.docs,
//       ));
//     }
//     return matches;
//   }

//   Future<void> createMatch(FullMatchData matchData, String userId) async {
//     // Create match document
//     final matchRef = _firestore.collection('matches').doc();
//     final matchId = matchRef.id;

//     await matchRef.set(matchData.match.toFirestore());

//     // Create teams
//     await matchRef
//         .collection('teams')
//         .doc('home')
//         .set(matchData.homeTeam.toFirestore());
//     await matchRef
//         .collection('teams')
//         .doc('away')
//         .set(matchData.awayTeam.toFirestore());

//     // Create initial score
//     await matchRef
//         .collection('score')
//         .doc('current')
//         .set(matchData.score.toFirestore());

//     // Link match to user
//     await _firestore.collection('userToMatches').doc(userId).set({
//       'matchIds': FieldValue.arrayUnion([matchId])
//     }, SetOptions(merge: true));
//   }

//   Future<void> addMatchEvent(String matchId, MatchEvent event) async {
//     await _firestore
//         .collection('matches')
//         .doc(matchId)
//         .collection('events')
//         .add(event.toFirestore());
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/match_models.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Your existing methods...

  Future<List<FullMatchData>> getOngoingMatches() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final matchesSnapshot = await _firestore
        .collection('matches')
        .where('start_time', isLessThanOrEqualTo: now)
        .where('start_time', isGreaterThanOrEqualTo: startOfDay)
        .where('status', isEqualTo: 'ongoing')
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

  Future<List<FullMatchData>> getUserMatches() async {
    final String currentUserId = _auth.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) {
      throw Exception('User not authenticated');
    }

    // Get user's match IDs
    final userMatchesDoc =
        await _firestore.collection('userToMatches').doc(currentUserId).get();

    if (!userMatchesDoc.exists) {
      return [];
    }

    final List<String> matchIds =
        List<String>.from(userMatchesDoc.data()?['matchIds'] ?? []);

    List<FullMatchData> matches = [];
    for (String matchId in matchIds) {
      final matchDoc =
          await _firestore.collection('matches').doc(matchId).get();

      if (!matchDoc.exists) continue;

      final match = Match.fromFirestore(matchDoc);

      // Fetch related data
      final homeTeamDoc = await _firestore
          .collection('matches')
          .doc(matchId)
          .collection('teams')
          .doc('home')
          .get();
      final awayTeamDoc = await _firestore
          .collection('matches')
          .doc(matchId)
          .collection('teams')
          .doc('away')
          .get();
      final scoreDoc = await _firestore
          .collection('matches')
          .doc(matchId)
          .collection('score')
          .doc('current')
          .get();
      final eventsSnapshot = await _firestore
          .collection('matches')
          .doc(matchId)
          .collection('events')
          .get();

      matches.add(FullMatchData.fromFirestore(
        matchDoc: matchDoc,
        homeTeamDoc: homeTeamDoc,
        awayTeamDoc: awayTeamDoc,
        scoreDoc: scoreDoc,
        eventDocs: eventsSnapshot.docs,
      ));
    }

    // Sort by start time, most recent first
    matches.sort((a, b) => b.match.startTime.compareTo(a.match.startTime));
    return matches;
  }

  Future<List<FullMatchData>> getPastMatches() async {
    final now = DateTime.now();

    final matchesSnapshot = await _firestore
        .collection('matches')
        .where('status', isEqualTo: 'completed')
        .where('start_time', isLessThan: now)
        .orderBy('start_time', descending: true)
        .limit(50) // Limit to prevent loading too many matches
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

  // Helper methods for match status updates
  Future<void> startMatch(String matchId) async {
    await _firestore.collection('matches').doc(matchId).update({
      'status': 'ongoing',
      'start_time': DateTime.now(),
    });
  }

  Future<void> endMatch(String matchId) async {
    await _firestore.collection('matches').doc(matchId).update({
      'status': 'completed',
      'end_time': DateTime.now(),
    });
  }

  Future<void> updateScore(
      String matchId, Map<String, dynamic> scoreData) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('score')
        .doc('current')
        .update(scoreData);
  }

  Future<void> addMatchEvent(String matchId, MatchEvent event) async {
    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('events')
        .add(event.toFirestore());
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
}
