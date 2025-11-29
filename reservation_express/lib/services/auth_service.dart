import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';

  // Sauvegarder les données utilisateur
  static Future<void> saveUserData(
    int userId,
    String email,
    String name,
    String phone,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userPhoneKey, phone);
  }

  // Récupérer l'ID utilisateur
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Récupérer l'email utilisateur
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Récupérer le nom utilisateur
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Récupérer le téléphone utilisateur
  static Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhoneKey);
  }

  // Récupérer toutes les données utilisateur
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt(_userIdKey),
      'email': prefs.getString(_userEmailKey),
      'name': prefs.getString(_userNameKey),
      'phone': prefs.getString(_userPhoneKey),
    };
  }

  // Déconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPhoneKey);
  }

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userIdKey) && prefs.getInt(_userIdKey) != null;
  }

  // Vérifier la validité de la session
  static Future<bool> isValidSession() async {
    if (!await isLoggedIn()) {
      return false;
    }
    
    final userId = await getUserId();
    final userEmail = await getUserEmail();
    
    return userId != null && userEmail != null && userEmail.isNotEmpty;
  }

  // Nettoyer les données utilisateur (en cas de corruption)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}