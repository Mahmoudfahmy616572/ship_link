import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/constant.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/utils/validators.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/auth_field.dart';
import 'package:ship_link/core/widgets/build_botton.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/user/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/user/presentation/screens/signup/register/User/components/link_text.dart';
import 'package:ship_link/user/presentation/screens/signup/register/User/components/top_logo.dart';

class UserBody extends StatefulWidget {
  const UserBody({super.key});

  @override
  State<UserBody> createState() => _UserBodyState();
}

class _UserBodyState extends State<UserBody> {
  final isVisiable = ValueNotifier<bool>(false);
  final isVisiableConfirm = ValueNotifier<bool>(false);
  final formKey = GlobalKey<FormState>();

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController postalCode = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();

  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final FocusNode postalFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmFocus = FocusNode();

  bool _submitting = false;

  @override
  void dispose() {
    isVisiable.dispose();
    isVisiableConfirm.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    firstName.dispose();
    lastName.dispose();
    address.dispose();
    postalCode.dispose();
    phoneNumber.dispose();
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    emailFocus.dispose();
    phoneFocus.dispose();
    addressFocus.dispose();
    postalFocus.dispose();
    passwordFocus.dispose();
    confirmFocus.dispose();
    super.dispose();
  }

  Widget _label(String text) => Text(
        text,
        style: appStyle(14, FontWeight.normal, const Color(0xFF6C6C6C)),
      );

