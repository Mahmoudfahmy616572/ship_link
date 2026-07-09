import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/web/data/models/confirmCart/confirmCart.dart';
import 'package:ship_link/web/data/models/getFromCart/get_from_cart.dart';
import 'package:ship_link/web/data/models/payment/payment.dart';

abstract class CartRepository {
  Future<Either<Failure, GetFromCart>> getFromCart();
  Future<Either<Failure, String>> addToCart({required int id, int quantity = 1});
  Future<Either<Failure, ConfirmCart>> confirmCart({
    required int id,
    required String userId,
    String? deliveryAddress,
    double? deliveryLat,
    double? deliveryLng,
    String? addressLabel,
    String? phoneNumber,
    String? deliveryInstructions,
    String paymentMethod = 'cod',
  });
  Future<Either<Failure, String>> deletefromCart({required int cart_id, required int product_id});
  Future<Either<Failure, Payment>> checkOut({required int totalPrice, int? orderId, String? redirectUri});
  Future<Either<Failure, List<Map<String, dynamic>>>> getOrderHistory();
  Future<Either<Failure, List<Map<String, dynamic>>>> getSuggestedProducts(List<String> categories, {List<int> excludeIds = const []});
}
