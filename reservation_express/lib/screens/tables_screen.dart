import 'package:flutter/material.dart';
import 'package:reservation_express/models/RestaurantTable.dart';
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
        _filteredTables = _tables.where((table) => table.tableType == filter.toLowerCase()).toList();
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showTableDetails(RestaurantTable table) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Table ${table.tableNumber}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              _buildDetailRow('Capacité:', '${table.capacity} personnes'),
              _buildDetailRow('Type:', table.tableType),
              _buildDetailRow('Statut:', table.status),
              _buildDetailRow('Prix/heure:', '${table.pricePerHour}€'),
              if (table.locationDescription != null)
                _buildDetailRow('Emplacement:', table.locationDescription!),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _reserveTable(table);
                  },
                  child: Text('Réserver cette table'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  void _reserveTable(RestaurantTable table) {
    // Navigation vers l'écran de réservation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirection vers la réservation de la table ${table.tableNumber}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nos Tables'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtres
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Toutes', 'Disponibles', 'Indoor', 'Outdoor', 'VIP']
                          .map((filter) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(filter),
                                  selected: _selectedFilter == filter,
                                  onSelected: (selected) => _filterTables(filter),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                // Liste des tables
                Expanded(
                  child: _filteredTables.isEmpty
                      ? Center(
                          child: Text(
                            'Aucune table trouvée',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
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
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor(table.status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.table_restaurant,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Table ${table.tableNumber}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${table.capacity} personnes • ${table.tableType}'),
            Text(
              '${table.pricePerHour}€/heure',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            table.status,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          backgroundColor: _getStatusColor(table.status),
        ),
        onTap: () => _showTableDetails(table),
      ),
    );
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
}