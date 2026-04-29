// ─── Restaurant Model ────────────────────────────────────────────────────────
class RestaurantProfile {
  final String id;
  final String name;
  final String restaurantType;
  final String status;
  final String? address;
  final String? city;
  final String? phone;
  final String? description;

  RestaurantProfile({
    required this.id,
    required this.name,
    required this.restaurantType,
    required this.status,
    this.address,
    this.city,
    this.phone,
    this.description,
  });

  factory RestaurantProfile.fromJson(Map<String, dynamic> json) {
    return RestaurantProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Restaurant',
      restaurantType: json['restaurant_type']?.toString() ?? 'Fine Dining',
      status: json['status']?.toString() ?? 'INACTIVE',
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      phone: json['phone']?.toString(),
      description: json['description']?.toString(),
    );
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}

// ─── Menu Category Model ──────────────────────────────────────────────────────
class MenuCategory {
  final String id;
  final String name;
  final String? description;
  final List<MenuItem> items;

  MenuCategory({
    required this.id,
    required this.name,
    this.description,
    this.items = const [],
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return MenuCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      items: rawItems.map((i) => MenuItem.fromJson(i)).toList(),
    );
  }
}

class MenuItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final bool isAvailable;
  final String? imageUrl;
  final String categoryId;
  final String? preparationTime;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.isAvailable,
    this.imageUrl,
    required this.categoryId,
    this.preparationTime,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      isAvailable: json['is_available'] == true || json['is_available'] == 1,
      imageUrl: json['image_url']?.toString(),
      categoryId: json['category_id']?.toString() ?? '',
      preparationTime: json['preparation_time']?.toString(),
    );
  }
}

// ─── Staff Model ──────────────────────────────────────────────────────────────
class StaffMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final bool isActive;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.isActive,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'server',
      phone: json['phone']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}

// ─── Table Model ──────────────────────────────────────────────────────────────
class TableModel {
  final String id;
  final String tableNumber;
  final int capacity;
  final bool isActive;
  final String? qrCode;
  final String status; // 'EMPTY' or 'OCCUPIED'

  TableModel({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.isActive,
    this.qrCode,
    this.status = 'EMPTY',
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id']?.toString() ?? '',
      tableNumber: json['table_number']?.toString() ?? '',
      capacity: int.tryParse(json['capacity']?.toString() ?? '4') ?? 4,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      qrCode: (json['qr_token'] ?? json['qr_code'])?.toString(),
      status: json['table_status']?.toString().toUpperCase() ?? 'EMPTY',
    );
  }
}

// ─── Order Model ──────────────────────────────────────────────────────────────
class OrderModel {
  final String id;
  final String status;
  final String orderType;
  final double totalAmount;
  final String paymentStatus;
  final String createdAt;
  final String? tableNumber;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.status,
    required this.orderType,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
    this.tableNumber,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PLACED',
      orderType: json['order_type']?.toString() ?? 'DINE_IN',
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      paymentStatus: json['payment_status']?.toString() ?? 'UNPAID',
      createdAt: json['created_at']?.toString() ?? '',
      tableNumber: json['table_number']?.toString(),
      items: rawItems.map((i) => OrderItem.fromJson(i)).toList(),
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({required this.name, required this.quantity, required this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }
}

