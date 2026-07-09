import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final _supabase = Supabase.instance.client;

  AddressCubit() : super(const AddressInitial());

  Future<void> load() async {
    emit(const AddressLoading());
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) { emit(const AddressError('Not authenticated')); return; }
      final data = await _supabase
          .from('user_addresses')
          .select()
          .eq('user_id', user.id)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);
      if (!isClosed) emit(AddressLoaded(List<Map<String, dynamic>>.from(data)));
    } catch (e) {
      if (!isClosed) emit(AddressError(e.toString()));
    }
  }

  Future<void> add(Map<String, dynamic> data) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      data['user_id'] = user.id;
      final existing = await _supabase
          .from('user_addresses')
          .select('id')
          .eq('user_id', user.id)
          .limit(1);
      if (existing.isEmpty) data['is_default'] = true;
      await _supabase.from('user_addresses').insert(data);
      await load();
    } catch (e) {
      if (!isClosed) emit(AddressError(e.toString()));
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('user_addresses').update(data).eq('id', id);
      await load();
    } catch (e) {
      if (!isClosed) emit(AddressError(e.toString()));
    }
  }

  Future<void> delete(String id) async {
    await _supabase.from('user_addresses').delete().eq('id', id);
    await load();
  }

  Future<void> setDefault(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      await _supabase.from('user_addresses').update({'is_default': false}).eq('user_id', user.id);
      await _supabase.from('user_addresses').update({'is_default': true}).eq('id', id);
      await load();
    } catch (e) {
      if (!isClosed) emit(AddressError(e.toString()));
    }
  }
}
