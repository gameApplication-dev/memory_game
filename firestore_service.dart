import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrUpdateUser(Map<String, dynamic> userData) async {
    try {
      final String playerName = userData['name'];
      final docRef = _firestore.collection('users2').doc(playerName);

      DocumentSnapshot snapshot = await docRef.get();

      if (!snapshot.exists) {
        await docRef.set({
          'playerInfo': {
            'name': userData['name'],
            'age': userData['age'],
            'gender': userData['gender'],
            'percentile': 0,
          },
          'gameSessions': [
            {
              'sessionNumber': 1,
              'createdAt': DateTime.now().toIso8601String(),
              'gameData': {
                'quitCount': 0,
                'attempts': 0,
                'successfulAttempts': 0,
                'timeTaken': 0,
                'difficulty': '',
                'completedAt': null,
                'percentile': 0,
              }
            }
          ]
        });

        print('Created new player document for: $playerName');
        return;
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> sessions = data['gameSessions'] ?? [];
      int nextSessionNumber = sessions.length + 1;

      sessions.add({
        'sessionNumber': nextSessionNumber,
        'createdAt': DateTime.now().toIso8601String(),
        'gameData': {
          'quitCount': 0,
          'attempts': 0,
          'successfulAttempts': 0,
          'timeTaken': 0,
          'difficulty': '',
          'completedAt': null,
          'percentile': 0,
        }
      });

      await docRef.update({
        'gameSessions': sessions
      });

      print('Added new session #$nextSessionNumber for player: $playerName');

    } catch (e) {
      print('Error creating/updating user: $e');
      rethrow;
    }
  }

  Future<void> updateGameData(String playerName, Map<String, dynamic> gameData, {bool isQuitting = false}) async {
    try {
      final docRef = _firestore.collection('users2').doc(playerName);

      DocumentSnapshot snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception('Player document not found');
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> sessions = List.from(data['gameSessions']);

      int currentSessionIndex = sessions.length - 1;
      Map<String, dynamic> currentSession = Map.from(sessions[currentSessionIndex]);

      if (isQuitting) {
        currentSession['gameData']['quitCount'] = (currentSession['gameData']['quitCount'] ?? 0) + 1;
      } else {
        currentSession['gameData'] = {
          ...currentSession['gameData'],
          ...gameData['gameData'] as Map<String, dynamic>,
        };
      }

      // Calculate and update percentile after game completion
      if (!isQuitting && currentSession['gameData']['completedAt'] != null) {
        double percentile = await calculatePercentile(
            currentSession['gameData']['timeTaken'],
            currentSession['gameData']['attempts'],
            currentSession['gameData']['difficulty']
        );
        currentSession['gameData']['percentile'] = percentile;
      }

      sessions[currentSessionIndex] = currentSession;

      await docRef.update({
        'gameSessions': sessions
      });

      print('Game data updated successfully for player: $playerName, session #${currentSession['sessionNumber']}');

    } catch (e) {
      print('Error updating game data: $e');
      rethrow;
    }
  }

  Future<double> calculatePercentile(int timeTaken, int attempts, String difficulty) async {
    try {
      QuerySnapshot gamesSnapshot = await _firestore
          .collection('users2')
          .get();

      List<double> allScores = [];

      // Collect all completed games' scores with matching difficulty
      for (var doc in gamesSnapshot.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        List<dynamic> sessions = userData['gameSessions'] ?? [];

        for (var session in sessions) {
          if (session['gameData']['difficulty'] == difficulty &&
              session['gameData']['completedAt'] != null) {
            double score = calculateScore(
                session['gameData']['timeTaken'],
                session['gameData']['attempts']
            );
            allScores.add(score);
          }
        }
      }

      if (allScores.isEmpty) return 0.0;

      // Calculate current game's score
      double currentScore = calculateScore(timeTaken, attempts);

      // Sort scores in ascending order (lower is better)
      allScores.sort();

      // Find position of current score
      int position = 0;
      for (int i = 0; i < allScores.length; i++) {
        if (currentScore <= allScores[i]) {
          position = i;
          break;
        }
        position = allScores.length;
      }

      // Calculate percentile
      return ((allScores.length - position) / allScores.length) * 100;

    } catch (e) {
      print('Error calculating percentile: $e');
      return 0.0;
    }
  }

  double calculateScore(int timeTaken, int attempts) {
    // Lower score is better
    const double timeWeight = 0.7;
    const double attemptsWeight = 0.3;
    return (timeTaken * timeWeight) + (attempts * attemptsWeight);
  }

  Future<Map<String, dynamic>?> fetchUserData(String playerName) async {
    try {
      print('Fetching data for player: $playerName');
      DocumentSnapshot snapshot = await _firestore.collection('users2').doc(playerName).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> sessions = data['gameSessions'];
        Map<String, dynamic> latestSession = sessions.last;

        print('Successfully fetched player data: $data');
        return {
          'playerInfo': data['playerInfo'],
          'currentSession': latestSession,
          'totalSessions': sessions.length
        };
      }
      return null;
    } catch (e) {
      print('Error fetching player data: $e');
      rethrow;
    }
  }
}