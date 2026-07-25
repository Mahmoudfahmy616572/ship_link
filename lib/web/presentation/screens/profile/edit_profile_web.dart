import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/cubits/profileEdit/profile_edit_cubit.dart';
import 'package:ship_link/core/utils/sizer.dart';

class EditProfileWeb extends StatefulWidget {
  const EditProfileWeb({super.key});
  static String routName = '/edit-profile';

  @override
  State<EditProfileWeb> createState() => _EditProfileWebState();
}

class _EditProfileWebState extends State<EditProfileWeb> with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _avatarUrl;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    context.read<ProfileEditCubit>().load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.cta),
                title: Text(context.t.tr('camera')),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.cta),
                title: Text(context.t.tr('gallery')),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final cubit = context.read<ProfileEditCubit>();
    final url = await cubit.pickImage(source: source);
    if (url != null && mounted) {
      setState(() => _avatarUrl = url);
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) { _showError(context.t.tr('name_required')); return; }
    if (email.isEmpty || !email.contains('@')) { _showError(context.t.tr('valid_email_required')); return; }

    final error = await context.read<ProfileEditCubit>().save(name: name, email: email, phone: phone);
    if (error == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.tr('profile_updated_successfully'))),
      );
      Navigator.pop(context);
    } else if (error != null && mounted) {
      _showError(error);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('personal_information')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
      ),
      body: BlocBuilder<ProfileEditCubit, ProfileEditState>(
        builder: (context, state) {
          if (state is ProfileEditLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileEditLoaded) {
            if (_nameCtrl.text.isEmpty && state.name.isNotEmpty) {
              _nameCtrl.text = state.name;
              _emailCtrl.text = state.email;
              _phoneCtrl.text = state.phone;
              _avatarUrl = state.avatarUrl;
            }
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: const Color(0xFFF3F4F6),
                            child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      _avatarUrl!, width: 104, height: 104,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(Icons.person, size: 48, color: const Color(0xFF9CA3AF)),
                                    ),
                                  )
                                : Icon(Icons.person, size: 48, color: const Color(0xFF9CA3AF)),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Icon(Icons.camera_alt, size: 18, color: AppColors.cta),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(context.t.tr('edit_your_personal_details'),
                      style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
                  SizedBox(height: 24),
                  _field(context.t.tr('full_name'), _nameCtrl, Icons.person_outline),
                  SizedBox(height: 16),
                  _field(context.t.tr('email_address'), _emailCtrl, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  SizedBox(height: 16),
                  _field(context.t.tr('phone_number'), _phoneCtrl, Icons.phone_outlined, keyboardType: TextInputType.phone),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: state is ProfileEditSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cta,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: state is ProfileEditSaving
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(context.t.tr('save_changes'), style: appStyle(16, FontWeight.w600, Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: appStyle(13, FontWeight.w500, const Color(0xFF6B7280))),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: appStyle(15, FontWeight.w500, const Color(0xFF111827)),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
