enum Difficulty { easy, medium, hard, expert }

extension DifficultyValue on Difficulty {
  int get removals {
    switch (this) {
      case Difficulty.easy:
        return 35;
      case Difficulty.medium:
        return 45;
      case Difficulty.hard:
        return 55;
      case Difficulty.expert:
        return 64;
    }
  }
}
