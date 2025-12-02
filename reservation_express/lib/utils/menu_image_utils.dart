class MenuImageUtils {
  static const String baseImagePath = 'assets/images/menu/';

  static String getMenuImage(
    String? category,
    String? itemName, {
    String? imageUrl,
  }) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.toLowerCase().endsWith('.jpg') ||
          imageUrl.toLowerCase().endsWith('.png') ||
          imageUrl.toLowerCase().endsWith('.jpeg')) {
        return '$baseImagePath$imageUrl';
      }
    }

    final cat = category?.toLowerCase() ?? '';
    final name = itemName?.toLowerCase() ?? '';

    if (cat.contains('appetizer') || cat.contains('entrée')) {
      return '${baseImagePath}appetizer.jpg';
    } else if (cat.contains('main') || cat.contains('plat')) {
      return '${baseImagePath}main_course.jpg';
    } else if (cat.contains('salad') || cat.contains('salade')) {
      return '${baseImagePath}salad.jpg';
    } else if (cat.contains('dessert')) {
      return '${baseImagePath}dessert.jpg';
    } else if (cat.contains('drink') || cat.contains('boisson')) {
      return '${baseImagePath}drink.jpg';
    } else if (cat.contains('special') || cat.contains('spécial')) {
      return '${baseImagePath}special.jpg';
    }

    return '${baseImagePath}food.jpg';
  }
}
