// First, add these dependencies to pubspec.yaml:
// dependencies:
//   tflite_flutter: ^0.10.1

import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math';
import '../models/match_models.dart';

class MatchPredictor {
  static Interpreter? _interpreter;
  static bool _isInitialized = false;

  // Initialize the model
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _interpreter =
          await Interpreter.fromAsset('assets/match_predictor.tflite');
      _isInitialized = true;
    } catch (e) {
      print('Error initializing TFLite: $e');
      rethrow;
    }
  }

  // Convert match data to model input format
  static List<double> _preprocessMatchData(FullMatchData matchData) {
    // Extract features in the same order as training data
    final homeEvents = matchData.getTeamEvents(matchData.homeTeam.teamId);
    final awayEvents = matchData.getTeamEvents(matchData.awayTeam.teamId);

    // Count events
    int homeGoals =
        homeEvents.where((e) => e.eventType == EventType.goal).length;
    int awayGoals =
        awayEvents.where((e) => e.eventType == EventType.goal).length;
    int homeYellowCards =
        homeEvents.where((e) => e.eventType == EventType.yellowCard).length;
    int awayYellowCards =
        awayEvents.where((e) => e.eventType == EventType.yellowCard).length;
    int homeRedCards =
        homeEvents.where((e) => e.eventType == EventType.redCard).length;
    int awayRedCards =
        awayEvents.where((e) => e.eventType == EventType.redCard).length;
    int homeFouls =
        homeEvents.where((e) => e.eventType == EventType.foul).length;
    int awayFouls =
        awayEvents.where((e) => e.eventType == EventType.foul).length;
    int homeSubstitutions =
        homeEvents.where((e) => e.eventType == EventType.substitution).length;
    int awaySubstitutions =
        awayEvents.where((e) => e.eventType == EventType.substitution).length;

    // Return features in the same order as training data
    return [
      matchData.score.homeScore.toDouble(),
      matchData.score.awayScore.toDouble(),
      homeGoals.toDouble(),
      awayGoals.toDouble(),
      homeYellowCards.toDouble(),
      awayYellowCards.toDouble(),
      homeRedCards.toDouble(),
      awayRedCards.toDouble(),
      homeFouls.toDouble(),
      awayFouls.toDouble(),
      homeSubstitutions.toDouble(),
      awaySubstitutions.toDouble(),
    ];
  }

  // Make prediction
  static Future<MatchPrediction> predictMatch(FullMatchData matchData) async {
    if (!_isInitialized || _interpreter == null) {
      throw Exception('TFLite interpreter not initialized');
    }

    try {
      // Preprocess input data
      final input = _preprocessMatchData(matchData);

      // Reshape input to match model expectations (batch_size=1, input_features)
      var inputArray = [input];

      // Prepare output tensor
      var outputArray = List.filled(1 * 3, 0.0).reshape([1, 3]);

      // Run inference
      _interpreter!.run(inputArray, outputArray);

      // Process outputs
      final List<double> probabilities = outputArray[0];

      return MatchPrediction(
        homeWinProbability: probabilities[0],
        drawProbability: probabilities[1],
        awayWinProbability: probabilities[2],
      );
    } catch (e) {
      print('Error making prediction: $e');
      rethrow;
    }
  }

  // Clean up resources
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}

// Prediction result class
class MatchPrediction {
  final double homeWinProbability;
  final double drawProbability;
  final double awayWinProbability;

  MatchPrediction({
    required this.homeWinProbability,
    required this.drawProbability,
    required this.awayWinProbability,
  });

  @override
  String toString() {
    return 'Match Prediction:\n'
        'Home Win: ${(homeWinProbability * 100).toStringAsFixed(2)}%\n'
        'Draw: ${(drawProbability * 100).toStringAsFixed(2)}%\n'
        'Away Win: ${(awayWinProbability * 100).toStringAsFixed(2)}%';
  }
}
