String token = '';
const baseurl = "https://shiplink.spider-te8.com/api/";
var header = {"Accept": "application/json", "Authorization": 'Bearer $token'};

//=========================Auth end points=========================
String register = 'auth/register';
String singin = 'auth/login';
String singout = 'auth/logout';

//=========================Products end points=========================

String getProducts = 'Products/get';
String addProducts = 'product/add';
String getCart = 'product/getFromCart';
