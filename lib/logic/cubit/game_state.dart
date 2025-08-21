// game_state.dart
import 'package:equatable/equatable.dart';
import 'package:sudoku/data/models/move.dart';

enum GameStatus { loading, playing, won, lost, error }

class GameState extends Equatable {
  final List<List<int?>> board;
  final List<List<int?>> fullBoard;
  final List<List<int?>> initialBoard;
  final Map<String, Set<int>> notes;
  final Set<String> conflicts;

  final int? selectedRow;
  final int? selectedCol;
  final bool noteMode;

  final int mistakes;
  final int maxMistakes;
  final int secondsElapsed;
  final GameStatus status;

  final List<Move> undoStack;
  final List<Move> redoStack;

  const GameState({
    required this.board,
    required this.fullBoard,
    required this.initialBoard,
    required this.notes,
    required this.conflicts,
    this.selectedRow,
    this.selectedCol,
    this.noteMode = false,
    this.mistakes = 0,
    this.maxMistakes = 3,
    this.secondsElapsed = 0,
    this.status = GameStatus.loading,
    this.undoStack = const [],
    this.redoStack = const [],
  });

  GameState copyWith({
    List<List<int?>>? board,
    List<List<int?>>? fullBoard,
    List<List<int?>>? initialBoard,
    Map<String, Set<int>>? notes,
    Set<String>? conflicts,
    int? selectedRow,
    int? selectedCol,
    bool? noteMode,
    int? mistakes,
    int? maxMistakes,
    int? secondsElapsed,
    GameStatus? status,
    List<Move>? undoStack,
    List<Move>? redoStack,
  }) {
    return GameState(
      board: board ?? this.board,
      fullBoard: fullBoard ?? this.fullBoard,
      initialBoard: initialBoard ?? this.initialBoard,
      notes: notes ?? this.notes,
      conflicts: conflicts ?? this.conflicts,
      selectedRow: selectedRow ?? this.selectedRow,
      selectedCol: selectedCol ?? this.selectedCol,
      noteMode: noteMode ?? this.noteMode,
      mistakes: mistakes ?? this.mistakes,
      maxMistakes: maxMistakes ?? this.maxMistakes,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      status: status ?? this.status,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }

  /// Converts a GameState instance to a JSON map for serialization.
  Map<String, dynamic> toJson() {
    return {
      'board': board.map((row) => row.map((e) => e).toList()).toList(),
      'fullBoard': fullBoard.map((row) => row.map((e) => e).toList()).toList(),
      'initialBoard': initialBoard
          .map((row) => row.map((e) => e).toList())
          .toList(),
      'notes': notes.map((key, value) => MapEntry(key, value.toList())),
      'conflicts': conflicts.toList(),
      'selectedRow': selectedRow,
      'selectedCol': selectedCol,
      'noteMode': noteMode,
      'mistakes': mistakes,
      'maxMistakes': maxMistakes,
      'secondsElapsed': secondsElapsed,
      'status': status.name,
      'undoStack': undoStack.map((move) => move.toJson()).toList(),
      'redoStack': redoStack.map((move) => move.toJson()).toList(),
    };
  }

  /// Creates a GameState instance from a JSON map.
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      board: (json['board'] as List)
          .map((row) => (row as List).map((e) => e as int?).toList())
          .toList(),
      fullBoard: (json['fullBoard'] as List)
          .map((row) => (row as List).map((e) => e as int?).toList())
          .toList(),
      initialBoard: (json['initialBoard'] as List)
          .map((row) => (row as List).map((e) => e as int?).toList())
          .toList(),
      notes: (json['notes'] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, (value as List).map((e) => e as int).toSet()),
      ),
      conflicts: (json['conflicts'] as List).map((e) => e as String).toSet(),
      selectedRow: json['selectedRow'] as int?,
      selectedCol: json['selectedCol'] as int?,
      noteMode: json['noteMode'] as bool,
      mistakes: json['mistakes'] as int,
      maxMistakes: json['maxMistakes'] as int,
      secondsElapsed: json['secondsElapsed'] as int,
      status: GameStatus.values.firstWhere((e) => e.name == json['status']),
      undoStack: (json['undoStack'] as List)
          .map((e) => Move.fromJson(e))
          .toList(),
      redoStack: (json['redoStack'] as List)
          .map((e) => Move.fromJson(e))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    board,
    fullBoard,
    initialBoard,
    notes,
    conflicts,
    selectedRow,
    selectedCol,
    noteMode,
    mistakes,
    maxMistakes,
    secondsElapsed,
    status,
    undoStack,
    redoStack,
  ];
}
