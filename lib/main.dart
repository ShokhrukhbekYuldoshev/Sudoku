import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/logic/cubit/game_cubit.dart';
import 'package:sudoku/logic/services/generator.dart';
import 'ui/screens/home_screen.dart';
import 'core/theme.dart';

Future<void> main() async {
  // Run the app
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => GameCubit(SudokuGenerator()))],
      child: MaterialApp(
        title: 'Sudoku',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
