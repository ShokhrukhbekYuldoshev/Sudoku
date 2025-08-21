Set<int> getImpossibleNumbers(int row, int col, List<List<int?>> board) {
  final impossible = <int>{};

  // Row
  for (int c = 0; c < 9; c++) {
    if (board[row][c] != null) impossible.add(board[row][c]!);
  }

  // Column
  for (int r = 0; r < 9; r++) {
    if (board[r][col] != null) impossible.add(board[r][col]!);
  }

  // Box
  final boxRow = (row ~/ 3) * 3;
  final boxCol = (col ~/ 3) * 3;
  for (int r = boxRow; r < boxRow + 3; r++) {
    for (int c = boxCol; c < boxCol + 3; c++) {
      if (board[r][c] != null) impossible.add(board[r][c]!);
    }
  }

  return impossible;
}
