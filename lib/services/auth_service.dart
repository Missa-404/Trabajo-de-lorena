import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'database_service.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  final DatabaseService _db = DatabaseService();

  Future<bool> register(String username, String password) async {
    try {
      User user = User(username: username, password: password);
      await _db.registerUser(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    User? user = await _db.loginUser(username, password);
    if (user != null && user.id != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_userIdKey, user.id!);
      await prefs.setString(_usernameKey, user.username);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<bool> isLoggedIn() async {
    return await getCurrentUserId() != null;
  }
}