import 'package:flutter/material.dart';
import 'package:sudoku/data/repositories/game_repository.dart';
import 'package:sudoku/ui/screens/game_screen.dart';
import 'package:sudoku/ui/widgets/difficulty_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _canResume = false;

  @override
  void initState() {
    super.initState();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final gameState = await GameRepository.loadGame();
    setState(() {
      _canResume = gameState != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sudoku")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Resume Game button
            ElevatedButton(
              onPressed: _canResume
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameScreen(isNewGame: false),
                        ),
                      );
                    }
                  : null, // Disable the button if no game can be resumed
              child: const Text("Resume Game"),
            ),
            const SizedBox(height: 16),
            // New Game button
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const DifficultyDialog(),
                );
              },
              child: const Text("New Game"),
            ),
          ],
        ),
      ),
    );
  }
}
