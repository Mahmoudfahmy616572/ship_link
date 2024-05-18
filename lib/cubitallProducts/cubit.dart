import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:ship_link/cubitallProducts/product_stat.dart';
import 'package:ship_link/models/Cart/cart.dart';
import 'package:ship_link/models/allProducts/all_products.dart';

import '../constant/constant.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(InitialState());
  static ProductCubit get(context) => BlocProvider.of<ProductCubit>(context);
  AllProducts allProducts = AllProducts();
  CartProducts getCart = CartProducts();

  products() async {
    try {
      emit(ProductLoading());
      var response =
          await http.get(Uri.parse("$baseurl$getProducts"), headers: header);
      if (response.statusCode == 200 || response.statusCode == 201) {
        var res = jsonDecode(response.body);
        allProducts = AllProducts.fromJson(res);
        emit(ProductSuccess());
        print(allProducts);
      }
    } catch (e) {
      print(e);

      emit(ProductFaild());
    }
  }

  addProductToCard({
    required String id,
  }) async {
    try {
      print('==========================');
      print(token);
      emit(AddLoading());
      var response = await http.post(Uri.parse("$baseurl$addProducts"), body: {
        "user_id": "2",
        "product_id": id
      }, headers: {
        "Accept": "application/json",
        "Authorization": 'Bearer $token'
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        var res = jsonDecode(response.body);

        print('===========');
        emit(AddSuccess(res['success']));
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
      emit(AddFaild());
    }
  }

  getProductFormCart() async {
    try {
      emit(GetCartLoading());

      var response = await http.get(Uri.parse("$baseurl$getCart"), headers: {
        "Accept": "application/json",
        "Authorization": 'Bearer $token'
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        var res = jsonDecode(response.body);
        getCart = CartProducts.fromJson(res);
        print('===========');
        print(getCart);
        emit(GetCartSuccess());
        print(getCart);

        print('===========');
      }
    } catch (e) {
      print(e);
      emit(GetCartFaild());
    }
  }
}
