import 'package:flutter/material.dart';
import 'package:reservation_express/models/Reservation.dart';
import 'package:reservation_express/models/RestaurantTable.dart';
import 'package:reservation_express/models/user.dart';
import '../services/api_service.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  _TablesScreenState createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  List<RestaurantTable> _tables = [];
  List<RestaurantTable> _filteredTables = [];
  bool _isLoading = true;
  String _selectedFilter = 'Toutes';

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    try {
      final tables = await ApiService.getTables();
      setState(() {
        _tables = tables;
        _filteredTables = tables;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erreur de chargement: $e');
    }
  }

  void _filterTables(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'Toutes') {
        _filteredTables = _tables;
      } else if (filter == 'Disponibles') {
        _filteredTables = _tables.where((table) => table.status == 'available').toList();
      } else {
        _filteredTables = _tables.where((table) => table.tableType.toLowerCase() == filter.toLowerCase()).toList();
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTableDetails(RestaurantTable table) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView( // AJOUT DU SCROLL ICI AUSSI
            child: Column(
              children: [
                // Handle
                Container(
                  margin: EdgeInsets.only(top: 10),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Table ${table.tableNumber}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTableImage(table),
                      SizedBox(height: 20),
                      _buildDetailSection(table),
                      SizedBox(height: 20),
                      _buildActionButton(table),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableImage(RestaurantTable table) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _getTableColor(table.tableType),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getTableColor(table.tableType).withOpacity(0.7),
            _getTableColor(table.tableType).withOpacity(0.9),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_restaurant,
            size: 50,
            color: Colors.white,
          ),
          SizedBox(height: 8),
          Text(
            'Table ${table.tableNumber}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _capitalize(table.tableType),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(RestaurantTable table) {
    return Column(
      children: [
        _buildDetailRow('Capacité', '${table.capacity} personnes', Icons.people),
        _buildDetailRow('Type', _capitalize(table.tableType), Icons.category),
        _buildDetailRow('Statut', _getStatusText(table.status), Icons.circle, 
            color: _getStatusColor(table.status)),
        _buildDetailRow('Prix/heure', '${table.pricePerHour}€', Icons.attach_money),
        if (table.locationDescription != null && table.locationDescription!.isNotEmpty)
          _buildDetailRow('Emplacement', table.locationDescription!, Icons.location_on),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? color}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.blue, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(RestaurantTable table) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          _reserveTable(table);
        },
        child: Text(
          'Réserver cette table',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }



void _reserveTable(RestaurantTable table) async {
  try {
    // Récupérer l'utilisateur connecté (à adapter selon votre gestion d'authentification)
    final currentUser = await _getCurrentUser();
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez vous connecter pour réserver'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calculer le prix total
    final totalPrice = table.pricePerHour * 2; // Durée par défaut de 2 heures

    // Créer la réservation
    final reservation = Reservation(
      userId: currentUser.id,
      tableId: table.id,
      reservationDate: DateTime.now().add(Duration(days: 1)), // Demain par défaut
      reservationTime: '19:00', // Heure par défaut
      numberOfGuests: 2, // Nombre de guests par défaut
      durationHours: 2,
      totalPrice: totalPrice,
      status: 'confirmed',
    );

    final response = await ApiService.createReservation(reservation);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Table ${table.tableNumber} réservée avec succès!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      throw Exception('Erreur serveur: ${response.statusCode}');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur lors de la réservation: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Méthode pour récupérer l'utilisateur connecté (à adapter)
Future<User?> _getCurrentUser() async {
  // Implémentez cette méthode selon votre système d'authentification
  // Exemple simplifié :
  return User(
    id: 1, // Remplacer par l'ID réel de l'utilisateur connecté
    fullName: 'Utilisateur Test',
    email: 'test@example.com', password: '', phoneNumber: '',
  );
}

  Color _getTableColor(String tableType) {
    switch (tableType.toLowerCase()) {
      case 'vip':
        return Colors.purple;
      case 'outdoor':
        return Colors.green;
      case 'indoor':
      default:
        return Colors.blue;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Disponible';
      case 'reserved':
        return 'Réservée';
      case 'occupied':
        return 'Occupée';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'reserved':
        return Colors.orange;
      case 'occupied':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nos Tables',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Chargement des tables...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Filtres
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Toutes', 'Disponibles', 'Indoor', 'Outdoor', 'VIP']
                          .map((filter) => Container(
                                margin: EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(filter),
                                  selected: _selectedFilter == filter,
                                  onSelected: (selected) => _filterTables(filter),
                                  backgroundColor: Colors.white,
                                  selectedColor: Colors.blue,
                                  checkmarkColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: _selectedFilter == filter ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                // Compteur
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        '${_filteredTables.length} table${_filteredTables.length > 1 ? 's' : ''} trouvée${_filteredTables.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Liste des tables
                Expanded(
                  child: _filteredTables.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.table_restaurant_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucune table trouvée',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Essayez de changer les filtres',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: 16),
                          itemCount: _filteredTables.length,
                          itemBuilder: (context, index) {
                            final table = _filteredTables[index];
                            return _buildTableCard(table);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTableCard(RestaurantTable table) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showTableDetails(table),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon de la table
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getStatusColor(table.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.table_restaurant,
                  color: _getStatusColor(table.status),
                  size: 30,
                ),
              ),
              SizedBox(width: 16),
              // Informations de la table
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Table ${table.tableNumber}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${table.capacity} personnes • ${_capitalize(table.tableType)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${table.pricePerHour}€/heure',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              // Statut
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(table.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(table.status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getStatusText(table.status),
                  style: TextStyle(
                    color: _getStatusColor(table.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}