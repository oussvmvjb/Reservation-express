import 'package:flutter/material.dart';
import 'package:reservation_express/models/Reservation.dart';
import 'package:reservation_express/models/RestaurantTable.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<Reservation> _reservations = [];
  Map<int, RestaurantTable> _tableCache = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final userId = await AuthService.getUserId();
      if (userId != null) {
        final reservations = await ApiService.getUserReservations(userId);

        await _loadMissingTables(reservations);

        setState(() {
          _reservations = reservations;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Utilisateur non connecté';
        });
        _showError('Utilisateur non connecté');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erreur de chargement: $e';
      });
      _showError('Erreur de chargement: $e');
    }
  }

  Future<void> _loadMissingTables(List<Reservation> reservations) async {

    for (var reservation in reservations) {
      if (reservation.table == null) {
        if (!_tableCache.containsKey(reservation.tableId)) {
          try {
            final table = await ApiService.getTableById(reservation.tableId);
            if (table != null) {
              _tableCache[reservation.tableId] = table;
              print('Table ${table.tableNumber} chargée avec succès');
            } else {
              print('Table ${reservation.tableId} non trouvée');
            }
          } catch (e) {
            print(
              'Erreur lors du chargement de la table ${reservation.tableId}: $e',
            );
          }
        }
      }
    }
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _cancelReservation(int reservationId, int tableId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer la réservation'),
          content: Text(
            'Êtes-vous sûr de vouloir SUPPRIMER cette réservation ?\n\n'
            'Cette action est irréversible !\n'
            'La réservation sera effacée et la table remise disponible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Non, garder'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                _showSuccess('Suppression en cours...');

                try {
                  final deleteResponse = await ApiService.deleteReservation(
                    reservationId,
                  );

                  if (deleteResponse.statusCode == 200) {
                    try {
                      final statusResponse = await ApiService.updateTableStatus(
                        tableId,
                        'available',
                      );

                      if (statusResponse.statusCode == 200) {
                        _showSuccess(
                          'Réservation supprimée et table remise disponible',
                        );
                      } else {
                        _showSuccess('Réservation supprimée');
                      }
                    } catch (tableError) {
                      
                      _showSuccess('Réservation supprimée');
                    }

                    await _loadReservations();
                  } else {
                    _showError(
                      ' Échec de la suppression: ${deleteResponse.statusCode}',
                    );
                  }
                } catch (error) {
                  _showError('Erreur lors de la suppression: $error');
                }
              },
              child: Text(
                'Oui, supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToTables() {
    Navigator.pushNamed(context, '/tables').then((_) {
      _loadReservations();
    });
  }

  RestaurantTable? _getTableForReservation(Reservation reservation) {
    if (reservation.table != null) {
      return reservation.table;
    }

    if (_tableCache.containsKey(reservation.tableId)) {
      return _tableCache[reservation.tableId];
    }

    return null;
  }

  String _getTableDisplay(Reservation reservation) {
    final table = _getTableForReservation(reservation);
    if (table != null) {
      return 'Table ${table.tableNumber}';
    } else {
      return 'Table #${reservation.tableId}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes Réservations',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadReservations,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                _isLoading
                    ? _buildLoadingState()
                    : _hasError
                    ? _buildErrorState()
                    : _reservations.isEmpty
                    ? _buildEmptyState()
                    : _buildReservationsList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Chargement de vos réservations...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadReservations,
            child: Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 100, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text(
            'Aucune réservation',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Vous n avez pas encore de réservation.\nRéservez votre première table dès maintenant!',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: _navigateToTables,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Voir les tables disponibles',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList() {
    return RefreshIndicator(
      onRefresh: _loadReservations,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 20),
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          final reservation = _reservations[index];
          return _buildReservationCard(reservation);
        },
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    final table = _getTableForReservation(reservation);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTableDisplay(reservation),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      if (table != null && table.location != null)
                        Text(
                          table.location!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reservation.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(
                        reservation.status,
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getStatusText(reservation.status),
                    style: TextStyle(
                      color: _getStatusColor(reservation.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            _buildDetailRow(
              Icons.calendar_today,
              'Date',
              reservation.getFormattedDate(),
            ),
            _buildDetailRow(
              Icons.access_time,
              'Heure',
              reservation.getFormattedTime(),
            ),
            _buildDetailRow(
              Icons.timer,
              'Durée',
              '${reservation.durationHours} heure(s)',
            ),
            _buildDetailRow(
              Icons.people,
              'Personnes',
              '${reservation.numberOfGuests}',
            ),
            _buildDetailRow(
              Icons.attach_money,
              'Prix total',
              '${reservation.totalPrice.toStringAsFixed(2)}€',
            ),

            if (table != null) ...[
              _buildDetailRow(
                Icons.chair,
                'Capacité',
                '${table.capacity} personnes',
              ),
              if (table.tableType != null && table.tableType!.isNotEmpty)
                _buildDetailRow(Icons.category, 'Type', table.tableType!),
            ],

            if (reservation.specialRequests != null &&
                reservation.specialRequests!.isNotEmpty)
              _buildDetailRow(
                Icons.note,
                'Demandes spéciales',
                reservation.specialRequests!,
              ),

            SizedBox(height: 16),

            if (reservation.status == 'confirmed')
              SizedBox(
                width: double.infinity,
                height: 45,
                child: OutlinedButton(
                  onPressed:
                      () => _cancelReservation(
                        reservation.id,
                        reservation.tableId,
                      ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Annuler la réservation',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
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

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmée';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulée';
      case 'completed':
        return 'Terminée';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
