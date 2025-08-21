import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final bool won;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const GameOverDialog({
    super.key,
    required this.won,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        won ? "You Won!" : "You Lost!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: won ? Colors.green : Colors.red,
        ),
      ),
      content: Text(
        won
            ? "Congratulations! You solved the puzzle."
            : "You reached the maximum mistakes.",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Restart"),
          onPressed: onRestart,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.exit_to_app),
          label: const Text("Exit"),
          onPressed: onExit,
        ),
      ],
    );
  }
}
