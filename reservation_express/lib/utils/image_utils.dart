class ImageUtils {
  static const String baseImagePath = 'assets/images/tables/';

  static String getTableImage(String? tableType, {String? imageUrl}) {
    // If there's a specific image URL in database, use it
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Check if it's a local asset (ends with .jpg/.png/.jpeg)
      if (imageUrl.toLowerCase().endsWith('.jpg') ||
          imageUrl.toLowerCase().endsWith('.png') ||
          imageUrl.toLowerCase().endsWith('.jpeg')) {
        return '$baseImagePath$imageUrl';
      }
    }

    // Otherwise, use default based on table type
    switch (tableType?.toLowerCase()) {
      case 'indoor':
        return '${baseImagePath}indoor_table.jpg';
      case 'outdoor':
        return '${baseImagePath}outdoor_table.jpg';
      case 'vip':
        return '${baseImagePath}vip_table.jpg';
      case 'bar':
        return '${baseImagePath}bar_table.jpg';
      case 'private':
        return '${baseImagePath}private_table.jpg';
      default:
        return '${baseImagePath}indoor_table.jpg'; // Default fallback
    }
  }
}
