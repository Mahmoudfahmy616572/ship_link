import 'package:ship_link/data/models/singIn/sign_in.dart';

String token = '';
const baseurl = "https://shiplink.spider-te8.com/api/";
var header = {"Accept": "application/json", "Authorization": 'Bearer $token'};
SignIn userSignIn = SignIn();

//=========================Auth end points=========================
String register = 'auth/register';
String singin = 'auth/login';
String singout = 'auth/logout';
String singinDriver = 'driver/login';
String singupDriver = 'driver/register';
String signoutDriver = 'auth/logout';

//=========================Products end points=========================

String getProducts = 'Products/get';
String addProducts = 'product/add';
String getfromCart = 'product/getFromCart';
String deletefromCart1 = 'product/deleteFromCart/cart/';
String deletefromCart2 = '/product/';
String confirmeCart = 'confirmCart';
String paymentUrl = 'checkout';
String getTopSellerUrl = 'topSellers';

//===============Driver end point==============
String getOrderUrl = "driver/getOrders";
String getStatesUrl = "getStats";
String getuserDataUrl = "driver/userProfile";
String updateUserDataUrl = 'driver/updateUser';
String acceptOrder = 'driver/acceptOrder';
String getAcceptedOrdersUrl = 'driver/getAccepted';
