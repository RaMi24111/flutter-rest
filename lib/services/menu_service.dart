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

  static Future<MenuItem> createItem(Map<String, dynamic> body) async {
    final data =
        await ApiService.post(ApiEndpoints.menuItems, body, requiresAuth: true);
    return MenuItem.fromJson(data);
  }

  static Future<void> deleteItem(String itemId) async {
    await ApiService.delete(ApiEndpoints.menuItemById(itemId),
        requiresAuth: true);
  }
}
