import 'package:sudoku/data/models/difficulty.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension DifficultyPool on Difficulty {
  int get poolSize {
    switch (this) {
      case Difficulty.easy:
        return 100;
      case Difficulty.medium:
        return 100;
      case Difficulty.hard:
        return 100;
      case Difficulty.expert:
        return 100;
    }
  }
}
