import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/services/auth_service_web.dart';
import 'package:ship_link/services/profile_image_service.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool _loading = true;
  bool _saving = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('name, email, phone_number, avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      if (profile != null && mounted) {
        _nameCtrl.text = profile['name'] as String? ?? '';
        _emailCtrl.text = profile['email'] as String? ?? user.email ?? '';
        _phoneCtrl.text = profile['phone_number'] as String? ?? user.phone ?? '';
        _avatarUrl = profile['avatar_url'] as String?;
      }
    }
    if (mounted) { setState(() => _loading = false); _animCtrl.forward(); }
  }

  void _pickImage() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (file == null) return;
    try {
      final svc = ProfileImageService();
      final url = await svc.upload(userId, file);
      if (!mounted) return;
      await Supabase.instance.client.from('profiles').upsert({'id': userId, 'avatar_url': url});
      setState(() => _avatarUrl = url);
    } catch (_) {}
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) { _showError(context.t.tr('name_required')); return; }
    if (email.isEmpty || !email.contains('@')) { _showError(context.t.tr('valid_email_required')); return; }

    setState(() => _saving = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final emailExists = await supabase.from('profiles')
          .select('id').eq('email', email).neq('id', user.id).maybeSingle();
      if (emailExists != null) { if (mounted) _showError(context.t.tr('email_already_in_use')); setState(() => _saving = false); return; }

      final phoneExists = await supabase.from('profiles')
          .select('id').eq('phone_number', phone).neq('id', user.id).maybeSingle();
      if (phoneExists != null) { if (mounted) _showError(context.t.tr('phone_already_in_use')); setState(() => _saving = false); return; }

      final updates = <String, dynamic>{'id': user.id, 'name': name, 'email': email};
      if (phone.isNotEmpty) updates['phone_number'] = phone;
      await supabase.from('profiles').upsert(updates);

      await supabase.auth.updateUser(UserAttributes(data: {'full_name': name}));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.tr('profile_updated_successfully'))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _saving
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(context.t.tr('save_changes'), style: appStyle(16, FontWeight.w600, Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
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
