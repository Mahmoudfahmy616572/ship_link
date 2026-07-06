import 'package:ship_link/driver/data/models/singIn/sign_in.dart';

String token = '';
const baseurl = "https://shiplink.spider-te8.com/api/";
var header = {"Accept": "application/json", "Authorization": 'Bearer $token'};
SignIn userSignIn = SignIn();
