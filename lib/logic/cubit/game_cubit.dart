import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/core/helpers.dart';
import 'package:sudoku/data/models/difficulty.dart';
import 'package:sudoku/data/models/move.dart';
import 'package:sudoku/data/repositories/game_repository.dart';
import 'package:sudoku/logic/services/generator.dart';
import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  final SudokuGenerator generator;

  /// Track number of correctly filled cells (for fast win-check)
  int _correctCells = 0;

  GameCubit(this.generator)
    : super(
        GameState(
          board: List.generate(9, (_) => List.filled(9, null)),
          fullBoard: List.generate(9, (_) => List.filled(9, null)),
          initialBoard: List.generate(9, (_) => List.filled(9, null)),
          notes: {},
          conflicts: {},
        ),
      );

  Future<void> initializeGame({
    Difficulty difficulty = Difficulty.medium,
    bool isNewGame = false,
  }) async {
    emit(state.copyWith(status: GameStatus.loading));

    try {
      GameState? savedState;

      // Only load saved game if it's not a new game
      if (!isNewGame) {
        savedState = await GameRepository.loadGame();
      }

      if (savedState != null) {
        _recountCorrectCells(savedState.board); // count correct cells
        emit(savedState); // resume saved game
        return;
      }

      // Generate a new puzzle if no saved game exists or if it's a new game
      final puzzle = await generator.generatePuzzle(difficulty: difficulty);
      final solution = generator.solution;

      _correctCells = _countCorrectCells(puzzle, solution);

      final newState = GameState(
        board: _deepCopyBoard(puzzle),
        fullBoard: _deepCopyBoard(solution),
        initialBoard: _deepCopyBoard(puzzle),
        notes: {},
        conflicts: {},
        mistakes: 0,
        maxMistakes: 3,
        secondsElapsed: 0,
        status: GameStatus.playing,
        undoStack: [],
        redoStack: [],
      );

      emit(newState);

      // Save it for future resuming
      await GameRepository.saveGame(newState);
    } catch (e, st) {
      if (kDebugMode) {
        print('Error initializing game: $e\n$st');
      }
      emit(state.copyWith(status: GameStatus.error));
    }
  }

  void selectCell(int row, int col) {
    if (state.status != GameStatus.playing) return;
    emit(state.copyWith(selectedRow: row, selectedCol: col));
  }

  void toggleNoteMode() {
    emit(state.copyWith(noteMode: !state.noteMode));
  }

  void setNumber(int number) {
    if (state.status != GameStatus.playing) return;
    final row = state.selectedRow;
    final col = state.selectedCol;
    if (row == null || col == null) return;
    if (state.initialBoard[row][col] != null) return;

    final key = "$row-$col";

    // Handle note mode
    if (state.noteMode) {
      final notes = Map<String, Set<int>>.from(state.notes);
      notes.putIfAbsent(key, () => {});

      // Check impossible numbers
      final impossibleNumbers = getImpossibleNumbers(row, col, state.board);
      if (impossibleNumbers.contains(number)) return; // skip impossible note

      if (notes[key]!.contains(number)) {
        notes[key]!.remove(number);
      } else {
        notes[key]!.add(number);
      }

      emit(state.copyWith(notes: notes));
      return;
    }

    final previousValue = state.board[row][col];
    if (previousValue == number) return;

    final isMistake = state.fullBoard[row][col] != number;

    final newBoard = _deepCopyBoard(state.board);
    newBoard[row][col] = number;

    // Auto-update notes: remove `number` from row/col/box
    final newNotes = Map<String, Set<int>>.from(state.notes);
    for (int r = 0; r < 9; r++) {
      final k = "$r-$col";
      newNotes[k]?.remove(number);
    }
    for (int c = 0; c < 9; c++) {
      final k = "$row-$c";
      newNotes[k]?.remove(number);
    }
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        final k = "$r-$c";
        newNotes[k]?.remove(number);
      }
    }
    newNotes.remove(key); // remove notes from the current cell

    final move = Move(
      row: row,
      col: col,
      oldValue: previousValue,
      newValue: number,
      isMistake: isMistake,
    );

    _updateState(newBoard, move);
    emit(state.copyWith(notes: newNotes));
  }

  void erase() {
    if (state.status != GameStatus.playing) return;
    final row = state.selectedRow;
    final col = state.selectedCol;
    if (row == null || col == null) return;
    if (state.initialBoard[row][col] != null) return;

    final previousValue = state.board[row][col];
    if (previousValue == null) return;

    final newBoard = _deepCopyBoard(state.board);
    newBoard[row][col] = null;

    final move = Move(
      row: row,
      col: col,
      oldValue: previousValue,
      newValue: null,
      isMistake: false, // erasing itself is never a mistake
    );

    _updateState(newBoard, move);
  }

  void undo() {
    if (state.undoStack.isEmpty) return;
    final lastMove = state.undoStack.last;

    final newBoard = _deepCopyBoard(state.board);
    newBoard[lastMove.row][lastMove.col] = lastMove.oldValue;

    final newUndo = List<Move>.from(state.undoStack)..removeLast();
    final newRedo = List<Move>.from(state.redoStack)..add(lastMove);

    // ✅ Do NOT touch mistakes here (mistakes are permanent)
    _updateState(newBoard, null, undoStack: newUndo, redoStack: newRedo);
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    final nextMove = state.redoStack.last;

    final newBoard = _deepCopyBoard(state.board);
    newBoard[nextMove.row][nextMove.col] = nextMove.newValue;

    final newUndo = List<Move>.from(state.undoStack)..add(nextMove);
    final newRedo = List<Move>.from(state.redoStack)..removeLast();

    // ✅ Do NOT touch mistakes here
    _updateState(newBoard, null, undoStack: newUndo, redoStack: newRedo);
  }

  void _updateState(
    List<List<int?>> newBoard,
    Move? currentMove, {
    List<Move>? undoStack,
    List<Move>? redoStack,
    Map<String, Set<int>>? notes,
  }) {
    int newMistakes = state.mistakes;
    if (currentMove != null &&
        currentMove.isMistake &&
        currentMove.newValue != null) {
      newMistakes++; // mistakes only go UP
    }

    // Update correct cell count
    _correctCells = _countCorrectCells(newBoard, state.fullBoard);

    final conflicts = _findConflicts(newBoard, currentMove);

    emit(
      state.copyWith(
        board: newBoard,
        mistakes: newMistakes,
        conflicts: conflicts,
        undoStack:
            undoStack ??
            (currentMove != null
                ? [...state.undoStack, currentMove]
                : state.undoStack),
        redoStack: redoStack ?? (currentMove != null ? [] : state.redoStack),
        notes: notes ?? state.notes,
      ),
    );

    if (newMistakes >= state.maxMistakes) {
      _endGame(false);
      return;
    }

    _checkWin();
  }

  /// Optimized conflict detection: only check row/col/box of last move
  Set<String> _findConflicts(List<List<int?>> board, Move? move) {
    final conflicts = <String>{};

    if (move == null) return _findAllConflicts(board); // fallback

    final r = move.row;
    final c = move.col;
    final number = board[r][c];
    if (number == null) return conflicts;

    for (int i = 0; i < 9; i++) {
      if (i != c && board[r][i] == number) {
        conflicts.addAll(['$r-$c', '$r-$i']);
      }
      if (i != r && board[i][c] == number) {
        conflicts.addAll(['$r-$c', '$i-$c']);
      }
    }

    final boxRow = (r ~/ 3) * 3;
    final boxCol = (c ~/ 3) * 3;
    for (int br = boxRow; br < boxRow + 3; br++) {
      for (int bc = boxCol; bc < boxCol + 3; bc++) {
        if ((br != r || bc != c) && board[br][bc] == number) {
          conflicts.addAll(['$r-$c', '$br-$bc']);
        }
      }
    }
    return conflicts;
  }

  /// Full scan conflicts (used on game load)
  Set<String> _findAllConflicts(List<List<int?>> board) {
    final conflicts = <String>{};
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final number = board[r][c];
        if (number == null) continue;

        for (int i = 0; i < 9; i++) {
          if (i != c && board[r][i] == number) {
            conflicts.addAll(['$r-$c', '$r-$i']);
          }
          if (i != r && board[i][c] == number) {
            conflicts.addAll(['$r-$c', '$i-$c']);
          }
        }

        final boxRow = (r ~/ 3) * 3;
        final boxCol = (c ~/ 3) * 3;
        for (int br = boxRow; br < boxRow + 3; br++) {
          for (int bc = boxCol; bc < boxCol + 3; bc++) {
            if ((br != r || bc != c) && board[br][bc] == number) {
              conflicts.addAll(['$r-$c', '$br-$bc']);
            }
          }
        }
      }
    }
    return conflicts;
  }

  void _checkWin() {
    if (_correctCells == 81) {
      _endGame(true);
    }
  }

  void _endGame(bool won) {
    GameRepository.clearGame();
    emit(state.copyWith(status: won ? GameStatus.won : GameStatus.lost));
  }

  int _countCorrectCells(List<List<int?>> board, List<List<int?>> solution) {
    int count = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != null && board[r][c] == solution[r][c]) {
          count++;
        }
      }
    }
    return count;
  }

  void _recountCorrectCells(List<List<int?>> board) {
    _correctCells = _countCorrectCells(board, state.fullBoard);
  }

  List<List<int?>> _deepCopyBoard(List<List<int?>> board) =>
      board.map((row) => List<int?>.from(row)).toList();
}
