import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'intro_page.dart';
import 'win_page.dart';
import 'memory_game_screen.dart';
import 'firestore_service.dart';
import 'theme_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  runApp(const MemoryGameApp());
}

class MemoryGameApp extends StatelessWidget {
  const MemoryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Game',
      theme: ThemeData(primarySwatch: Colors.pink),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/intro': (context) => const IntroPage(),
        '/theme': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ThemeSelectionScreen(
            userId: args['userId'],
            difficulty: args['difficulty'],
          );
        },
        '/game': (context) => const MemoryGameScreen(),
        '/win': (context) => const WinPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String? _gender;
  final int _maxAge = 80;
  bool _isNameValid = true;
  bool _isAgeValid = true;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateNameInput);
    _ageController.addListener(_validateAgeInput);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateNameInput);
    _ageController.removeListener(_validateAgeInput);
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _validateNameInput() {
    final regex = RegExp(r'^[a-zA-Z\s]*$');
    setState(() {
      _isNameValid = regex.hasMatch(_nameController.text) &&
          _nameController.text.length <= 30;
    });
  }

  void _validateAgeInput() {
    final age = int.tryParse(_ageController.text);
    setState(() {
      _isAgeValid = age != null && age > 0 && age <= _maxAge;
    });
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_isNameValid && _isAgeValid && _gender != null) {
      final userData = {
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'gender': _gender,
      };

      try {
        await _firestoreService.createOrUpdateUser(userData);
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/intro',
            arguments: {
              'userId': userData['name'],
              'name': userData['name'],
              'age': userData['age'],
              'gender': userData['gender'],
            },
          );
        }
      } catch (e) {
        _showAlertDialog('Error', 'Failed to save user data: $e');
      }
    } else {
      _showAlertDialog('Input Error', 'Please fill in all fields correctly.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCB8B8),
        title: const Text(
          "Memory Game Login",
          style: TextStyle(fontFamily: 'ComicSans', fontSize: 24),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to the Memory Game!',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF6D6875),
                  fontFamily: 'ComicSans',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  errorText: _isNameValid
                      ? null
                      : 'Invalid name (Use only letters and spaces)',
                  labelStyle: const TextStyle(color: Color(0xFFB5838D)),
                  filled: true,
                  fillColor: const Color(0xFFFFE3E3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  errorText: _isAgeValid
                      ? null
                      : 'Invalid age (Enter age from 1-80 only)',
                  labelStyle: const TextStyle(color: Color(0xFFB5838D)),
                  filled: true,
                  fillColor: const Color(0xFFFFE3E3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Gender:',
                style: TextStyle(fontSize: 18, color: Color(0xFF6D6875)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _gender = 'Male';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _gender == 'Male'
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                        border: _gender == 'Male'
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            '👨',
                            style: TextStyle(
                              fontSize: 50,
                              color: _gender == 'Male'
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                          const Text('Male',
                              style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _gender = 'Female';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _gender == 'Female'
                            ? Colors.pink.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                        border: _gender == 'Female'
                            ? Border.all(color: Colors.pink, width: 2)
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            '👩',
                            style: TextStyle(
                              fontSize: 50,
                              color: _gender == 'Female'
                                  ? Colors.pink
                                  : Colors.black,
                            ),
                          ),
                          const Text('Female',
                              style: TextStyle(color: Colors.pink)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFCB8B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,
                child: const Text(
                  'Start Game',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
