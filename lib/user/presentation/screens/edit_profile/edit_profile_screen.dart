import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/services/profile_image_service.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/core/widgets/shimmer/shimmer_loading.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  static String routName = '/editProfile';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _originalEmail = '';
  final _loadingNotifier = ValueNotifier<bool>(false);
  final _avatarUrlNotifier = ValueNotifier<String?>(null);
  final _savingNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _loadingNotifier.value = true;
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('name, email, phone_number, avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      if (profile != null && mounted) {
        _nameCtrl.text = profile['name'] as String? ?? '';
        final loadedEmail = profile['email'] as String? ?? user.email ?? '';
        _emailCtrl.text = loadedEmail;
        _originalEmail = loadedEmail;
        _phoneCtrl.text = profile['phone_number'] as String? ?? user.phone ?? '';
        _avatarUrlNotifier.value = profile['avatar_url'] as String?;
      }
    }
    if (mounted) _loadingNotifier.value = false;
  }

  void _pickImage(ImageSource source) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final svc = ProfileImageService();
    final file = source == ImageSource.gallery
        ? await svc.pickFromGallery()
        : await svc.pickFromCamera();
    if (file == null) return;
    try {
      final url = await svc.upload(userId, file);
      if (!mounted) return;
      await Supabase.instance.client
          .from('profiles')
          .upsert({'id': userId, 'avatar_url': url});
      _avatarUrlNotifier.value = url;
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error('Failed to upload image: $e', context);
      }
    }
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(context.t.tr('choose_from_gallery')),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(context.t.tr('take_a_photo')),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      _showError(context.t.tr('name_required'));
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError(context.t.tr('valid_email_required'));
      return;
    }
    // phone is optional

    _savingNotifier.value = true;
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final emailChanged = email.toLowerCase() != _originalEmail.toLowerCase();

      // 1. Check email duplicate in profiles (case-insensitive)
      if (emailChanged) {
        final emailExists = await supabase
            .from('profiles')
            .select('id')
            .ilike('email', email)
            .neq('id', user.id)
            .maybeSingle();
        if (emailExists != null) {
          if (mounted) _showError(context.t.tr('email_already_in_use'));
          _savingNotifier.value = false;
          return;
        }
      }

      // 2. Check phone duplicate in profiles (case-insensitive)
      if (phone.isNotEmpty) {
        final phoneExists = await supabase
            .from('profiles')
            .select('id')
            .ilike('phone_number', phone)
            .neq('id', user.id)
            .maybeSingle();
        if (phoneExists != null) {
          if (mounted) _showError(context.t.tr('phone_already_in_use'));
          _savingNotifier.value = false;
          return;
        }
      }

      // 3. Build profile updates (exclude email if changed — it'll be handled by updateUser)
      final updates = <String, dynamic>{
        'id': user.id,
        'name': name,
      };
      if (!emailChanged) updates['email'] = email;
      if (phone.isNotEmpty) updates['phone_number'] = phone;
      await supabase.from('profiles').upsert(updates);

      // 4. If email changed, call updateUser (sends verification to new email)
      if (emailChanged) {
        await supabase.auth.updateUser(UserAttributes(email: email));
        // Also update profiles.email now (auth.users.email is already updated)
        await supabase.from('profiles').upsert({
          'id': user.id,
          'email': email,
        });
      }

      if (mounted) {
        if (emailChanged) {
          CustomSnackBar.success(
            context.t.tr('verification_email_sent').replaceAll('{email}', email),
            context,
          );
        } else {
          CustomSnackBar.success(context.t.tr('profile_updated_successfully'), context);
        }
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        final msg = e.message.toLowerCase().contains('already registered')
            ? context.t.tr('email_already_in_use')
            : e.message;
        _showError(msg);
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) _savingNotifier.value = false;
    }
  }

  void _showError(String msg) {
    CustomSnackBar.error(msg, context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _loadingNotifier.dispose();
    _avatarUrlNotifier.dispose();
    _savingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Sizer.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          context.t.tr('personal_information'),
          style: appStyle(22, FontWeight.w700, AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _loadingNotifier,
        builder: (context, loading, _) {
          return loading
              ? ShimmerLoading.productDetail()
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<String?>(
                        valueListenable: _avatarUrlNotifier,
                        builder: (context, avatarUrl, _) {
                          return Center(
                            child: GestureDetector(
                              onTap: _showPicker,
                              child: CircleAvatar(
                                radius: 52.r,
                                backgroundColor: AppColors.surface,
                                child: avatarUrl != null && avatarUrl.isNotEmpty
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: avatarUrl,
                                          width: 104.r,
                                          height: 104.r,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => Icon(
                                              Icons.person, size: 48.sp, color: AppColors.textHint),
                                        ),
                                      )
                                    : Icon(Icons.person, size: 48.sp, color: AppColors.textHint),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        context.t.tr('edit_your_personal_details'),
                        style: appStyle(14, FontWeight.w400, AppColors.textSecondary),
                      ),
                      SizedBox(height: 24.h),
                      _field(context.t.tr('full_name'), _nameCtrl, Icons.person_outline),
                      SizedBox(height: 16.h),
                      _field(context.t.tr('email_address'), _emailCtrl, Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress),
                      SizedBox(height: 16.h),
                      _field(context.t.tr('phone_number'), _phoneCtrl, Icons.phone_outlined,
                          keyboardType: TextInputType.phone),
                      SizedBox(height: 32.h),
                      ValueListenableBuilder<bool>(
                        valueListenable: _savingNotifier,
                        builder: (context, saving, _) {
                          return SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: saving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cta,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                elevation: 0,
                              ),
                              child: saving
                                  ? SizedBox(
                                      height: 22.h,
                                      width: 22.h,
                                      child: const CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      context.t.tr('save_changes'),
                                      style: appStyle(16, FontWeight.w600, Colors.white),
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: appStyle(13, FontWeight.w500, AppColors.textSecondary)),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: appStyle(15, FontWeight.w500, AppColors.textPrimary),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20.r, color: AppColors.textHint),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
        ),
      ],
    );
  }
}
