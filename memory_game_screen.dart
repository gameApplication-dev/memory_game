//memory_game_screen.dart
import 'package:flutter/material.dart';
import 'firestore_service.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late List<bool> flippedCards;
  late List<String> cards;
  List<int> flippedIndices = [];
  bool isProcessing = false;
  late int gridCount;
  late int totalCards;
  late int pairsToMatch;
  int successfulAttempts = 0;
  int attempts = 0;
  int quitCount = 0;
  late Stopwatch stopwatch;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    flippedCards = [];
    cards = [];
    stopwatch.start();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        final userId = args['userId'] as String;
        try {
          final userData = await _firestoreService.fetchUserData(userId);
          if (userData != null) {
            quitCount = userData['gameData']?['quitCount'] ?? 0;
          }
        } catch (e) {
          print('Error fetching initial quit count: $e');
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      final String difficulty = args['difficulty'] as String;
      final String theme =
          args['theme'] as String? ?? 'fruits'; // Default to fruits
      setupGame(difficulty, theme: theme);
    }
  }

  void setupGame(String difficulty, {String theme = 'fruits'}) {
    setState(() {
      switch (difficulty) {
        case 'easy':
          gridCount = 4;
          totalCards = 16;
          pairsToMatch = 8;
          break;
        case 'medium':
          gridCount = 5;
          totalCards = 20;
          pairsToMatch = 10;
          break;
        case 'hard':
          gridCount = 6;
          totalCards = 24;
          pairsToMatch = 12;
          break;
        default:
          gridCount = 4;
          totalCards = 16;
          pairsToMatch = 8;
      }
      cards = generateCardPairs(pairsToMatch, theme: theme);
      cards.shuffle();
      flippedCards = List.generate(totalCards, (_) => false);
    });
  }

  List<String> generateCardPairs(int numPairs, {String theme = 'fruits'}) {
    List<String> baseCards;

    switch (theme) {
      case 'animals':
        baseCards = [
          '🐶',
          '🐱',
          '🐭',
          '🐹',
          '🐰',
          '🦊',
          '🐻',
          '🐼',
          '🐨',
          '🐯',
          '🦁',
          '🐮',
          '🐷',
          '🐸',
          '🐵',
          '🦄'
        ];
        break;
      case 'halloween':
        baseCards = [
          '🎃',
          '👻',
          '🦇',
          '🕷',
          '🕸',
          '🧙‍♀️',
          '🧛‍♂️',
          '🧟‍♀️',
          '⚰️',
          '🪦',
          '🕯',
          '☠️',
          '🍬',
          '🍭',
          '🧙‍♂️',
          '🧛‍♀️'
        ];
        break;
      case 'emojis':
        baseCards = [
          '😀',
          '😂',
          '😍',
          '😎',
          '🥳',
          '😱',
          '😡',
          '🤔',
          '😴',
          '😇',
          '🤩',
          '😭',
          '🤗',
          '😏',
          '🤐',
          '🥶'
        ];
        break;
      case 'fruits': // Default theme
      default:
        baseCards = [
          '🍎',
          '🍌',
          '🍇',
          '🍓',
          '🍒',
          '🍍',
          '🥝',
          '🍉',
          '🍋',
          '🍑',
          '🥥',
          '🍈',
          '🍆',
          '🥑',
          '🍠',
          '🍄'
        ];
    }

    return List.generate(numPairs, (i) => [baseCards[i], baseCards[i]])
        .expand((x) => x)
        .toList();
  }

  void flipCard(int index) {
    if (flippedCards[index] || isProcessing) return;
    setState(() {
      flippedCards[index] = true;
      flippedIndices.add(index);
      attempts++;
      if (flippedIndices.length == 2) checkForMatch();
    });
  }

  void checkForMatch() {
    isProcessing = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        if (cards[flippedIndices[0]] == cards[flippedIndices[1]]) {
          successfulAttempts++;
        } else {
          flippedCards[flippedIndices[0]] = false;
          flippedCards[flippedIndices[1]] = false;
        }
        flippedIndices.clear();
        isProcessing = false;
        checkForWin();
      });
    });
  }

  void checkForWin() {
    if (flippedCards.every((flipped) => flipped)) {
      stopwatch.stop();
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final userId = args['userId'] as String;
      final difficulty = args['difficulty'] as String;

      Map<String, dynamic> gameData = {
        'gameData': {
          'difficulty': difficulty,
          'timeTaken': stopwatch.elapsed.inSeconds,
          'attempts': attempts,
          'successfulAttempts': successfulAttempts,
          'unsuccessfulAttempts': attempts - successfulAttempts,
          'completedAt': DateTime.now().toIso8601String(),
        }
      };

      _firestoreService
          .updateGameData(userId, gameData, isQuitting: false)
          .then((_) async {
        if (mounted) {
          final userData = await _firestoreService.fetchUserData(userId);
          final currentQuitCount = userData?['gameData']?['quitCount'] ?? 0;

          Navigator.pushReplacementNamed(
            context,
            '/win',
            arguments: {
              'timeTaken': gameData['gameData']['timeTaken'],
              'attempts': gameData['gameData']['attempts'],
              'successfulAttempts': gameData['gameData']['successfulAttempts'],
              'quitCount': currentQuitCount,
              'difficulty': difficulty,
            },
          );
        }
      }).catchError((error) {
        print('Error updating game data: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save game data')),
        );
      });
    }
  }

  Future<bool> _onWillPop() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userId = args['userId'] as String;

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Quit Game'),
            content: const Text('Are you sure you want to quit the game?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final userData =
                        await _firestoreService.fetchUserData(userId);
                    final currentQuitCount =
                        userData?['gameData']?['quitCount'] ?? 0;

                    Map<String, dynamic> gameData = {
                      'gameData': {
                        'quitCount': currentQuitCount + 1,
                      }
                    };

                    await _firestoreService.updateGameData(userId, gameData,
                        isQuitting: true);

                    if (mounted) {
                      args['quitCount'] = currentQuitCount + 1;
                    }
                  } catch (e) {
                    print('Error updating quit data: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to save game data')),
                      );
                    }
                  }

                  Navigator.of(context).pop(true); // Close dialog immediately
                  Navigator.of(context)
                      .pushReplacementNamed('/intro', arguments: args);
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCB8B8),
        title: const Text("Memory Game"),
        centerTitle: true,
      ),
      body: Center(
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: totalCards,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => flipCard(index),
              child: Card(
                color: flippedCards[index]
                    ? Colors.white
                    : const Color(0xFFFFC6C6),
                child: Center(
                  child: Text(
                    flippedCards[index] ? cards[index] : '',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
