//intro_page.dart
import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  void _startGame(BuildContext context, String difficulty) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Navigator.pushNamed(
      context,
      '/theme',
      arguments: {
        'userId': args['userId'],
        'name': args['name'],
        'age': args['age'],
        'gender': args['gender'],
        'difficulty': difficulty,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCB8B8),
        title: const Text("Memory Game"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Select Difficulty:', style: TextStyle(fontSize: 24, color: Color(0xFF6D6875))),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC6C6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _startGame(context, 'easy'),
              child: const Text('Easy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9A9A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _startGame(context, 'medium'),
              child: const Text('Medium'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _startGame(context, 'hard'),
              child: const Text('Difficult'),
            ),
          ],
        ),
      ),
    );
  }
}