  Widget _strengthMeter() {
    return ListenableBuilder(
      listenable: password,
      builder: (context, _) {
        final ctrl = password;
        final score = Validators.strength(ctrl.text);
        final color = switch (score) {
          0 || 1 => const Color(0xFFEF4444),
          2 || 3 => const Color(0xFFF59E0B),
          _ => const Color(0xFF10B981),
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: i < score
                          ? color
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            if (ctrl.text.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '${context.t.tr('password_strength')}: ${Validators.strengthLabel(context, score)}',
                style: appStyle(12, FontWeight.w500, color),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Registersuccess) {
          if (mounted) setState(() => _submitting = false);
          if (token != '') {
            Navigator.pushReplacementNamed(context, '/locationPicker');
          }
        } else if (state is Registerfaild) {
          if (mounted) setState(() => _submitting = false);
          CustomSnackBar.displayErrorMotionToast(
              state.message.isNotEmpty
                  ? state.message
                  : context.t.tr('registration_failed'),
              context);
        }
      },
      builder: (context, state) {
        final isLoading = state is RegisterLoading || _submitting;
        final cubit = AuthCubit.get(context);
        final halfWidth = MediaQuery.of(context).size.width * 0.43;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: TopLogo(text: context.t.tr('sign_up_user'))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label(context.t.tr('first_name')),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: halfWidth,
                          child: AuthField(
                            controller: firstName,
                            hint: context.t.tr('enter_first_name'),
                            icon: Icons.person_outline,
                            theme: AuthFieldTheme.filled,
                            focusNode: firstNameFocus,
                            onSubmitted: (_) => lastNameFocus.requestFocus(),
                            validator: (v) => Validators.name(
                              context,
                              v,
                              requiredKey: 'first_name_required',
                              shortKey: 'name_must_be_more_than_2',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label(context.t.tr('last_name')),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: halfWidth,
                          child: AuthField(
                            controller: lastName,
                            hint: context.t.tr('enter_last_name'),
                            icon: Icons.person_outline,
                            theme: AuthFieldTheme.filled,
                            focusNode: lastNameFocus,
                            onSubmitted: (_) => emailFocus.requestFocus(),
                            validator: (v) => Validators.name(
                              context,
                              v,
                              requiredKey: 'last_name_required',
                              shortKey: 'name_must_be_more_than_2',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _label(context.t.tr('email')),
                const SizedBox(height: 5),
                AuthField(
                  controller: email,
                  hint: context.t.tr('enter_email'),
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  theme: AuthFieldTheme.filled,
                  focusNode: emailFocus,
                  onSubmitted: (_) => phoneFocus.requestFocus(),
                  validator: (v) => Validators.email(context, v),
                ),
                const SizedBox(height: 16),
                _label(context.t.tr('phone_number')),
                const SizedBox(height: 5),
                AuthField(
                  controller: phoneNumber,
                  hint: context.t.tr('enter_phone'),
                  icon: Icons.phone_outlined,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.phone,
                  theme: AuthFieldTheme.filled,
                  focusNode: phoneFocus,
                  onSubmitted: (_) => addressFocus.requestFocus(),
                  validator: (v) => Validators.phone(context, v),
                ),
                const SizedBox(height: 16),
                _label(context.t.tr('address')),
                const SizedBox(height: 5),
                AuthField(
                  controller: address,
                  hint: context.t.tr('enter_address'),
                  icon: Icons.location_on_outlined,
                  keyboardType: TextInputType.streetAddress,
                  theme: AuthFieldTheme.filled,
                  focusNode: addressFocus,
                  onSubmitted: (_) => postalFocus.requestFocus(),
                  validator: (v) => Validators.address(context, v),
                ),
                const SizedBox(height: 16),
                _label(context.t.tr('postal_code')),
                const SizedBox(height: 5),
                AuthField(
                  controller: postalCode,
                  hint: context.t.tr('enter_postal_code'),
                  icon: Icons.markunread_mailbox_outlined,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  theme: AuthFieldTheme.filled,
                  focusNode: postalFocus,
                  onSubmitted: (_) => passwordFocus.requestFocus(),
                  validator: (v) => Validators.postalCode(context, v),
                ),
                const SizedBox(height: 16),
                _label(context.t.tr('password')),
                const SizedBox(height: 5),
                ValueListenableBuilder<bool>(
                  valueListenable: isVisiable,
                  builder: (context, vis, _) => AuthField(
                    controller: password,
                    hint: context.t.tr('enter_password'),
                    icon: Icons.lock_outline,
                    obscure: vis,
                    keyboardType: TextInputType.text,
                    theme: AuthFieldTheme.filled,
                    focusNode: passwordFocus,
                    onSubmitted: (_) => confirmFocus.requestFocus(),
                    suffix: IconButton(
                      tooltip: vis
                          ? context.t.tr('show_password')
                          : context.t.tr('hide_password'),
                      onPressed: () => isVisiable.value = !vis,
                      icon: vis
                          ? const Icon(Icons.visibility_outlined,
                              color: Color(0xFF9CA3AF))
                          : const Icon(Icons.visibility_off_outlined,
                              color: Color(0xFF9CA3AF)),
                    ),
                    validator: (v) => Validators.password(context, v),
                  ),
                ),
                _strengthMeter(),
                const SizedBox(height: 16),
                _label(context.t.tr('confirm_password')),
                const SizedBox(height: 5),
                ValueListenableBuilder<bool>(
                  valueListenable: isVisiableConfirm,
                  builder: (context, vis, _) => AuthField(
                    controller: confirmPassword,
                    hint: context.t.tr('enter_confirm_password'),
                    icon: Icons.lock_outline,
                    obscure: vis,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    theme: AuthFieldTheme.filled,
                    focusNode: confirmFocus,
                    onSubmitted: (_) => _submit(cubit: cubit),
                    suffix: IconButton(
                      tooltip: vis
                          ? context.t.tr('show_password')
                          : context.t.tr('hide_password'),
                      onPressed: () => isVisiableConfirm.value = !vis,
                      icon: vis
                          ? const Icon(Icons.visibility_outlined,
                              color: Color(0xFF9CA3AF))
                          : const Icon(Icons.visibility_off_outlined,
                              color: Color(0xFF9CA3AF)),
                    ),
                    validator: (val) => Validators.confirmPassword(
                      context,
                      val,
                      password.text,
                    ),
                  ),
                ),
                const SizedBox(height: 33),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: BuildButton(
                    text: context.t.tr('sign_up'),
                    color: Colors.white,
                    textStyle: appStyle(17, FontWeight.w700, Colors.black),
                    ontap: isLoading
                        ? null
                        : () => _submit(cubit: cubit),
                  ),
                ),
                const SizedBox(height: 16),
                LinkText(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit({required AuthCubit cubit}) {
    if (_submitting) return;
    if (!formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final fullName = '${firstName.text} ${lastName.text}'.trim();
    cubit.signUp(
      name: fullName,
      email: email.text.trim(),
      password: password.text,
      phone: phoneNumber.text.trim(),
    );
  }
}
