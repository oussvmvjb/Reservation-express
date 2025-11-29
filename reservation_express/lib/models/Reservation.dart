import 'package:flutter/material.dart';
import 'package:reservation_express/models/RestaurantTable.dart';
import 'user.dart';


class Reservation {
  final int? id;
  final int userId;
  final int tableId;
  final DateTime reservationDate;
  final TimeOfDay reservationTime;
  final int durationHours;
  final int numberOfGuests;
  final String? specialRequests;
  final String status;
  final double totalPrice;
  final User? user;
  final RestaurantTable? table;

  Reservation({
    this.id,
    required this.userId,
    required this.tableId,
    required this.reservationDate,
    required this.reservationTime,
    this.durationHours = 2,
    required this.numberOfGuests,
    this.specialRequests,
    this.status = 'confirmed',
    required this.totalPrice,
    this.user,
    this.table,
  });

  // Conversion de l'objet Reservation en Map pour JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tableId': tableId,
      'reservationDate': reservationDate.toIso8601String(),
      'reservationTime': '${reservationTime.hour.toString().padLeft(2, '0')}:${reservationTime.minute.toString().padLeft(2, '0')}',
      'durationHours': durationHours,
      'numberOfGuests': numberOfGuests,
      'specialRequests': specialRequests,
      'status': status,
      'totalPrice': totalPrice,
      'user': user?.toJson(),
      'table': table?.toJson(),
    };
  }

  // Création d'une Reservation à partir d'un Map (JSON)
  factory Reservation.fromJson(Map<String, dynamic> json) {
    // Parsing du temps
    final timeString = json['reservationTime'] as String;
    final timeParts = timeString.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return Reservation(
      id: json['id'],
      userId: json['userId'] ?? json['user']?['id'],
      tableId: json['tableId'] ?? json['table']?['id'],
      reservationDate: DateTime.parse(json['reservationDate']),
      reservationTime: TimeOfDay(hour: hour, minute: minute),
      durationHours: json['durationHours'] ?? 2,
      numberOfGuests: json['numberOfGuests'],
      specialRequests: json['specialRequests'],
      status: json['status'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      table: json['table'] != null ? RestaurantTable.fromJson(json['table']) : null,
    );
  }
}