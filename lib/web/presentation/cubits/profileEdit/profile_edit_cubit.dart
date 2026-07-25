import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/core/services/profile_image_service.dart';

part 'profile_edit_state.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  final _supabase = Supabase.instance.client;

  ProfileEditCubit() : super(const ProfileEditInitial());

  Future<void> load() async {
    emit(const ProfileEditLoading());
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) { emit(const ProfileEditError('Not authenticated')); return; }
      final profile = await _supabase
          .from('profiles')
          .select('name, email, phone_number, avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      if (!isClosed) emit(ProfileEditLoaded(
        name: profile?['name'] as String? ?? '',
        email: profile?['email'] as String? ?? user.email ?? '',
        phone: profile?['phone_number'] as String? ?? user.phone ?? '',
        avatarUrl: profile?['avatar_url'] as String?,
      ));
    } catch (e) {
      if (!isClosed) emit(ProfileEditError(e.toString()));
    }
  }

  Future<String?> pickImage({ImageSource? source}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final file = await ImagePicker().pickImage(source: source ?? ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file == null) return null;
    try {
      final svc = ProfileImageService();
      final url = await svc.upload(userId, file);
      await _supabase.from('profiles').upsert({'id': userId, 'avatar_url': url});
      final current = state;
      if (current is ProfileEditLoaded) {
        if (!isClosed) emit(ProfileEditLoaded(
          name: current.name, email: current.email, phone: current.phone, avatarUrl: url,
        ));
      }
      return url;
    } catch (_) {
      return null;
    }
  }

  Future<String?> save({
    required String name,
    required String email,
    String? phone,
  }) async {
    emit(const ProfileEditSaving());
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) { emit(const ProfileEditError('Not authenticated')); return 'Not authenticated'; }

      final emailExists = await supabase.from('profiles')
          .select('id').eq('email', email).neq('id', user.id).maybeSingle();
      if (emailExists != null) { emit(const ProfileEditError('email_already_in_use')); return 'email_already_in_use'; }

      if (phone != null && phone.isNotEmpty) {
        final phoneExists = await supabase.from('profiles')
            .select('id').eq('phone_number', phone).neq('id', user.id).maybeSingle();
        if (phoneExists != null) { emit(const ProfileEditError('phone_already_in_use')); return 'phone_already_in_use'; }
      }

      final updates = <String, dynamic>{'id': user.id, 'name': name, 'email': email};
      if (phone != null && phone.isNotEmpty) updates['phone_number'] = phone;
      await supabase.from('profiles').upsert(updates);
      await supabase.auth.updateUser(UserAttributes(data: {'full_name': name}));

      if (!isClosed) emit(ProfileEditSaved());
      return null;
    } catch (e) {
      if (!isClosed) emit(ProfileEditError(e.toString()));
      return e.toString();
    }
  }
}
