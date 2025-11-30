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
// Dans ApiService.dart - AJOUTEZ CETTE MÉTHODE
static Future<http.Response> updateTableStatus(int tableId, String newStatus) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/tables/$tableId/status'),
      headers: headers,
      body: json.encode({
        'status': newStatus,
      }),
    );
    return response;
  } catch (e) {
    throw Exception('Erreur de mise à jour du statut de la table: $e');
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

// Dans ApiService.dart - CORRECTION de createReservation
static Future<http.Response> createReservation(Map<String, dynamic> reservationData) async {
  try {
    return await http.post(
      Uri.parse('$baseUrl/reservations'),
      headers: headers,
      body: json.encode(reservationData),
    );
  } catch (e) {
    throw Exception('Erreur de création de réservation: $e');
  }
}

static Future<List<Reservation>> getUserReservations(int userId) async {
  try {
    print('🌐 Appel API: $baseUrl/reservations/user/$userId');
    
    final response = await http.get(
      Uri.parse('$baseUrl/reservations/user/$userId'),
      headers: headers,
    );
    
    print('📡 Réponse API - Status: ${response.statusCode}');
    print('📡 Réponse API - Body: ${response.body}');
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('✅ ${data.length} réservations reçues de l\'API');
      
      List<Reservation> reservations = data.map((json) => Reservation.fromJson(json)).toList();
      
      // Debug détaillé
      for (var i = 0; i < reservations.length; i++) {
        final reservation = reservations[i];
        print('''
📋 Réservation ${i + 1}:
   - ID: ${reservation.id}
   - User ID: ${reservation.userId}
   - Table ID: ${reservation.tableId}
   - Table object: ${reservation.table != null ? 'PRÉSENT' : 'ABSENT'}
   - Table number: ${reservation.table?.tableNumber ?? 'N/A'}
   - Date: ${reservation.getFormattedDate()}
   - Heure: ${reservation.reservationTime}
   - Statut: ${reservation.status}
''');
      }
      
      return reservations;
    } else {
      throw Exception('Échec du chargement des réservations: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Erreur réseau lors du chargement des réservations: $e');
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
static Future<http.Response> createOrder(Map<String, dynamic> orderData) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: headers,
      body: json.encode(orderData),
    );
    return response;
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

static Future<Order?> getOrderById(int orderId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Order.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Échec du chargement de la commande: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erreur réseau: $e');
  }
}

static Future<http.Response> updateOrderStatus(int orderId, String status) async {
  try {
    return await http.put(
      Uri.parse('$baseUrl/orders/$orderId/status'),
      headers: headers,
      body: json.encode({'status': status}),
    );
  } catch (e) {
    throw Exception('Erreur de mise à jour du statut: $e');
  }
}

static Future<http.Response> cancelOrder(int orderId) async {
  try {
    return await http.put(
      Uri.parse('$baseUrl/orders/$orderId/cancel'),
      headers: headers,
    );
  } catch (e) {
    throw Exception('Erreur d\'annulation: $e');
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