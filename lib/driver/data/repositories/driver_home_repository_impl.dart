import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/driver/data/models/acceptOrder/accept_order.dart';
import 'package:ship_link/driver/data/models/getAcceptedOrders/get_accepted_orders.dart';
import 'package:ship_link/driver/data/models/getStates/get_states.dart';
import 'package:ship_link/driver/data/models/getUserDriverData/get_user_driver_data.dart';
import 'package:ship_link/driver/data/models/get_order/get_order.dart';
import 'package:ship_link/driver/data/models/update_user_data/up_user_data.dart';
import 'package:ship_link/core/services/notification_service.dart';
import 'package:ship_link/driver/domain/repositories/driver_home_repository.dart';
import 'package:ship_link/driver/data/datasources/driver_home_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverHomeRepositoryImpl extends DriverHomeRepository {
  DriverHomeRepositoryImpl();

  final _dataSource = DriverHomeRemoteDataSource();
  String? get _driverId => Supabase.instance.client.auth.currentUser?.id;

  @override
  Future<Either<Failure, GetOrder>> getOrders() async {
    try {
      final data = await _dataSource.getAvailableOrders();
      GetOrder getOrder = GetOrder.fromJson({
        'data': {'OrderShipping': [], 'order': data},
        'message': 'success', 'status': 200,
      });
      return right(getOrder);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GetuserDriverData>> getuserData() async {
    try {
      if (_driverId == null) return left(ServerFailure('Not authenticated'));
      final data = await _dataSource.getDriverData();
      if (data == null) return left(ServerFailure('Driver profile not found'));
      GetuserDriverData getuserDriverData = GetuserDriverData.fromJson({'data': data});
      return right(getuserDriverData);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UpDateUserData>> updateUserData({required String name, required String phoneNumber}) async {
    try {
      if (_driverId == null) return left(ServerFailure('Not authenticated'));
      final data = await _dataSource.updateDriverData(name: name, phoneNumber: phoneNumber);
      if (data == null) return left(ServerFailure('Driver profile not found'));
      UpDateUserData upDateUserData = UpDateUserData.fromJson({
        'data': data, 'message': 'Profile updated', 'status': 200,
      });
      return right(upDateUserData);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<String?> _getOrderUserId(int orderId) async {
    final data = await _dataSource.getOrderUser(orderId);
    return data?['user_id'] as String?;
  }

  Future<Either<Failure, AcceptOrder>> _processOrder(
    int orderId, String status, String notifTitle, String notifBody, String notifType,
  ) async {
    try {
      final userId = await _getOrderUserId(orderId);
      await _dataSource.updateOrderStatus(orderId, status, _driverId!);
      if (userId != null) {
        await NotificationService().sendNotification(
          userId: userId, title: notifTitle, body: notifBody, type: notifType,
          data: {'orderId': orderId},
        );
      }
      return right(AcceptOrder.fromJson({'data': 1, 'message': '$status', 'status': 200}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcceptOrder>> acceptOrders({required int orderId}) async {
    return _processOrder(orderId, 'accepted', 'Order Accepted', 'Your order #$orderId has been accepted by a driver! Track it now.', 'order_accepted');
  }

  @override
  Future<Either<Failure, AcceptOrder>> markPickedUp({required int orderId}) async {
    return _processOrder(orderId, 'picked_up', 'Order Picked Up', 'Your order #$orderId has been picked up by the driver and is on the way!', 'order_picked_up');
  }

  @override
  Future<Either<Failure, AcceptOrder>> markShipped({required int orderId}) async {
    return _processOrder(orderId, 'shipped', 'Order In Transit', 'Your order #$orderId is now in transit and will arrive soon!', 'order_shipped');
  }

  @override
  Future<Either<Failure, AcceptOrder>> markDelivered({required int orderId}) async {
    return _processOrder(orderId, 'delivered', 'Order Delivered', 'Your order #$orderId has been delivered! Enjoy your order.', 'order_delivered');
  }

  @override
  Future<Either<Failure, AcceptOrder>> cancelOrder({required int orderId}) async {
    return _processOrder(orderId, 'cancelled', 'Order Cancelled', 'Your order #$orderId has been cancelled.', 'order_cancelled');
  }

  @override
  Future<Either<Failure, GetAcceptOrder>> getAcceptedOrders() async {
    try {
      if (_driverId == null) return left(ServerFailure('Not authenticated'));
      final data = await _dataSource.getDriverOrders();
      GetAcceptOrder getAcceptedOrder = GetAcceptOrder.fromJson({
        'data': {'OrderShipping': [], 'order': data},
        'message': 'success', 'status': 200,
      });
      return right(getAcceptedOrder);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GetStates>> getStates({required String selectedState}) async {
    try {
      final data = await _dataSource.getStates();
      GetStates getStates = GetStates.fromJson({
        'data': data, 'message': 'success', 'status': 200,
      });
      return right(getStates);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
