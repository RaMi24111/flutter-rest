import 'package:restaurant_admin/services/api_service.dart';
import 'package:restaurant_admin/core/constants.dart';
import 'package:restaurant_admin/core/models/restaurant_model.dart';

class RestaurantService {
  static Future<RestaurantProfile> getProfile() async {
    final data =
        await ApiService.get(ApiEndpoints.restaurant, requiresAuth: true);
    return RestaurantProfile.fromJson(data as Map<String, dynamic>);
  }
}
