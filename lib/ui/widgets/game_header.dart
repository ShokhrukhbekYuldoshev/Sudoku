import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/logic/cubit/game_cubit.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({super.key});

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameCubit>().state;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Mistakes as hearts
        Row(
          children: List.generate(
            state.maxMistakes,
            (i) => Icon(
              i < state.mistakes ? Icons.close : Icons.close_outlined,
              color: i < state.mistakes ? Colors.red : Colors.grey,
              size: 28,
            ),
          ),
        ),
        // Timer
        Text(
          formatTime(state.secondsElapsed),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
