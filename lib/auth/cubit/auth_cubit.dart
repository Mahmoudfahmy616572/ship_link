import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ship_link/auth/cubit/auth_stat.dart';
import 'package:ship_link/constant/constant.dart';
import 'package:ship_link/models/register/user_register.dart';
import 'package:ship_link/models/signout/sign_out.dart';
import 'package:ship_link/models/singIn/sign_in.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(InitialState());
  static AuthCubit get(context) => BlocProvider.of<AuthCubit>(context);
  Register userRegister = Register();
  SignIn userSignIn = SignIn();
  SignOut userSignOut = SignOut();

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
      print('=================');
      emit(RegisterLoading());
      final response = await http.post(Uri.parse('$baseurl$register'),
          body: {
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "phone_number": phoneNumber,
            "password": password,
            "password_confirmation": passwordConfirmation,
            "address": address,
            "gender": gender,
            "code": code,
          },
          headers: header);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("================");
        print(response.body);
        var res = jsonDecode(response.body);
        userRegister = Register.fromJson(res);
        token = userRegister.token ?? '';
        emit(Registersuccess());
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
      emit(Registerfaild());
    }
  }

// ===========singin============
  signIN({
    required String email,
    required String password,
  }) async {
    try {
      emit(SignInLoading());
      var response = await http.post(Uri.parse("$baseurl$singin"),
          body: {
            "email": email,
            "password": password,
          },
          headers: header);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var res = jsonDecode(response.body);
        userSignIn = SignIn.fromJson(res);
        token = userSignIn.token ?? '';
        print(token);
        emit(SignInSuccess());
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
      emit(SignInFaild());
    }
  }

// ===========singOut============
  signOut() async {
    try {
      emit(SignInLoading());
      var response =
          await http.delete(Uri.parse("$baseurl$singin"), headers: header);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var res = jsonDecode(response.body);
        userSignOut = SignOut.fromJson(res);
        print(response.body);
        emit(SignOutSuccess());
      }
    } catch (e) {
      print(e);
      emit(SignOutFaild());
    }
  }
}
