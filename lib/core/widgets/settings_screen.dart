import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:provider/provider.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/providers.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/notification_preferences_screen.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  static String routName = '/settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is UpdatePasswordSuccess) {
                  Navigator.pop(ctx);
                  CustomSnackBar.displaySuccessMotionToast(
                      context.t.tr('password_updated'), context);
                } else if (state is UpdatePasswordFaild) {
                  CustomSnackBar.displayErrorMotionToast(state.message, context);
                }
              },
              child: AlertDialog(
                title: Text(context.t.tr('change_password')),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 52,
                          child: TextFormField(
                            controller: currentCtrl,
                            obscureText: obscureCurrent,
                            decoration: _dialogInputDecoration(
                              context.t.tr('current_password'),
                              obscureCurrent,
                              () => setDialogState(() => obscureCurrent = !obscureCurrent),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? context.t.tr('password_required')
                                : null,
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          height: 52,
                          child: TextFormField(
                            controller: newCtrl,
                            obscureText: obscureNew,
                            decoration: _dialogInputDecoration(
                              context.t.tr('new_password'),
                              obscureNew,
                              () => setDialogState(() => obscureNew = !obscureNew),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return context.t.tr('password_required');
                              if (v.length < 6) return context.t.tr('password_min_length');
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          height: 52,
                          child: TextFormField(
                            controller: confirmCtrl,
                            obscureText: obscureConfirm,
                            decoration: _dialogInputDecoration(
                              context.t.tr('confirm_new_password'),
                              obscureConfirm,
                              () => setDialogState(() => obscureConfirm = !obscureConfirm),
                            ),
                            validator: (v) => v != newCtrl.text
                                ? context.t.tr('passwords_do_not_match')
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      currentCtrl.dispose();
                      newCtrl.dispose();
                      confirmCtrl.dispose();
                      Navigator.pop(ctx);
                    },
                    child: Text(context.t.tr('cancel')),
                  ),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final loading = state is UpdatePasswordLoading;
                      return ElevatedButton(
                        onPressed: loading
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  context.read<AuthCubit>().updatePassword(newCtrl.text);
                                }
                              },
                        child: loading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(context.t.tr('update_password')),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _dialogInputDecoration(
      String hint, bool obscure, VoidCallback toggle) {
    return InputDecoration(
      hintText: hint,
      hintStyle: appStyle(14, FontWeight.w400, const Color(0xFF9CA3AF)),
      prefixIcon: const Icon(Icons.lock_outline, size: 20),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 20),
        onPressed: toggle,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.tr('settings')),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Card(
              child: Material(
                type: MaterialType.transparency,
                child: ListTile(
                  title: Text(t.tr('language')),
                  trailing: Text(
                    context.watch<LocaleProvider>().locale.languageCode == 'en'
                        ? 'English'
                        : 'العربية',
                  ),
                  onTap: () {
                    context.read<LocaleProvider>().toggleLocale();
                  },
                ),
              ),
            ),
            Card(
              child: Material(
                type: MaterialType.transparency,
                child: ListTile(
                  leading: const Icon(Icons.lock_outline, color: AppColors.cta),
                  title: Text(t.tr('change_password')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context),
                ),
              ),
            ),
            Card(
              child: Material(
                type: MaterialType.transparency,
                child: ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(t.tr('notification_preferences')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
