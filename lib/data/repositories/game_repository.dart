import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/logic/cubit/game_state.dart';

class GameRepository {
  static const _keyCurrentGame = 'current_game';

  /// Save current game state to SharedPreferences
  static Future<void> saveGame(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyCurrentGame, jsonEncode(state.toJson()));
  }

  /// Load saved game state
  static Future<GameState?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyCurrentGame);
    if (jsonString == null) return null;
    return GameState.fromJson(jsonDecode(jsonString));
  }

  /// Delete saved game (after winning or quitting)
  static Future<void> clearGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentGame);
  }
}
