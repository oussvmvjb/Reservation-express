import 'package:reservation_express/models/RestaurantTable.dart';

class Reservation {
  final int id;
  final int userId;
  final int tableId;
  final RestaurantTable? table;
  final DateTime reservationDate;
  final String reservationTime;
  final int numberOfGuests;
  final int durationHours;
  final String? specialRequests;
  final double totalPrice;
  final String status;

  Reservation({
    required this.id,
    required this.userId,
    required this.tableId,
    this.table,
    required this.reservationDate,
    required this.reservationTime,
    required this.numberOfGuests,
    required this.durationHours,
    this.specialRequests,
    required this.totalPrice,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    print('🔄 Parsing reservation JSON: $json'); // Debug
    
    return Reservation(
      id: json['id']?.toInt() ?? 0,
      userId: json['user'] != null ? (json['user']['id']?.toInt() ?? 0) : 0,
      tableId: json['table'] != null ? (json['table']['id']?.toInt() ?? 0) : 0,
      table: json['table'] != null ? RestaurantTable.fromJson(json['table']) : null,
      reservationDate: DateTime.parse(json['reservationDate']),
      reservationTime: json['reservationTime'] ?? '',
      numberOfGuests: json['numberOfGuests']?.toInt() ?? 0,
      durationHours: json['durationHours']?.toInt() ?? 2,
      specialRequests: json['specialRequests'],
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
    );
  }

  String getFormattedDate() {
    return '${reservationDate.day}/${reservationDate.month}/${reservationDate.year}';
  }

  String getFormattedTime() {
    return reservationTime;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': {'id': userId},
      'table': {'id': tableId},
      'reservationDate': reservationDate.toIso8601String().split('T')[0],
      'reservationTime': reservationTime,
      'numberOfGuests': numberOfGuests,
      'durationHours': durationHours,
      'specialRequests': specialRequests,
      'totalPrice': totalPrice,
      'status': status,
    };
  }
  
}