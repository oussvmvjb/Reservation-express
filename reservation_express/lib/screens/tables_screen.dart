import 'package:flutter/material.dart';
import 'package:reservation_express/models/Reservation.dart';
import 'package:reservation_express/models/RestaurantTable.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

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

  // Variables pour la sélection de date et heure
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay(hour: 19, minute: 0);
  int _selectedDuration = 2;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  // Méthode safe pour setState — utilise "mounted"
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  Future<void> _loadTables() async {
    try {
      final tables = await ApiService.getTables();
      _safeSetState(() {
        _tables = tables;
        _filteredTables = tables;
        _isLoading = false;
      });
    } catch (e) {
      _safeSetState(() {
        _isLoading = false;
      });
      _showError('Erreur de chargement: $e');
    }
  }

  void _filterTables(String filter) {
    _safeSetState(() {
      _selectedFilter = filter;
      if (filter == 'Toutes') {
        _filteredTables = _tables;
      } else if (filter == 'Disponibles') {
        _filteredTables = _tables.where((table) => table.status == 'available').toList();
      } else {
        _filteredTables = _tables.where((table) => table.tableType?.toLowerCase() == filter.toLowerCase()).toList();
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context, {required DateTime initialDate}) async {
    final now = DateTime.now();

    final safeInitialDate = initialDate.isBefore(DateTime(now.year, now.month, now.day))
        ? now
        : initialDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(Duration(days: 365)),
      locale: Locale('fr', 'FR'),
    );

    return picked;
  }

  // Méthode pour sélectionner l'heure
  Future<TimeOfDay?> _selectTime(BuildContext context, {TimeOfDay? initialTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    return picked;
  }

  void _showTableDetails(RestaurantTable table) {
    // On ouvre la bottom sheet et on garde les sélections locales
    DateTime modalDate = _selectedDate;
    TimeOfDay modalTime = _selectedTime;
    int modalDuration = _selectedDuration;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
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

                      // Date/Time selection (uses modal's local variables)
                      _buildDateTimeSelection(
                        context,
                        setModalState,
                        table,
                        modalDate,
                        modalTime,
                        modalDuration,
                        (DateTime d) => setModalState(() => modalDate = d),
                        (TimeOfDay t) => setModalState(() => modalTime = t),
                        (int h) => setModalState(() => modalDuration = h),
                      ),

                      SizedBox(height: 20),
                      _buildDetailSectionWithLocalSelection(table, modalDuration),
                      SizedBox(height: 20),

                      // Action buttons
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: table.status == 'available'
                              ? () async {
                                  // Appeler la réservation tout en passant les valeurs locales
                                  final reserved = await _reserveTable(
                                    table,
                                    reservationDate: modalDate,
                                    reservationTime: modalTime,
                                    reservationDuration: modalDuration,
                                  );

                                  if (reserved) {
                                    // fermer la modal après réservation réussie
                                    if (mounted) Navigator.pop(context);
                                  }
                                }
                              : null,
                          child: Text(
                            table.status == 'available' ? 'Réserver cette table' : 'Indisponible',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: table.status == 'available' ? Colors.blue : Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateTimeSelection(
    BuildContext context,
    StateSetter setModalState,
    RestaurantTable table,
    DateTime modalDate,
    TimeOfDay modalTime,
    int modalDuration,
    ValueChanged<DateTime> onDateChanged,
    ValueChanged<TimeOfDay> onTimeChanged,
    ValueChanged<int> onDurationChanged,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails de la réservation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 16),

          // Sélection de la date
          _buildDateTimeRow(
            context,
            'Date',
            '${modalDate.day}/${modalDate.month}/${modalDate.year}',
            Icons.calendar_today,
            () async {
              final picked = await _selectDate(context, initialDate: modalDate);
              if (picked != null) onDateChanged(picked);
            },
          ),
          SizedBox(height: 12),

          // Sélection de l'heure
          _buildDateTimeRow(
            context,
            'Heure',
            '${modalTime.hour.toString().padLeft(2, '0')}:${modalTime.minute.toString().padLeft(2, '0')}',
            Icons.access_time,
            () async {
              final picked = await _selectTime(context, initialTime: modalTime);
              if (picked != null) onTimeChanged(picked);
            },
          ),
          SizedBox(height: 12),

          // Sélection de la durée
          _buildDurationSelectionLocal(modalDuration, onDurationChanged),
        ],
      ),
    );
  }

  Widget _buildDateTimeRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
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
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelectionLocal(int modalDuration, ValueChanged<int> onDurationChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durée',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [1, 2, 3, 4]
              .map((duration) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: duration < 4 ? 8 : 0),
                      child: ChoiceChip(
                        label: Text('$duration h'),
                        selected: modalDuration == duration,
                        onSelected: (selected) {
                          onDurationChanged(duration);
                        },
                        selectedColor: Colors.blue,
                        labelStyle: TextStyle(
                          color: modalDuration == duration ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTableImage(RestaurantTable table) {
    final color = _getTableColor(table.tableType);
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.7),
            color.withOpacity(0.9),
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
            _capitalize(table.tableType ?? 'Standard'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSectionWithLocalSelection(RestaurantTable table, int modalDuration) {
    final totalPrice = (table.pricePerHour ?? 0) * modalDuration;

    return Column(
      children: [
        _buildDetailRow('Capacité', '${table.capacity} personnes', Icons.people),
        _buildDetailRow('Type', _capitalize(table.tableType ?? 'Standard'), Icons.category),
        _buildDetailRow('Statut', _getStatusText(table.status), Icons.circle, color: _getStatusColor(table.status)),
        _buildDetailRow('Prix/heure', '${table.pricePerHour ?? 0}€', Icons.attach_money),
        _buildDetailRow('Durée', '$modalDuration heure${modalDuration > 1 ? 's' : ''}', Icons.timer),
        _buildDetailRow('Prix total', '${totalPrice}€', Icons.euro, color: Colors.green),
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
                    color: color ?? Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Réserve la table en utilisant des valeurs passées (locales de la modal)
  /// Retourne true si la réservation a réussi.
  Future<bool> _reserveTable(
    RestaurantTable table, {
    required DateTime reservationDate,
    required TimeOfDay reservationTime,
    required int reservationDuration,
  }) async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        _showError('Veuillez vous connecter pour réserver');
        return false;
      }

      // Formater la date et l'heure pour l'API
      final reservationDateTime = DateTime(
        reservationDate.year,
        reservationDate.month,
        reservationDate.day,
        reservationTime.hour,
        reservationTime.minute,
      );

      // Montrer la confirmation
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          final totalPrice = (table.pricePerHour ?? 0) * reservationDuration;
          return AlertDialog(
            title: Text('Confirmer la réservation'),
            content: Text(
              'Voulez-vous réserver la Table ${table.tableNumber} ?\n\n'
              '• Date: ${reservationDate.day}/${reservationDate.month}/${reservationDate.year}\n'
              '• Heure: ${reservationTime.hour.toString().padLeft(2, '0')}:${reservationTime.minute.toString().padLeft(2, '0')}\n'
              '• Durée: $reservationDuration heure${reservationDuration > 1 ? 's' : ''}\n'
              '• Capacité: ${table.capacity} personnes\n'
              '• Type: ${_capitalize(table.tableType ?? 'Standard')}\n'
              '• Prix total: ${totalPrice}€',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Confirmer', style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        },
      );

      if (confirm != true) return false;

      _showSuccess('⏳ Réservation en cours...');

      // 1. Mettre à jour le statut de la table dans la BD
      final statusResponse = await ApiService.updateTableStatus(table.id, 'reserved');

      if (statusResponse.statusCode != 200) {
        _showError('Erreur lors de la réservation de la table');
        return false;
      }

      // 2. Créer la réservation
      final totalPrice = (table.pricePerHour ?? 0) * reservationDuration;
      final reservationData = {
        "user": {"id": userId},
        "table": {"id": table.id},
        "reservationDate": reservationDateTime.toIso8601String().split('T')[0],
        "reservationTime": "${reservationTime.hour.toString().padLeft(2, '0')}:${reservationTime.minute.toString().padLeft(2, '0')}",
        "numberOfGuests": table.capacity,
        "durationHours": reservationDuration,
        "totalPrice": totalPrice,
        "status": "confirmed",
        "specialRequests": "Aucune demande particulière"
      };

      final reservationResponse = await ApiService.createReservation(reservationData);

      if (reservationResponse.statusCode == 201) {
        _showSuccess('✅ Table ${table.tableNumber} réservée avec succès!');
        // Recharger les tables
        await _loadTables();
        return true;
      } else {
        // Si la création échoue, remettre la table disponible
        await ApiService.updateTableStatus(table.id, 'available');
        _showError('Erreur lors de la création de la réservation');
        return false;
      }
    } catch (e) {
      // En cas d'erreur, essayer de remettre la table disponible
      try {
        await ApiService.updateTableStatus(table.id, 'available');
      } catch (_) {}
      _showError('Erreur lors de la réservation: $e');
      return false;
    }
  }

  Color _getTableColor(String? tableType) {
    switch (tableType?.toLowerCase()) {
      case 'vip':
        return Colors.purple;
      case 'outdoor':
        return Colors.green;
      case 'indoor':
        return Colors.blue;
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTables,
            tooltip: 'Actualiser',
          ),
        ],
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
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_tables.where((t) => t.status == 'available').length} disponible${_tables.where((t) => t.status == 'available').length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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
                      : RefreshIndicator(
                          onRefresh: _loadTables,
                          child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 16),
                            itemCount: _filteredTables.length,
                            itemBuilder: (context, index) {
                              final table = _filteredTables[index];
                              return _buildTableCard(table);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTableCard(RestaurantTable table) {
    bool isAvailable = table.status == 'available';

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
                      '${table.capacity} personnes • ${_capitalize(table.tableType ?? 'Standard')}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${table.pricePerHour ?? 0}€/heure',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        if (table.location != null && table.location!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              '• ${table.location}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
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