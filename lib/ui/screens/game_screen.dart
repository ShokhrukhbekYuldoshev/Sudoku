import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/logic/cubit/game_cubit.dart';
import 'package:sudoku/logic/cubit/game_state.dart';
import 'package:sudoku/ui/widgets/control_buttons.dart';
import 'package:sudoku/ui/widgets/difficulty_dialog.dart';
import 'package:sudoku/ui/widgets/game_header.dart';
import 'package:sudoku/ui/widgets/game_over_dialog.dart';
import '../widgets/number_pad.dart';
import '../widgets/sudoku_board.dart';

class GameScreen extends StatefulWidget {
  final bool isNewGame;

  const GameScreen({super.key, this.isNewGame = false});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GameCubit>().initializeGame(isNewGame: widget.isNewGame);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameCubit, GameState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          (current.status == GameStatus.won ||
              current.status == GameStatus.lost),
      listener: (context, state) {
        final won = state.status == GameStatus.won;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GameOverDialog(
            won: won,
            onRestart: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const DifficultyDialog(),
              );
            },
            onExit: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // back to menu
            },
          ),
        );
      },
      child: Scaffold(
        body: BlocBuilder<GameCubit, GameState>(
          builder: (context, state) {
            if (state.status == GameStatus.loading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading game...', style: TextStyle(fontSize: 18)),
                  ],
                ),
              );
            } else {
              return SafeArea(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: GameHeader(),
                    ),
                    const Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SudokuBoard(),
                        ),
                      ),
                    ),
                    const ControlButtons(),
                    const NumberPad(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
