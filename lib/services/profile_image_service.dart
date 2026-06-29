import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileImageService {
  final _picker = ImagePicker();
  final _storage = Supabase.instance.client.storage;

  Future<XFile?> pickFromGallery() => _picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
  Future<XFile?> pickFromCamera() => _picker.pickImage(source: ImageSource.camera, maxWidth: 512, maxHeight: 512);

  Future<String?> upload(String userId, XFile file) async {
    final ext = file.path.split('.').last;
    final path = 'avatars/$userId.$ext';
    await _storage.from('profiles').upload(path, File(file.path), fileOptions: FileOptions(upsert: true));
    return _storage.from('profiles').getPublicUrl(path);
  }

  Future<bool> delete(String userId) async {
    try {
      await _storage.from('profiles').remove(['avatars/$userId.jpg', 'avatars/$userId.png', 'avatars/$userId.jpeg']);
      return true;
    } catch (_) {
      return false;
    }
  }
}
