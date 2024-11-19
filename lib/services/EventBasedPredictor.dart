import '../models/match_models.dart';

class EventBasedPredictor {
  // Event weights (can be adjusted for accuracy)
  static const double goalWeight = 1.0;
  static const double yellowCardWeight = -0.2;
  static const double redCardWeight = -0.5;
  static const double foulWeight = -0.1;
  static const double substitutionWeight = 0.1;

  // Predict match outcome using event data
  static MatchPrediction predictMatch(FullMatchData matchData) {
    // Calculate scores for both teams
    double homeScore =
        _calculateTeamScore(matchData.homeTeam.teamId, matchData);
    double awayScore =
        _calculateTeamScore(matchData.awayTeam.teamId, matchData);

    // Normalize scores to determine probabilities
    double totalScore = homeScore + awayScore;
    double homeWinProbability = homeScore / totalScore;
    double drawProbability =
        1.0 - (homeWinProbability + (awayScore / totalScore));
    double awayWinProbability = awayScore / totalScore;

    // Ensure no probabilities are negative
    homeWinProbability = homeWinProbability < 0 ? 0 : homeWinProbability;
    drawProbability = drawProbability < 0 ? 0 : drawProbability;
    awayWinProbability = awayWinProbability < 0 ? 0 : awayWinProbability;

    // Re-normalize to ensure the sum is 1
    double sumProbabilities =
        homeWinProbability + drawProbability + awayWinProbability;

    return MatchPrediction(
      homeWinProbability: homeWinProbability / sumProbabilities,
      drawProbability: drawProbability / sumProbabilities,
      awayWinProbability: awayWinProbability / sumProbabilities,
    );
  }

  // Calculate score for a given team based on match events
  static double _calculateTeamScore(String teamId, FullMatchData matchData) {
    // Get all events related to the team
    List<MatchEvent> teamEvents = matchData.getTeamEvents(teamId);

    // Initialize event counts
    int goals = 0;
    int yellowCards = 0;
    int redCards = 0;
    int fouls = 0;
    int substitutions = 0;

    // Count each event type
    for (var event in teamEvents) {
      switch (event.eventType) {
        case EventType.goal:
          goals++;
          break;
        case EventType.yellowCard:
          yellowCards++;
          break;
        case EventType.redCard:
          redCards++;
          break;
        case EventType.foul:
          fouls++;
          break;
        case EventType.substitution:
          substitutions++;
          break;
      }
    }

    // Calculate the score using weights for each event type
    double score = (goals * goalWeight) +
        (yellowCards * yellowCardWeight) +
        (redCards * redCardWeight) +
        (fouls * foulWeight) +
        (substitutions * substitutionWeight);

    return score;
  }
}

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
