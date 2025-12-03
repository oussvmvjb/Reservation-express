import 'package:flutter/material.dart';
import 'package:reservation_express/models/MenuItem.dart';
import 'package:reservation_express/services/auth_service.dart';
import 'package:reservation_express/utils/menu_image_utils.dart';
import '../services/api_service.dart';
import 'dart:convert';

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

      final limitedItems =
          menuItems.length > 8 ? menuItems.sublist(0, 8) : menuItems;

      setState(() {
        _menuItems = limitedItems;
        _filteredItems = limitedItems;
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
        _filteredItems =
            _menuItems.where((item) => item.category == category).toList();
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
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
            final imagePath = MenuImageUtils.getMenuImage(
              item.category,
              item.name,
              imageUrl: item.imageUrl,
            );

            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${item.price}€',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[300],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  if (item.description != null && item.description!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        item.description!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),

                  if (item.ingredients != null && item.ingredients!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingrédients:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            item.ingredients!,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),

                  if (item.preparationTime != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            'Préparation: ${item.preparationTime} min',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Quantité',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: Icon(Icons.remove, color: Colors.blue),
                              ),
                              onPressed:
                                  quantity > 0
                                      ? () {
                                        _updateQuantity(item, quantity - 1);
                                        setSheetState(() {
                                          quantity = _getItemQuantity(item.id);
                                        });
                                      }
                                      : null,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                quantity.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child: Icon(Icons.add, color: Colors.white),
                              ),
                              onPressed: () {
                                _updateQuantity(item, quantity + 1);
                                setSheetState(() {
                                  quantity = _getItemQuantity(item.id);
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Total: ${(item.price * quantity).toStringAsFixed(2)}€',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
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
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: BorderSide(color: Colors.blue),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Continuer'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _cartItems.isNotEmpty ? _showCart : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart, size: 18),
                              SizedBox(width: 4),
                              Text('Commander (${_getTotalItemCount()})'),
                            ],
                          ),
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
        final existingIndex = _cartItems.indexWhere(
          (cartItem) => cartItem.menuItem.id == item.id,
        );
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
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Text(
                'Votre Commande',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              if (_cartItems.isEmpty)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Votre panier est vide',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ajoutez des articles du menu',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = _cartItems[index];
                      final imagePath = MenuImageUtils.getMenuImage(
                        cartItem.menuItem.category,
                        cartItem.menuItem.name,
                        imageUrl: cartItem.menuItem.imageUrl,
                      );

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: AssetImage(imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.menuItem.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${cartItem.menuItem.price}€ x ${cartItem.quantity}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${(cartItem.menuItem.price * cartItem.quantity).toStringAsFixed(2)}€',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _updateQuantity(cartItem.menuItem, 0);
                                      if (_cartItems.isEmpty) {
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ],
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
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_cartTotal.toStringAsFixed(2)}€',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
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
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Vider le panier'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirmOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Commander'),
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
      final userId = await AuthService.getUserId();

      if (userId == null) {
        _showError('Veuillez vous connecter pour commander');
        return;
      }

      final reservations = await ApiService.getUserReservations(userId);

      if (reservations.isEmpty) {
        _showError('Aucune réservation trouvée');
        return;
      }

      reservations.sort((a, b) => b.id.compareTo(a.id));
      final latestReservation = reservations.first;

      if (latestReservation.table == null) {
        _showError('Table non trouvée pour cette réservation');
        return;
      }

      final orderData = {
        "reservation": {"id": latestReservation.id},
        "user": {"id": userId},
        "table": {"id": latestReservation.table!.id},
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
        _showSuccess(
          'Commande créée pour la table ${latestReservation.table!.tableNumber}!',
        );
      } else {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Erreur: $e');
    }
  }

  String _formatItemsToJson() {
    final itemsList =
        _cartItems.map((cartItem) {
          return {
            "name": cartItem.menuItem.name,
            "price": cartItem.menuItem.price,
            "quantity": cartItem.quantity,
          };
        }).toList();

    return json.encode(itemsList);
  }

  String _formatItemsSummary() {
    return _cartItems
        .map((cartItem) {
          return '${cartItem.quantity}x ${cartItem.menuItem.name}';
        })
        .join(', ');
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
                tooltip: 'Voir le panier',
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
                    constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      _getTotalItemCount().toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          color: Colors.grey[50],
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  _categories
                                      .map(
                                        (category) => Container(
                                          margin: EdgeInsets.only(right: 8),
                                          child: FilterChip(
                                            label: Text(category),
                                            selected:
                                                _selectedCategory == category,
                                            onSelected:
                                                (selected) =>
                                                    _filterItems(category),
                                            backgroundColor: Colors.white,
                                            selectedColor: Colors.blue,
                                            checkmarkColor: Colors.white,
                                            labelStyle: TextStyle(
                                              color:
                                                  _selectedCategory == category
                                                      ? Colors.white
                                                      : Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Text(
                                '${_filteredItems.length} article${_filteredItems.length > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[800],
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_cartItems.length} dans le panier',
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

                        // Menu Items List
                        Expanded(
                          child:
                              _filteredItems.isEmpty
                                  ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.restaurant_menu,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Aucun article trouvé',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Essayez une autre catégorie',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : ListView.builder(
                                    padding: EdgeInsets.only(bottom: 16),
                                    itemCount: _filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final item = _filteredItems[index];
                                      return _buildMenuItemCard(item);
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    final quantity = _getItemQuantity(item.id);
    final imagePath = MenuImageUtils.getMenuImage(
      item.category,
      item.name,
      imageUrl: item.imageUrl,
    );

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showItemDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    if (item.description != null &&
                        item.description!.isNotEmpty)
                      Text(
                        item.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.price}€',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (item.preparationTime != null)
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 2),
                              Text(
                                '${item.preparationTime} min',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              if (quantity > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    quantity.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                  ),
                  child: Icon(Icons.add, size: 20, color: Colors.blue),
                ),
            ],
          ),
        ),
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
