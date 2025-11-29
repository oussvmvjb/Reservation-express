class RestaurantTable {
  final int? id;
  final String tableNumber;
  final int capacity;
  final String tableType;
  final String status;
  final String? locationDescription;
  final double pricePerHour;
  final String? imageUrl;

  RestaurantTable({
    this.id,
    required this.tableNumber,
    required this.capacity,
    required this.tableType,
    required this.status,
    this.locationDescription,
    required this.pricePerHour,
    this.imageUrl,
  });

  // Conversion de l'objet RestaurantTable en Map pour JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'capacity': capacity,
      'tableType': tableType,
      'status': status,
      'locationDescription': locationDescription,
      'pricePerHour': pricePerHour,
      'imageUrl': imageUrl,
    };
  }

  // Création d'un RestaurantTable à partir d'un Map (JSON)
  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'],
      tableNumber: json['tableNumber'],
      capacity: json['capacity'],
      tableType: json['tableType'],
      status: json['status'],
      locationDescription: json['locationDescription'],
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}