class Stats {
  int puzzlesSolved;
  Duration bestTime;
  Duration totalPlayTime;

  Stats({
    this.puzzlesSolved = 0,
    this.bestTime = Duration.zero,
    this.totalPlayTime = Duration.zero,
  });
}
