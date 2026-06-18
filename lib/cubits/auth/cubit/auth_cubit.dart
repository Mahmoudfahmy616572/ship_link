import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/constant.dart';
import 'package:ship_link/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/data/models/register/user_register.dart';
import 'package:ship_link/data/models/signIn_Driver/signin_driver.dart';
import 'package:ship_link/data/models/signUp_driver/signup_driver.dart';
import 'package:ship_link/data/models/singIn/sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(InitialState());

  static AuthCubit get(context) => BlocProvider.of<AuthCubit>(context);
  Register userRegister = Register();
  SignIn userSignIn = SignIn();
  SigninDriver signInDriver = SigninDriver();
  SignUpDriver signupDriver = SignUpDriver();

  final _supabase = Supabase.instance.client;

  signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
    required String gender,
    required String code,
    required String passwordConfirmation,
  }) async {
    try {
      emit(RegisterLoading());
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user != null) {
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'gender': gender,
          'code': code,
          'role': 'user',
        });
        token = user.id;
        userRegister = Register(
          message: 'Registration successful',
          token: user.id,
        );
        emit(Registersuccess());
      } else if (res.session != null) {
        token = res.session!.user.id;
        emit(Registersuccess());
      } else {
        emit(Registerfaild());
      }
    } catch (e) {
      print('AuthCubit.signUp error: $e');
      emit(Registerfaild());
    }
  }

  signIN({
    required String email,
    required String password,
  }) async {
    emit(SignInLoading());
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user != null) {
        token = user.id;
        userSignIn = SignIn(
          message: 'Login successful',
          token: user.id,
        );
        emit(SignInSuccess());
      } else {
        emit(SignInFaild());
      }
    } catch (e) {
      print('AuthCubit.signIN error: $e');
      emit(SignInFaild());
    }
  }

  signOut() async {
    try {
      emit(SignOutLoading());
      await _supabase.auth.signOut();
      token = '';
      emit(SignOutSuccess());
    } catch (e) {
      print('AuthCubit.signOut error: $e');
      emit(SignOutFaild());
    }
  }

  signUpDriver({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
    required String gender,
    required String code,
    required String passwordConfirmation,
    required String vehicleNumber,
    required String stateId,
  }) async {
    try {
      emit(RegisterDriverLoading());
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user != null) {
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'email': email,
          'name': name,
          'phone_number': phoneNumber,
          'gender': gender,
          'code': code,
          'vehicle_number': vehicleNumber,
          'state_id': stateId,
          'role': 'driver',
        });
        token = user.id;
        signupDriver = SignUpDriver(
          message: 'Driver registration successful',
          token: user.id,
        );
        emit(RegisterDriversuccess());
      } else {
        emit(RegisterDriverfaild());
      }
    } catch (e) {
      print('AuthCubit.signUpDriver error: $e');
      emit(RegisterDriverfaild());
    }
  }

  signINDriver({
    required String email,
    required String password,
  }) async {
    emit(SignInDriverLoading());
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user != null) {
        token = user.id;
        signInDriver = SigninDriver(
          message: 'Driver login successful',
          token: user.id,
        );
        emit(SignInDriverSuccess());
      } else {
        emit(SignInDriverFaild());
      }
    } catch (e) {
      print('AuthCubit.signINDriver error: $e');
      emit(SignInDriverFaild());
    }
  }

  signOutDriver() async {
    try {
      emit(SignOutDriverLoading());
      await _supabase.auth.signOut();
      token = '';
      emit(SignOutDriverSuccess());
    } catch (e) {
      print('AuthCubit.signOutDriver error: $e');
      emit(SignOutDriverFaild());
    }
  }
}
