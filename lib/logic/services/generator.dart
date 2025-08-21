import 'dart:math';
import 'package:sudoku/data/models/difficulty.dart';

class SudokuGenerator {
  final Random _rand = Random();
  late List<List<int?>> solution;

  /// Generate a new puzzle with a given difficulty.
  Future<List<List<int?>>> generatePuzzle({
    Difficulty difficulty = Difficulty.medium,
  }) async {
    // 1. Generate a fully solved board.
    List<List<int>> fullBoard = _generateFullBoard();
    solution = fullBoard.map((r) => r.toList()).toList();

    List<List<int?>> puzzle = fullBoard
        .map((r) => r.map((e) => e as int?).toList())
        .toList();

    // 2. Determine how many numbers to remove based on difficulty.
    int removals = difficulty.removals;
    List<int> positions = List.generate(81, (i) => i)..shuffle(_rand);

    int removedCount = 0;
    for (int pos in positions) {
      if (removedCount >= removals) {
        break;
      }

      int row = pos ~/ 9;
      int col = pos % 9;

      if (puzzle[row][col] == null) {
        continue;
      }

      // 3. Attempt to remove a number.
      int? backup = puzzle[row][col];
      puzzle[row][col] = null;

      // 4. Check if the puzzle still has a unique solution using a full solver.
      // We pass a deep copy to the solver to avoid modifying the original puzzle.
      List<List<int?>> puzzleCopy = puzzle.map((r) => r.toList()).toList();
      if (_hasUniqueSolution(puzzleCopy)) {
        removedCount++;
      } else {
        // If not unique, revert the change.
        puzzle[row][col] = backup;
      }
    }

    return puzzle;
  }

  /// Generates a fully solved Sudoku board using a backtracking algorithm.
  List<List<int>> _generateFullBoard() {
    List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
    _fillBoard(board);
    return board;
  }

  bool _fillBoard(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          List<int> nums = List.generate(9, (i) => i + 1)..shuffle(_rand);
          for (int num in nums) {
            if (_isSafe(board, row, col, num)) {
              board[row][col] = num;
              if (_fillBoard(board)) {
                return true;
              }
              board[row][col] = 0; // Backtrack
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// Checks if a number can be placed at a specific position.
  bool _isSafe(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) {
        return false;
      }
    }
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        if (board[r][c] == num) {
          return false;
        }
      }
    }
    return true;
  }

  /// Checks if the puzzle has exactly one solution by running a solver.
  bool _hasUniqueSolution(List<List<int?>> board) {
    int count = 0;

    void solve() {
      if (count > 1) return;

      int row = -1, col = -1;
      // Find the next empty cell
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (board[r][c] == null) {
            row = r;
            col = c;
            break;
          }
        }
        if (row != -1) break;
      }

      if (row == -1) {
        count++;
        return;
      }

      for (int n = 1; n <= 9; n++) {
        if (_isCandidateSafe(board, row, col, n)) {
          board[row][col] = n;
          solve();
          board[row][col] = null; // Backtrack
          if (count > 1) return;
        }
      }
    }

    solve();
    return count == 1;
  }

  /// Checks if a number can be placed in a partially filled board.
  bool _isCandidateSafe(List<List<int?>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num) return false;
    }
    for (int i = 0; i < 9; i++) {
      if (board[i][col] == num) return false;
    }
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        if (board[r][c] == num) return false;
      }
    }
    return true;
  }
}
