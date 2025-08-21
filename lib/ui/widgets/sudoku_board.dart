import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/logic/cubit/game_cubit.dart';

class SudokuBoard extends StatelessWidget {
  const SudokuBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<GameCubit>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedRow = cubit.state.selectedRow;
    final selectedCol = cubit.state.selectedCol;
    final selectedNumber = (selectedRow != null && selectedCol != null)
        ? cubit.state.board[selectedRow][selectedCol]
        : null;

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemCount: 81,
        itemBuilder: (context, index) {
          final row = index ~/ 9;
          final col = index % 9;
          final key = "$row-$col";

          final number = cubit.state.board[row][col];
          final isSelected = selectedRow == row && selectedCol == col;
          final isConflict = cubit.state.conflicts.contains(key);

          // --- Highlights ---
          final isHighlightedRow = selectedRow == row;
          final isHighlightedCol = selectedCol == col;
          bool isHighlightedBox = false;
          if (selectedRow != null && selectedCol != null) {
            isHighlightedBox =
                (row ~/ 3 == selectedRow ~/ 3) &&
                (col ~/ 3 == selectedCol ~/ 3);
          }

          final isSameNumberHighlight =
              (selectedNumber != null && number == selectedNumber);

          // --- Background coloring ---
          Color cellColor = colorScheme.surface;

          if (isHighlightedRow || isHighlightedCol || isHighlightedBox) {
            cellColor = colorScheme.primary.withValues(alpha: 0.12);
          }
          if (isSameNumberHighlight) {
            cellColor = colorScheme.secondary.withValues(alpha: 0.2);
          }
          if (isSelected) {
            cellColor = colorScheme.primary.withValues(alpha: 0.35);
          }

          return GestureDetector(
            onTap: () => cubit.selectCell(row, col),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline,
                    width: row % 3 == 0 ? 2 : 0.5,
                  ),
                  left: BorderSide(
                    color: colorScheme.outline,
                    width: col % 3 == 0 ? 2 : 0.5,
                  ),
                  right: BorderSide(
                    color: colorScheme.outline,
                    width: col == 8 ? 2 : 0.5,
                  ),
                  bottom: BorderSide(
                    color: colorScheme.outline,
                    width: row == 8 ? 2 : 0.5,
                  ),
                ),
                color: cellColor,
              ),
              child: Stack(
                children: [
                  // --- Number ---
                  if (number != null)
                    Center(
                      child: Text(
                        number.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          color: _getNumberColor(
                            cubit: cubit,
                            row: row,
                            col: col,
                            number: number,
                            isConflict: isConflict,
                            colorScheme: colorScheme,
                          ),
                          fontWeight: isConflict
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    )
                  // --- Notes (tiny numbers) ---
                  else if (cubit.state.notes.containsKey(key))
                    GridView.count(
                      crossAxisCount: 3,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: List.generate(9, (i) {
                        final num = i + 1;
                        return Center(
                          child: cubit.state.notes[key]!.contains(num)
                              ? Text(
                                  "$num",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        );
                      }),
                    ),

                  // --- Conflict marker for empty cells ---
                  if (isConflict && number == null)
                    Container(color: colorScheme.error.withValues(alpha: 0.2)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Helper: decides text color for numbers
  Color _getNumberColor({
    required GameCubit cubit,
    required int row,
    required int col,
    required int number,
    required bool isConflict,
    required ColorScheme colorScheme,
  }) {
    if (isConflict) return colorScheme.error;
    if (cubit.state.initialBoard[row][col] == number) {
      return colorScheme.onSurface; // given clue
    }
    if (cubit.state.fullBoard[row][col] != number) {
      return colorScheme.error; // permanent mistake
    }
    return colorScheme.primary; // user-correct entry
  }
}
