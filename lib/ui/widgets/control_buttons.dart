import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/logic/cubit/game_cubit.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GameCubit>();
    final isNoteMode = cubit.state.noteMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: cubit.undo,
            icon: const Icon(Icons.undo),
            tooltip: "Undo",
          ),
          IconButton(
            onPressed: cubit.redo,
            icon: const Icon(Icons.redo),
            tooltip: "Redo",
          ),
          IconButton(
            onPressed: cubit.erase,
            icon: const Icon(Icons.backspace),
            tooltip: "Erase",
          ),
          IconButton(
            onPressed: cubit.toggleNoteMode,
            icon: Icon(
              Icons.edit_note,
              color: isNoteMode ? Colors.orange : Colors.grey.shade700,
            ),
            tooltip: "Notes mode",
          ),
        ],
      ),
    );
  }
}
