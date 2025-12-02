class RestaurantTable {
  final int id;
  final String tableNumber;
  final int capacity;
  final String? location;
  final String? tableType;
  final String status;
  final double? pricePerHour;
  final String? imageUrl;
  final String? locationDescription;

  RestaurantTable({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    this.location,
    this.tableType,
    required this.status,
    this.pricePerHour,
    this.imageUrl,
    this.locationDescription,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    final priceRaw = json['pricePerHour'];
    if (priceRaw is num) {
      parsedPrice = priceRaw.toDouble();
    } else if (priceRaw is String) {
      parsedPrice = double.tryParse(priceRaw) ?? 0.0;
    }
    return RestaurantTable(
      id: json['id']?.toInt() ?? 0,
      tableNumber: json['tableNumber'] ?? '',
      capacity: json['capacity']?.toInt() ?? 0,
      location: json['location'],
      tableType: json['tableType'],
      status: json['status'] ?? 'available',
      pricePerHour: parsedPrice,
      imageUrl: json['imageUrl'],
      locationDescription: json['locationDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'capacity': capacity,
      'location': location,
      'tableType': tableType,
      'status': status,
      'pricePerHour': pricePerHour,
      'imageUrl': imageUrl,
      'locationDescription': locationDescription,
    };
  }
}
