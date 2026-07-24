import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/driver/data/models/acceptOrder/accept_order.dart';
import 'package:ship_link/driver/data/models/getAcceptedOrders/get_accepted_orders.dart';
import 'package:ship_link/driver/data/models/getUserDriverData/get_user_driver_data.dart';
import 'package:ship_link/driver/data/models/get_order/get_order.dart';
import 'package:ship_link/driver/data/models/getStates/get_states.dart';
import 'package:ship_link/driver/data/models/update_user_data/up_user_data.dart';
import 'package:ship_link/driver/domain/repositories/driver_home_repository.dart';
import 'package:ship_link/driver/data/datasources/driver_home_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverWebRepositoryImpl extends DriverHomeRepository {
  DriverWebRepositoryImpl();

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
  Future<Either<Failure, AcceptOrder>> acceptOrders({required int orderId}) async {
    try {
      await _dataSource.updateOrderStatus(orderId, 'accepted', _driverId!);
      return right(AcceptOrder.fromJson({'data': 1, 'message': 'accepted', 'status': 200}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcceptOrder>> markPickedUp({required int orderId}) async {
    try {
      await _dataSource.updateOrderStatus(orderId, 'picked_up', _driverId!);
      return right(AcceptOrder.fromJson({'data': 1, 'message': 'picked_up', 'status': 200}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcceptOrder>> markShipped({required int orderId}) async {
    try {
      await _dataSource.updateOrderStatus(orderId, 'shipped', _driverId!);
      return right(AcceptOrder.fromJson({'data': 1, 'message': 'shipped', 'status': 200}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcceptOrder>> markDelivered({required int orderId}) async {
    try {
      await _dataSource.updateOrderStatus(orderId, 'delivered', _driverId!);
      return right(AcceptOrder.fromJson({'data': 1, 'message': 'delivered', 'status': 200}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AcceptOrder>> cancelOrder({required int orderId}) async {
    try {
      await _dataSource.updateOrderStatus(orderId, 'cancelled', _driverId!);
      return right(AcceptOrder.fromJson({'data': 1, 'message': 'cancelled', 'status': 200}));
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
      return right(UpDateUserData.fromJson({'data': data}));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GetStates>> getStates({required String selectedState}) async {
    try {
      final data = await _dataSource.getStates();
      final states = GetStates.fromJson({'data': data, 'message': 'success', 'status': 200});
      return right(states);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
