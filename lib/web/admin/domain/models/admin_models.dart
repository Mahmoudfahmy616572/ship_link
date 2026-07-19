// موديلات لوحات الأدمن (بديل آمن عن Map<String, dynamic>)

class AdminUser {
  final String? id;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? role;
  final String? createdAt;

  AdminUser({this.id, this.name, this.email, this.phoneNumber, this.role, this.createdAt});

  factory AdminUser.fromMap(Map<String, dynamic> m) => AdminUser(
        id: m['id']?.toString(),
        name: m['name']?.toString().isNotEmpty == true ? m['name'].toString() : '${m['first_name'] ?? ''} ${m['last_name'] ?? ''}'.trim(),
        email: m['email']?.toString(),
        phoneNumber: m['phone_number']?.toString(),
        role: m['role']?.toString() ?? 'user',
        createdAt: m['created_at']?.toString(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'role': role,
        'created_at': createdAt,
      };
}

class AdminDriver {
  final String? id;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? state;
  final String? createdAt;

  AdminDriver({this.id, this.name, this.email, this.phoneNumber, this.vehicleType, this.vehicleNumber, this.state, this.createdAt});

  factory AdminDriver.fromMap(Map<String, dynamic> m) => AdminDriver(
        id: m['id']?.toString(),
        name: m['name']?.toString(),
        email: m['email']?.toString(),
        phoneNumber: m['phone_number']?.toString(),
        vehicleType: m['vehicle_type']?.toString(),
        vehicleNumber: m['vehicle_number']?.toString(),
        state: m['state']?.toString(),
        createdAt: m['created_at']?.toString(),
      );

  bool get hasVehicle => vehicleNumber != null && vehicleNumber!.isNotEmpty;
}

class AdminProduct {
  final int? id;
  final String? name;
  final String? description;
  final String? image;
  final List<dynamic> images;
  final num? price;
  final bool isOffer;
  final num? newPrice;
  final int qty;
  final int status;
  final int popular;
  final bool isTopSeller;
  final String? category;
  final String? createdAt;

  AdminProduct({
    this.id,
    this.name,
    this.description,
    this.image,
    this.images = const [],
    this.price,
    this.isOffer = false,
    this.newPrice,
    this.qty = 0,
    this.status = 1,
    this.popular = 0,
    this.isTopSeller = false,
    this.category,
    this.createdAt,
  });

  factory AdminProduct.fromMap(Map<String, dynamic> m) => AdminProduct(
        id: m['id'] is int ? m['id'] : (m['id'] != null ? int.tryParse(m['id'].toString()) : null),
        name: m['name']?.toString(),
        description: m['description']?.toString(),
        image: m['image']?.toString(),
        images: m['images'] is List ? List<dynamic>.from(m['images']) : const [],
        price: m['price'] is num ? m['price'] : (m['price'] != null ? num.tryParse(m['price'].toString()) : null),
        isOffer: m['is_offer'] == true,
        newPrice: m['new_price'] is num ? m['new_price'] : (m['new_price'] != null ? num.tryParse(m['new_price'].toString()) : null),
        qty: m['qty'] is int ? m['qty'] : (m['qty'] != null ? int.tryParse(m['qty'].toString()) ?? 0 : 0),
        status: m['status'] is int ? m['status'] : (m['status'] != null ? int.tryParse(m['status'].toString()) ?? 1 : 1),
        popular: m['popular'] is int ? m['popular'] : (m['popular'] != null ? int.tryParse(m['popular'].toString()) ?? 0 : 0),
        isTopSeller: m['is_top_seller'] == true,
        category: m['category']?.toString(),
        createdAt: m['created_at']?.toString(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'image': image,
        'images': images,
        'price': price,
        'is_offer': isOffer,
        'new_price': isOffer ? newPrice : null,
        'qty': qty,
        'status': status,
        'popular': popular,
        'is_top_seller': isTopSeller,
        'category': category,
      };
}

class AdminOrder {
  final int? id;
  final String? userId;
  final String? driverId;
  final num? totalPrice;
  final String? status;
  final String? createdAt;
  final String? customerName;
  final String? phoneNumber;
  final String? deliveryAddress;

  AdminOrder({
    this.id,
    this.userId,
    this.driverId,
    this.totalPrice,
    this.status,
    this.createdAt,
    this.customerName,
    this.phoneNumber,
    this.deliveryAddress,
  });

  factory AdminOrder.fromMap(Map<String, dynamic> m) => AdminOrder(
        id: m['id'] is int ? m['id'] : (m['id'] != null ? int.tryParse(m['id'].toString()) : null),
        userId: m['user_id']?.toString(),
        driverId: m['driver_id']?.toString(),
        totalPrice: m['total_price'] is num ? m['total_price'] : (m['total_price'] != null ? num.tryParse(m['total_price'].toString()) : null),
        status: m['status']?.toString() ?? 'unknown',
        createdAt: m['created_at']?.toString(),
        customerName: m['customer_name']?.toString(),
        phoneNumber: m['phone_number']?.toString(),
        deliveryAddress: m['delivery_address']?.toString(),
      );
}

class AdminOrderItem {
  final int? id;
  final int? productId;
  final int? quantity;
  final String? productName;
  final num? productPrice;

  AdminOrderItem({this.id, this.productId, this.quantity, this.productName, this.productPrice});

  factory AdminOrderItem.fromMap(Map<String, dynamic> m) {
    final product = m['products'];
    return AdminOrderItem(
      id: m['id'] is int ? m['id'] : (m['id'] != null ? int.tryParse(m['id'].toString()) : null),
      productId: m['product_id'] is int ? m['product_id'] : (m['product_id'] != null ? int.tryParse(m['product_id'].toString()) : null),
      quantity: m['quantity'] is int ? m['quantity'] : (m['quantity'] != null ? int.tryParse(m['quantity'].toString()) ?? 0 : 0),
      productName: product is Map ? product['name']?.toString() : null,
      productPrice: product is Map ? (product['price'] is num ? product['price'] : null) : null,
    );
  }
}
