import 'package:shared_preferences/shared_preferences.dart';

class XPStorage {
  static const String _xpKey = 'userXP';

  static Future<void> saveXP(double xp) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(_xpKey, xp);
  }

  static Future<double> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_xpKey) ?? 0.0;
  }
}
