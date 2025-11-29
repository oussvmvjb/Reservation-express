import 'package:flutter/material.dart';
import 'package:reservation_express/models/MenuItem.dart';
import '../services/api_service.dart';

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

  void _showItemDetails(MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
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
                  child: Text(item.description!),
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
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('Temps de préparation: ${item.preparationTime} min'),
                ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _addToCart(item);
                  },
                  child: Text('Ajouter au panier'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addToCart(MenuItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} ajouté au panier'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu du Restaurant'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtres par catégorie
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
                // Liste des articles
                Expanded(
                  child: _filteredItems.isEmpty
                      ? Center(
                          child: Text(
                            'Aucun article trouvé',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
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
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => _showItemDetails(item),
      ),
    );
  }
}