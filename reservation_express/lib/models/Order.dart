import 'package:reservation_express/models/Reservation.dart';
import 'package:reservation_express/models/RestaurantTable.dart';

import 'user.dart';


class Order {
  final int? id;
  final int reservationId;
  final int userId;
  final int tableId;
  final String orderNumber;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final Reservation? reservation;
  final User? user;
  final RestaurantTable? table;

  Order({
    this.id,
    required this.reservationId,
    required this.userId,
    required this.tableId,
    required this.orderNumber,
    required this.orderDate,
    required this.totalAmount,
    this.status = 'pending',
    this.reservation,
    this.user,
    this.table,
  });

  // Conversion de l'objet Order en Map pour JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservationId': reservationId,
      'userId': userId,
      'tableId': tableId,
      'orderNumber': orderNumber,
      'orderDate': orderDate.toIso8601String(),
      'totalAmount': totalAmount,
      'status': status,
      'reservation': reservation?.toJson(),
      'user': user?.toJson(),
      'table': table?.toJson(),
    };
  }

  // Création d'un Order à partir d'un Map (JSON)
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      reservationId: json['reservationId'] ?? json['reservation']?['id'],
      userId: json['userId'] ?? json['user']?['id'],
      tableId: json['tableId'] ?? json['table']?['id'],
      orderNumber: json['orderNumber'],
      orderDate: DateTime.parse(json['orderDate']),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
      reservation: json['reservation'] != null ? Reservation.fromJson(json['reservation']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      table: json['table'] != null ? RestaurantTable.fromJson(json['table']) : null,
    );
  }
}