import 'package:flutter/material.dart';
import 'package:reservation_express/models/MenuItem.dart';
import 'package:reservation_express/models/Order.dart';
import '../services/api_service.dart';
import 'dart:convert'; // Ajouter cette importation

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItem> _menuItems = [];
  List<MenuItem> _filteredItems = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String _selectedCategory = 'Toutes';
  
  // Panier d'achat
  List<CartItem> _cartItems = [];
  double _cartTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    try {
      final menuItems = await ApiService.getMenuItems();
      final categories = await ApiService.getMenuCategories();
      setState(() {
        _menuItems = menuItems;
        _filteredItems = menuItems;
        _categories = ['Toutes', ...categories];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erreur de chargement: $e');
    }
  }

  void _filterItems(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Toutes') {
        _filteredItems = _menuItems;
      } else {
        _filteredItems = _menuItems.where((item) => item.category == category).toList();
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showItemDetails(MenuItem item) {
    int quantity = _getItemQuantity(item.id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      item.name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      '${item.price}€',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (item.description != null && item.description!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        item.description!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (item.ingredients != null && item.ingredients!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Ingrédients: ${item.ingredients!}',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  if (item.preparationTime != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text('Temps de préparation: ${item.preparationTime} min'),
                    ),
                  
                  // Contrôle de quantité
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Quantité',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: quantity > 0 ? () {
                                _updateQuantity(item, quantity - 1);
                                setSheetState(() {
                                  quantity = _getItemQuantity(item.id);
                                });
                              } : null,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                quantity.toString(),
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                _updateQuantity(item, quantity + 1);
                                setSheetState(() {
                                  quantity = _getItemQuantity(item.id);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Continuer les achats'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _cartItems.isNotEmpty ? _showCart : null,
                          child: Text('Commander (${_getTotalItemCount()})'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // CORRECTION : Méthode simplifiée pour obtenir la quantité
  int _getItemQuantity(int itemId) {
    for (var cartItem in _cartItems) {
      if (cartItem.menuItem.id == itemId) {
        return cartItem.quantity;
      }
    }
    return 0;
  }

  void _updateQuantity(MenuItem item, int newQuantity) {
    setState(() {
      if (newQuantity == 0) {
        _cartItems.removeWhere((cartItem) => cartItem.menuItem.id == item.id);
      } else {
        final existingIndex = _cartItems.indexWhere((cartItem) => cartItem.menuItem.id == item.id);
        if (existingIndex >= 0) {
          _cartItems[existingIndex] = CartItem(item, newQuantity);
        } else {
          _cartItems.add(CartItem(item, newQuantity));
        }
      }
      _calculateTotal();
    });
    
    if (newQuantity == 0) {
      _showSuccess('${item.name} retiré du panier');
    } else if (newQuantity == 1) {
      _showSuccess('${item.name} ajouté au panier');
    } else {
      _showSuccess('${item.name} (x$newQuantity) dans le panier');
    }
  }

  void _calculateTotal() {
    _cartTotal = _cartItems.fold(0.0, (total, item) {
      return total + (item.menuItem.price * item.quantity);
    });
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Votre Commande',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              
              if (_cartItems.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Votre panier est vide',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = _cartItems[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.restaurant_menu, color: Colors.blue),
                          ),
                          title: Text(
                            cartItem.menuItem.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${cartItem.menuItem.price}€ x ${cartItem.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(cartItem.menuItem.price * cartItem.quantity).toStringAsFixed(2)}€',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _updateQuantity(cartItem.menuItem, 0);
                                  if (_cartItems.isEmpty) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
              if (_cartItems.isNotEmpty) ...[
                Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_cartTotal.toStringAsFixed(2)}€',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _cartItems.clear();
                            _cartTotal = 0.0;
                          });
                          Navigator.pop(context);
                          _showSuccess('Panier vidé');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                        ),
                        child: Text('Vider le panier'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirmOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Confirmer la commande'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmOrder() async {
    try {
      final userId = 1;
      final reservationId = 3; 
      final tableId = 1;
      
      final orderData = {
        "reservation": {"id": reservationId},
        "user": {"id": userId},
        "table": {"id": tableId},
        "totalAmount": _cartTotal,
        "status": "pending",
        "itemsJson": _formatItemsToJson(),
        "itemsSummary": _formatItemsSummary(),
      };

      final response = await ApiService.createOrder(orderData);
      
      if (response.statusCode == 201) {
        setState(() {
          _cartItems.clear();
          _cartTotal = 0.0;
        });
        Navigator.pop(context);
        _showSuccess('✅ Commande créée avec succès!');
      } else {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Erreur: $e');
    }
  }

  String _formatItemsToJson() {
    final itemsList = _cartItems.map((cartItem) {
      return {
        "name": cartItem.menuItem.name,
        "price": cartItem.menuItem.price,
        "quantity": cartItem.quantity,
      };
    }).toList();
    
    return json.encode(itemsList);
  }

  String _formatItemsSummary() {
    return _cartItems.map((cartItem) {
      return '${cartItem.quantity}x ${cartItem.menuItem.name}';
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu du Restaurant'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: _cartItems.isNotEmpty ? _showCart : null,
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _getTotalItemCount().toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories
                          .map((category) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(category),
                                  selected: _selectedCategory == category,
                                  onSelected: (selected) => _filterItems(category),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Aucun article trouvé',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return _buildMenuItemCard(item);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    final quantity = _getItemQuantity(item.id);
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            image: item.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(item.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: item.imageUrl == null
              ? Icon(Icons.restaurant_menu, color: Colors.grey[400])
              : null,
        ),
        title: Text(
          item.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description != null && item.description!.isNotEmpty)
              Text(
                item.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12),
              ),
            SizedBox(height: 4),
            Text(
              '${item.price}€',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 16,
              ),
            ),
          ],
        ),
        trailing: quantity > 0
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  quantity.toString(),
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => _showItemDetails(item),
      ),
    );
  }

  int _getTotalItemCount() {
    return _cartItems.fold(0, (total, item) => total + item.quantity);
  }
}

class CartItem {
  final MenuItem menuItem;
  int quantity;

  CartItem(this.menuItem, this.quantity);
}