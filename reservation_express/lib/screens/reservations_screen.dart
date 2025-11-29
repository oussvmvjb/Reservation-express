import 'package:flutter/material.dart';
import 'package:reservation_express/models/Reservation.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<Reservation> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId != null) {
        final reservations = await ApiService.getUserReservations(userId);
        setState(() {
          _reservations = reservations;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showError('Utilisateur non connecté');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erreur de chargement: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _cancelReservation(int reservationId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Annuler la réservation'),
          content: Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Non'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await ApiService.cancelReservation(reservationId);
                  _showSuccess('Réservation annulée avec succès');
                  _loadReservations(); // Recharger la liste
                } catch (e) {
                  _showError('Erreur lors de l\'annulation: $e');
                }
              },
              child: Text('Oui', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Réservations'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucune réservation',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Réservez votre première table!',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = _reservations[index];
                    return _buildReservationCard(reservation);
                  },
                ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Table ${reservation.table?.tableNumber ?? 'N/A'}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    reservation.status,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(reservation.status),
                ),
              ],
            ),
            SizedBox(height: 8),
            _buildReservationDetail('Date:', _formatDate(reservation.reservationDate)),
            _buildReservationDetail('Heure:', _formatTime(reservation.reservationTime)),
            _buildReservationDetail('Durée:', '${reservation.durationHours} heures'),
            _buildReservationDetail('Personnes:', '${reservation.numberOfGuests}'),
            if (reservation.specialRequests != null && reservation.specialRequests!.isNotEmpty)
              _buildReservationDetail('Demandes spéciales:', reservation.specialRequests!),
            _buildReservationDetail('Prix total:', '${reservation.totalPrice}€'),
            SizedBox(height: 16),
            if (reservation.status == 'confirmed')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelReservation(reservation.id!),
                  child: Text('Annuler la réservation', style: TextStyle(color: Colors.red)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}