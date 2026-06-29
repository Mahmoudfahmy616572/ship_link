import 'package:dartz/dartz.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/data/models/acceptOrder/accept_order.dart';
import 'package:ship_link/data/models/getAcceptedOrders/get_accepted_orders.dart';
import 'package:ship_link/data/models/getStates/get_states.dart';
import 'package:ship_link/data/models/getUserDriverData/get_user_driver_data.dart';
import 'package:ship_link/data/models/get_order/get_order.dart';
import 'package:ship_link/data/models/update_user_data/up_user_data.dart';
import 'package:ship_link/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'driver_home_serveices.dart';

class DriverHomeServeicesImpl extends DriverHomeServeices {
  DriverHomeServeicesImpl();

  SupabaseClient get _supabase => Supabase.instance.client;
  String? get _userId => _supabase.auth.currentUser?.id;

  @override
  Future<Either<Failure, GetOrder>> getOrders() async {
    try {
      final data = await _supabase
          .from('orders')
          .select('*, profiles(*)')
          .neq('status', 'accepted');
      GetOrder getOrder = GetOrder.fromJson({
        'data': {
          'OrderShipping': [],
          'order': data,
        },
        'message': 'success',
        'status': 200,
      });
      return right(getOrder);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GetuserDriverData>> getuserData() async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final data = await _supabase
          .from('drivers')
          .select('*')
          .eq('id', _userId!)
          .maybeSingle();
      if (data == null) {
        return left(ServerFailure('Driver profile not found'));
      }
      GetuserDriverData getuserDriverData = GetuserDriverData.fromJson({
        'data': data,
      });
      return right(getuserDriverData);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UpDateUserData>> updateUserData({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final data = await _supabase.from('drivers').update({
        'name': name,
        'phone_number': phoneNumber,
      }).eq('id', _userId!).select().maybeSingle();
      if (data == null) {
        return left(ServerFailure('Driver profile not found'));
      }
      UpDateUserData upDateUserData = UpDateUserData.fromJson({
        'data': data,
        'message': 'Profile updated',
        'status': 200,
      });
      return right(upDateUserData);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcceptOrder>> acceptOrders(
      {required int orderId}) async {
    try {
      final order = await _supabase
          .from('orders')
          .select('user_id')
          .eq('id', orderId)
          .maybeSingle();
      await _supabase.from('orders').update({
        'status': 'accepted',
        'driver_id': _supabase.auth.currentUser?.id,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
      final userId = order?['user_id'] as String?;
      if (userId != null) {
        await NotificationService().sendNotification(
          userId: userId,
          title: 'Order Accepted',
          body: 'Your order #$orderId has been accepted by a driver! Track it now.',
          type: 'order_accepted',
        );
      }
      AcceptOrder acceptOrder = AcceptOrder.fromJson({
        'data': 1,
        'message': 'Order accepted',
        'status': 200,
      });
      return right(acceptOrder);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GetAcceptOrder>> getAcceptedOrders() async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final data = await _supabase
          .from('orders')
          .select('*, profiles(*)')
          .eq('driver_id', _userId!);
      GetAcceptOrder getAcceptedOrder = GetAcceptOrder.fromJson({
        'data': {
          'OrderShipping': [],
          'order': data,
        },
        'message': 'success',
        'status': 200,
      });
      return right(getAcceptedOrder);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<String?> _getOrderUserId(int orderId) async {
    final data = await _supabase.from('orders').select('user_id').eq('id', orderId).maybeSingle();
    return data?['user_id'] as String?;
  }

  @override
  Future<Either<Failure, AcceptOrder>> markPickedUp({required int orderId}) async {
    try {
      final userId = await _getOrderUserId(orderId);
      await _supabase.from('orders').update({'status': 'picked_up', 'updated_at': DateTime.now().toIso8601String()}).eq('id', orderId);
      if (userId != null) {
        await NotificationService().sendNotification(
          userId: userId,
          title: 'Order Picked Up',
          body: 'Your order #$orderId has been picked up by the driver and is on the way!',
          type: 'order_picked_up',
        );
      }
      return right(AcceptOrder.fromJson({'data': 1, 'message': 'Order picked up', 'status': 200}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcceptOrder>> markShipped({required int orderId}) async {
    try {
      final userId = await _getOrderUserId(orderId);
      await _supabase.from('orders').update({'status': 'shipped', 'updated_at': DateTime.now().toIso8601String()}).eq('id', orderId);
      if (userId != null) {
        await NotificationService().sendNotification(
          userId: userId,
          title: 'Order In Transit',
          body: 'Your order #$orderId is now in transit and will arrive soon!',
          type: 'order_shipped',
        );
      }
      return right(AcceptOrder.fromJson({'data': 1, 'message': 'Order shipped', 'status': 200}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcceptOrder>> markDelivered({required int orderId}) async {
    try {
      final userId = await _getOrderUserId(orderId);
      await _supabase.from('orders').update({'status': 'delivered', 'updated_at': DateTime.now().toIso8601String()}).eq('id', orderId);
      if (userId != null) {
        await NotificationService().sendNotification(
          userId: userId,
          title: 'Order Delivered',
          body: 'Your order #$orderId has been delivered! Enjoy your order.',
          type: 'order_delivered',
        );
      }
      return right(AcceptOrder.fromJson({'data': 1, 'message': 'Order delivered', 'status': 200}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcceptOrder>> cancelOrder({required int orderId}) async {
    try {
      final userId = await _getOrderUserId(orderId);
      await _supabase.from('orders').update({'status': 'cancelled', 'updated_at': DateTime.now().toIso8601String()}).eq('id', orderId);
      if (userId != null) {
        await NotificationService().sendNotification(
          userId: userId,
          title: 'Order Cancelled',
          body: 'Your order #$orderId has been cancelled.',
          type: 'order_cancelled',
        );
      }
      return right(AcceptOrder.fromJson({'data': 1, 'message': 'Order cancelled', 'status': 200}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GetStates>> getStates(
      {required String selectedState}) async {
    try {
      final data = await _supabase.from('states').select('*');
      GetStates getStates = GetStates.fromJson({
        'data': data,
        'message': 'success',
        'status': 200,
      });
      return right(getStates);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
