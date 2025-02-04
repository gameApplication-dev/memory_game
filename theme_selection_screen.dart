// theme_selection_screen.dart
import 'package:flutter/material.dart';

class ThemeSelectionScreen extends StatelessWidget {
  final String userId;
  final String difficulty;

  const ThemeSelectionScreen({
    super.key,
    required this.userId,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final themes = {
      'Fruits': {'name': 'fruits', 'icon': '🍎'},
      'Animals': {'name': 'animals', 'icon': '🐶'},
      'Halloween': {'name': 'halloween', 'icon': '🎃'},
      'Emojis': {'name': 'emojis', 'icon': '😀'},
    };

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E1),
      appBar: AppBar(
        title: const Text(
          "Choose Theme",
          style: TextStyle(fontFamily: 'ComicSans', fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFCB8B8),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // Constrain width for larger screens
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select a Theme for Your Game!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF6D6875),
                    fontFamily: 'ComicSans',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 400, // Fixed height for the grid
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: themes.entries.map((entry) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/game',
                            arguments: {
                              'userId': userId,
                              'difficulty': difficulty,
                              'theme': entry.value['name'],
                            },
                          );
                        },
                        child: Card(
                          elevation: 4,
                          color: const Color(0xFFFFE3E3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(
                              color: Color(0xFFFCB8B8),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                entry.value['icon']!,
                                style: const TextStyle(fontSize: 48),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                entry.key,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFF6D6875),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}