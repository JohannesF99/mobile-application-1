import 'package:shared_preferences/shared_preferences.dart';

/// Hilfsklasse, welche die Verwendung von 'Shared Preferences'
/// vereinfacht, indem es nützliche Methoden für die häufigsten Use-Cases
/// bereit stellt.
class StorageManager {
  /// Methode, um ein neues Key-Value-Paar in den Shared Preferences zu
  /// speichern.
  static void saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is int) {
      prefs.setInt(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    }
  }

  /// Methode, um ein existierendes Key-Value-Paar der Shared Preferences
  /// zu lesen.
  static Future<dynamic> readData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    dynamic obj = prefs.get(key);
    return obj;
  }

  /// Methode, um ein existierendes Key-Value-Paar aus den Shared Preferences
  /// zu löschen.
  static Future<bool> deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  /// Löscht jeglichen Inhalt aus den Shared Preferences.
  static void clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}