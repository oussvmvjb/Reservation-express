import 'package:flutter/material.dart';
import 'package:reservation_express/models/RestaurantTable.dart';
import 'user.dart';

class Reservation {
  final int? id;
  final int? userId;
  final int? tableId;
  final DateTime reservationDate;
  final String reservationTime; // Changé de TimeOfDay à String
  final int durationHours;
  final int numberOfGuests;
  final String? specialRequests;
  final String status;
  final double totalPrice;
  final User? user;
  final RestaurantTable? table;

  Reservation({
    this.id,
    this.userId,
    this.tableId,
    required this.reservationDate,
    required this.reservationTime, // Maintenant c'est un String
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
      'reservationDate': reservationDate.toIso8601String().split('T')[0],
      'reservationTime': reservationTime, // Déjà au format String
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
    // Gestion de la date
    DateTime reservationDate;
    if (json['reservationDate'] is String) {
      reservationDate = DateTime.parse(json['reservationDate']);
    } else {
      // Si c'est déjà un DateTime (peut arriver selon la sérialisation)
      reservationDate = DateTime.parse(json['reservationDate'].toString());
    }

    // Gestion du temps - maintenant c'est un String directement
    String reservationTime = json['reservationTime'] ?? '19:00';

    return Reservation(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? ''),
      tableId: json['tableId'] is int ? json['tableId'] : int.tryParse(json['tableId']?.toString() ?? ''),
      reservationDate: reservationDate,
      reservationTime: reservationTime, // Stocké comme String
      durationHours: json['durationHours'] is int ? json['durationHours'] : int.tryParse(json['durationHours']?.toString() ?? '2') ?? 2,
      numberOfGuests: json['numberOfGuests'] is int ? json['numberOfGuests'] : int.tryParse(json['numberOfGuests']?.toString() ?? '1') ?? 1,
      specialRequests: json['specialRequests'],
      status: json['status'] ?? 'confirmed',
      totalPrice: json['totalPrice'] is double ? json['totalPrice'] : double.tryParse(json['totalPrice']?.toString() ?? '0.0') ?? 0.0,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      table: json['table'] != null ? RestaurantTable.fromJson(json['table']) : null,
    );
  }

  // Méthode utilitaire pour convertir le String en TimeOfDay (si nécessaire pour l'affichage)
  TimeOfDay getReservationTimeAsTimeOfDay() {
    try {
      final parts = reservationTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 19, minute: 0); // Valeur par défaut
    }
  }

  // Méthode utilitaire pour formater l'heure
  String getFormattedTime() {
    return reservationTime; // Déjà au format HH:mm
  }

  // Méthode utilitaire pour formater la date
  String getFormattedDate() {
    return '${reservationDate.day}/${reservationDate.month}/${reservationDate.year}';
  }
}