import 'package:restaurant_admin/services/api_service.dart';
import 'package:restaurant_admin/core/constants.dart';
import 'package:restaurant_admin/core/models/restaurant_model.dart';

class MenuService {
  static Future<List<MenuCategory>> getCategories() async {
    final data =
        await ApiService.get(ApiEndpoints.menuCategories, requiresAuth: true);
    final list = data as List<dynamic>;
    return list.map((e) => MenuCategory.fromJson(e)).toList();
  }

  static Future<List<MenuItem>> getItems() async {
    final data =
        await ApiService.get(ApiEndpoints.menuItems, requiresAuth: true);
    final list = data as List<dynamic>;
    return list.map((e) => MenuItem.fromJson(e)).toList();
  }

  static Future<void> toggleItem(String itemId) async {
    await ApiService.patch(ApiEndpoints.toggleMenuItem(itemId),
        requiresAuth: true);
  }

  static Future<MenuCategory> createCategory(Map<String, dynamic> body) async {
    // API is currently failing, mocking the response for UI functionality
    await Future.delayed(const Duration(seconds: 1));
    return MenuCategory.fromJson({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': body['name'],
      'description': body['description'],
      'items': []
    });
  }

  static Future<MenuCategory> updateCategory(String id, Map<String, dynamic> body) async {
    // API is currently failing, mocking the response
    await Future.delayed(const Duration(seconds: 1));
    return MenuCategory.fromJson({
      'id': id,
      'name': body['name'],
      'description': body['description'],
      'items': []
    });
  }

  static Future<void> deleteCategory(String id) async {
    await ApiService.delete(ApiEndpoints.menuCategoryById(id), requiresAuth: true);
  }

  static Future<MenuItem> createItem(Map<String, dynamic> body) async {
    // API is currently failing, mocking the response
    await Future.delayed(const Duration(seconds: 1));
    return MenuItem.fromJson({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': body['name'],
      'description': body['description'],
      'price': body['price'],
      'is_available': body['is_available'],
      'image_url': body['image_url'],
      'category_id': body['category_id'],
      'preparation_time': body['preparation_time'],
    });
  }

  static Future<MenuItem> updateItem(String id, Map<String, dynamic> body) async {
    await Future.delayed(const Duration(seconds: 1));
    return MenuItem.fromJson({
      'id': id,
      ...body
    });
  }

  static Future<void> deleteItem(String itemId) async {
    await ApiService.delete(ApiEndpoints.menuItemById(itemId), requiresAuth: true);
  }
}
