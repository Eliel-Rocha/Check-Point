import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class UserPreferencesService {
  static List<Color> _themeColor = [Colors.blueGrey];

  static Future<sql.Database> _getDatabase() async {
    return sql.openDatabase(
      'userPreferences.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await database.execute("""
          CREATE TABLE IF NOT EXISTS userPreferences(
            id INTEGER PRIMARY KEY,
            theme TEXT
          )
        """);
        _resetToDefaults();
        await database.insert('userPreferences', {
          'id': 1,
          'theme': _colorsToString(_themeColor),
        });
      },
    );
  }

  static Future<void> _updateDatabase({List<Color>? theme}) async {
    final db = await _getDatabase();
    _themeColor = theme ?? _themeColor;

    final data = {
      'theme': _colorsToString(_themeColor),
    };

    await db.update(
      'userPreferences',
      data,
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  static Future<void> loadPreferences() async {
    try {
      final db = await _getDatabase();
      final List<Map<String, dynamic>> preferences =
      await db.query('userPreferences', where: 'id = ?', whereArgs: [1]);

      if (preferences.isNotEmpty) {
        if (preferences.first['theme'].isEmpty){
          _resetToDefaults();
        }else {
          _themeColor = _stringToColors(preferences.first['theme']);
        }
      }
    } catch (e) {
      print("Erro ao carregar preferências: $e");
      _resetToDefaults();
    }
  }

  static void _resetToDefaults() {
    _themeColor = [
      Color(0xFFFF9933),
      Color(0xFF663399)
    ];
  }

  static String _colorToString(Color color) => color.value.toString();

  static Color _stringToColor(String colorString) =>
      Color(int.parse(colorString));

  static String _colorsToString(List<Color> colors) {
    return colors.map(_colorToString).join(';');
  }

  static List<Color> _stringToColors(String colorString) {
    return colorString
        .split(';')
        .map((s) => _stringToColor(s))
        .toList();
  }


  static List<Color> getThemeColor() => _themeColor;

  static Future<void> setThemeColor(List<Color> color) async {
    await _updateDatabase(theme: color);
  }
}
