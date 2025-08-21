import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/data/models/difficulty.dart';
import 'package:sudoku/logic/cubit/game_cubit.dart';
import 'package:sudoku/ui/screens/game_screen.dart';
import 'package:sudoku/utils/extensions.dart';

class DifficultyDialog extends StatelessWidget {
  const DifficultyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Select Difficulty"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final difficulty in Difficulty.values)
            _DifficultyOption(difficulty: difficulty),
        ],
      ),
    );
  }
}

class _DifficultyOption extends StatefulWidget {
  final Difficulty difficulty;
  const _DifficultyOption({required this.difficulty});

  @override
  State<_DifficultyOption> createState() => _DifficultyOptionState();
}

class _DifficultyOptionState extends State<_DifficultyOption> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameCubit>();
    return ListTile(
      title: Text(widget.difficulty.name.capitalize()),
      onTap: () {
        cubit.initializeGame(difficulty: widget.difficulty, isNewGame: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GameScreen()),
        );
      },
    );
  }
}
