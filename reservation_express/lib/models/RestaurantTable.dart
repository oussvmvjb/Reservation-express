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
    print('🔄 Parsing table JSON: $json'); // Debug
    
    return RestaurantTable(
      id: json['id']?.toInt() ?? 0,
      tableNumber: json['tableNumber'] ?? '',
      capacity: json['capacity']?.toInt() ?? 0,
      location: json['location'],
      tableType: json['tableType'],
      status: json['status'] ?? 'available',
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble(),
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