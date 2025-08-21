// data/models/move.dart
import 'package:equatable/equatable.dart';

class Move extends Equatable {
  final int row;
  final int col;
  final int? oldValue;
  final int? newValue;
  final bool isMistake;

  const Move({
    required this.row,
    required this.col,
    required this.oldValue,
    required this.newValue,
    required this.isMistake,
  });

  /// Creates a new [Move] instance by copying its values.
  Move copyWith({
    int? row,
    int? col,
    int? oldValue,
    int? newValue,
    bool? isMistake,
  }) {
    return Move(
      row: row ?? this.row,
      col: col ?? this.col,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      isMistake: isMistake ?? this.isMistake,
    );
  }

  /// Converts a [Move] instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'col': col,
      'oldValue': oldValue,
      'newValue': newValue,
      'isMistake': isMistake,
    };
  }

  /// Creates a [Move] instance from a JSON map.
  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      row: json['row'] as int,
      col: json['col'] as int,
      oldValue: json['oldValue'] as int?,
      newValue: json['newValue'] as int?,
      isMistake: json['isMistake'] as bool,
    );
  }

  @override
  List<Object?> get props => [row, col, oldValue, newValue, isMistake];
}
