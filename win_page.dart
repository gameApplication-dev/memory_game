import 'package:flutter/material.dart';
import 'firestore_service.dart';

class WinPage extends StatefulWidget {
  const WinPage({super.key});

  @override
  State<WinPage> createState() => _WinPageState();
}

class _WinPageState extends State<WinPage> {
  final FirestoreService _firestoreService = FirestoreService();
  double? percentileScore;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _calculatePercentile(
      int timeTaken, int attempts, String difficulty) async {
    double score = await _firestoreService.calculatePercentile(
      timeTaken,
      attempts,
      difficulty,
    );
    setState(() {
      percentileScore = score;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int timeTaken = args['timeTaken'];
    final int attempts = args['attempts'];
    final String difficulty = args['difficulty'];

    // Calculate percentile when the page loads
    if (percentileScore == null) {
      _calculatePercentile(timeTaken, attempts, difficulty);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCB8B8),
        title: const Text("You Win!"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉 You Win! 🎉',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Time Taken: $timeTaken seconds',
                style: const TextStyle(fontSize: 24)),
            Text('Attempts: $attempts', style: const TextStyle(fontSize: 24)),
            Text('Difficulty: ${difficulty.toUpperCase()}',
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            if (percentileScore != null)
              Text('Percentile : ${percentileScore!.toStringAsFixed(1)}',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B6B)))
            else
              const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B))),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC6C6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Play Again', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9A9A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Exit', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
