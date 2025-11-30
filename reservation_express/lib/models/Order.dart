class Order {
  final int id;
  final int reservationId;
  final int userId;
  final int tableId;
  final String orderNumber;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final String? itemsJson;
  final String? itemsSummary;

  Order({
    required this.id,
    required this.reservationId,
    required this.userId,
    required this.tableId,
    required this.orderNumber,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    this.itemsJson,
    this.itemsSummary,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toInt() ?? 0,
      reservationId: json['reservation'] != null ? (json['reservation']['id']?.toInt() ?? 0) : 0,
      userId: json['user'] != null ? (json['user']['id']?.toInt() ?? 0) : 0,
      tableId: json['table'] != null ? (json['table']['id']?.toInt() ?? 0) : 0,
      orderNumber: json['orderNumber'] ?? '',
      orderDate: json['orderDate'] != null 
          ? DateTime.parse(json['orderDate'])
          : DateTime.now(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      itemsJson: json['itemsJson'],
      itemsSummary: json['itemsSummary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation': {'id': reservationId},
      'user': {'id': userId},
      'table': {'id': tableId},
      'orderNumber': orderNumber,
      'orderDate': orderDate.toIso8601String(),
      'totalAmount': totalAmount,
      'status': status,
      'itemsJson': itemsJson,
      'itemsSummary': itemsSummary,
    };
  }
}