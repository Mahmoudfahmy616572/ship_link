import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';

// فورم إضافة/تعديل مستخدم (بيظهر في Dialog)
class UserCreateEditDialog extends StatefulWidget {
  final Map<String, dynamic>? user; // null = إضافة جديدة
  const UserCreateEditDialog({super.key, this.user});

  @override
  State<UserCreateEditDialog> createState() => _UserCreateEditDialogState();
}

class _UserCreateEditDialogState extends State<UserCreateEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _name = TextEditingController(text: u?['name']?.toString() ?? '');
    _email = TextEditingController(text: u?['email']?.toString() ?? '');
    _phone = TextEditingController(text: u?['phone_number']?.toString() ?? '');
    _role = u?['role']?.toString() ?? 'user';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Map<String, dynamic> _collect() => {
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone_number': _phone.text.trim(),
        'role': _role,
      };

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final isEdit = widget.user != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEdit ? t.tr('edit_user') : t.tr('add_user'),
                  style: appStyle(20, FontWeight.w700, AppColors.textPrimary)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: t.tr('name'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? t.tr('name_required') : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: t.tr('email'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return t.tr('email_required');
                  if (!v.contains('@')) return t.tr('email_invalid');
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phone,
                decoration: InputDecoration(
                  labelText: t.tr('phone_number'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(
                  labelText: t.tr('role'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('user')),
                  DropdownMenuItem(value: 'driver', child: Text('driver')),
                  DropdownMenuItem(value: 'admin', child: Text('admin')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'user'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.tr('cancel')),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, _collect());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEdit ? t.tr('save') : t.tr('add')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
