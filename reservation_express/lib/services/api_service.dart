import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reservation_express/models/MenuItem.dart';
import 'package:reservation_express/models/Order.dart';
import 'package:reservation_express/models/Reservation.dart';
import 'package:reservation_express/models/RestaurantTable.dart';
import 'package:reservation_express/models/user.dart';

class ApiService {
 static const String baseUrl = 'http://localhost:8080/api'; // Pour iOS/Web

  // Headers communs
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ========== AUTHENTIFICATION ==========

  /// Inscription d'un nouvel utilisateur
  static Future<http.Response> register(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: json.encode({
          'email': user.email,
          'password': user.password,
          'fullName': user.fullName,
          'phoneNumber': user.phoneNumber,
        }),
      );
      return response;
    } catch (e) {
      throw Exception('Erreur de connexion lors de l\'inscription: $e');
    }
  }

  /// Connexion d'un utilisateur
  static Future<http.Response> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      return response;
    } catch (e) {
      throw Exception('Erreur de connexion lors de la connexion: $e');
    }
  }

  /// Vérifier si un email existe déjà
  static Future<bool> checkEmailExists(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/check-email/$email'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Erreur de vérification email: $e');
    }
  }

  /// Vérifier la santé de l'API
  static Future<bool> checkApiHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ========== TABLES ==========

  static Future<List<RestaurantTable>> getTables() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tables'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => RestaurantTable.fromJson(json)).toList();
      } else {
        throw Exception('Échec du chargement des tables: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  static Future<List<RestaurantTable>> getAvailableTables() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tables/available'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => RestaurantTable.fromJson(json)).toList();
      } else {
        throw Exception('Échec du chargement des tables disponibles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  static Future<RestaurantTable?> getTableById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tables/$id'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RestaurantTable.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Échec du chargement de la table: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // ========== RÉSERVATIONS ==========

 static Future<http.Response> createReservation(Reservation reservation) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/reservations'),
        headers: headers,
        body: json.encode({
          'user': {'id': reservation.userId},
          'table': {'id': reservation.tableId},
          'reservationDate': reservation.reservationDate.toIso8601String().split('T')[0],
          'reservationTime': reservation.reservationTime,
          'numberOfGuests': reservation.numberOfGuests,
          'durationHours': reservation.durationHours,
          'specialRequests': reservation.specialRequests,
          'totalPrice': reservation.totalPrice,
          'status': reservation.status,
        }),
      );
    } catch (e) {
      throw Exception('Erreur de création de réservation: $e');
    }
  }

// Dans ApiService.dart
static Future<List<Reservation>> getUserReservations(int userId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations/user/$userId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('📊 Données brutes des réservations: $data');
      return data.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des réservations: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erreur réseau: $e');
  }
}

  static Future<http.Response> cancelReservation(int reservationId) async {
    try {
      return await http.put(
        Uri.parse('$baseUrl/reservations/$reservationId/cancel'),
        headers: headers,
      );
    } catch (e) {
      throw Exception('Erreur d\'annulation: $e');
    }
  }

  // ========== MENU ==========

  static Future<List<MenuItem>> getMenuItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menu'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => MenuItem.fromJson(json)).toList();
      } else {
        throw Exception('Échec du chargement du menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  static Future<List<MenuItem>> getMenuItemsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menu/category/$category'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => MenuItem.fromJson(json)).toList();
      } else {
        throw Exception('Échec du chargement des articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  static Future<List<String>> getMenuCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menu/categories'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((category) => category.toString()).toList();
      } else {
        throw Exception('Échec du chargement des catégories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // ========== COMMANDES ==========

  static Future<http.Response> createOrder(Order order) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
        body: json.encode({
          'reservation': {'id': order.reservationId},
          'user': {'id': order.userId},
          'table': {'id': order.tableId},
          'totalAmount': order.totalAmount,
        }),
      );
    } catch (e) {
      throw Exception('Erreur de création de commande: $e');
    }
  }

  static Future<List<Order>> getUserOrders(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/user/$userId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Échec du chargement des commandes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // ========== SANTÉ DE L'API ==========

  static Future<Map<String, dynamic>> getApiStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'status': 'DOWN', 'error': 'API non disponible'};
      }
    } catch (e) {
      return {'status': 'DOWN', 'error': e.toString()};
    }
  }
}