import 'package:dartz/dartz.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/data/models/acceptOrder/accept_order.dart';
import 'package:ship_link/data/models/getAcceptedOrders/get_accepted_orders.dart';
import 'package:ship_link/data/models/getStates/get_states.dart';
import 'package:ship_link/data/models/getUserDriverData/get_user_driver_data.dart';
import 'package:ship_link/data/models/get_order/get_order.dart';
import 'package:ship_link/data/models/update_user_data/up_user_data.dart';
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
          .select('*, profiles!inner(*)')
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
          .from('profiles')
          .select('*')
          .eq('id', _userId!)
          .single();
      GetuserDriverData getuserDriverData = GetuserDriverData.fromJson({
        'data': data,
      });
      return right(getuserDriverData);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UpDateUserData>> updateUserData(
      {required int id,
      required String name,
      required String phoneNumber}) async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final data = await _supabase.from('profiles').update({
        'name': name,
        'phone_number': phoneNumber,
        'state_id': id,
      }).eq('id', _userId!).select().single();
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
      await _supabase.from('orders').update({
        'status': 'accepted',
      }).eq('id', orderId);
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
      final data = await _supabase
          .from('orders')
          .select('*, profiles!inner(*)')
          .eq('status', 'accepted');
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
