import 'package:shared_preferences/shared_preferences.dart';

class CoinsStorage {
  static const String _coinsKey = 'userCoins';

  static Future<void> saveCoins(double coins) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(_coinsKey, coins);
  }

  static Future<double> loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_coinsKey) ?? 0.0; // Default to 0 if not found
  }
}
