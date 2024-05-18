// To parse this JSON data, do
//
//     final allProducts = allProductsFromJson(jsonString);

import 'dart:convert';

AllProducts allProductsFromJson(String str) => AllProducts.fromJson(json.decode(str));

String allProductsToJson(AllProducts data) => json.encode(data.toJson());

class AllProducts {
    Products? products;
    Providers? providers;

    AllProducts({
        this.products,
        this.providers,
    });

    factory AllProducts.fromJson(Map<String, dynamic> json) => AllProducts(
        products: json["Products"] == null ? null : Products.fromJson(json["Products"]),
        providers: json["Providers"] == null ? null : Providers.fromJson(json["Providers"]),
    );

    Map<String, dynamic> toJson() => {
        "Products": products?.toJson(),
        "Providers": providers?.toJson(),
    };
}

class Products {
    int? productscount;
    List<Product>? products;

    Products({
        this.productscount,
        this.products,
    });

    factory Products.fromJson(Map<String, dynamic> json) => Products(
        productscount: json["Productscount"],
        products: json["Products"] == null ? [] : List<Product>.from(json["Products"]!.map((x) => Product.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Productscount": productscount,
        "Products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
    };
}

class Product {
    int? id;
    String? name;
    String? description;
    String? image;
    double? price;
    int? isOffer;
    double? newPrice;
    int? qty;
    int? status;
    int? providerId;
    DateTime? createdAt;
    DateTime? updatedAt;

    Product({
        this.id,
        this.name,
        this.description,
        this.image,
        this.price,
        this.isOffer,
        this.newPrice,
        this.qty,
        this.status,
        this.providerId,
        this.createdAt,
        this.updatedAt,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        image: json["image"],
        price: json["price"]?.toDouble(),
        isOffer: json["is_offer"],
        newPrice: json["new_price"]?.toDouble(),
        qty: json["qty"],
        status: json["status"],
        providerId: json["provider_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "image": image,
        "price": price,
        "is_offer": isOffer,
        "new_price": newPrice,
        "qty": qty,
        "status": status,
        "provider_id": providerId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}

class Providers {
    int? providerscount;
    List<Provider>? providers;

    Providers({
        this.providerscount,
        this.providers,
    });

    factory Providers.fromJson(Map<String, dynamic> json) => Providers(
        providerscount: json["providerscount"],
        providers: json["providers"] == null ? [] : List<Provider>.from(json["providers"]!.map((x) => Provider.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "providerscount": providerscount,
        "providers": providers == null ? [] : List<dynamic>.from(providers!.map((x) => x.toJson())),
    };
}

class Provider {
    int? id;
    String? email;
    String? name;
    dynamic passwordConfirmation;
    dynamic emailVerifiedAt;
    dynamic city;
    String? productsType;
    dynamic address;
    dynamic servicess;
    dynamic websiteLink;
    dynamic phoneNumber;
    dynamic taxNum;
    dynamic postalCode;
    dynamic state;
    dynamic code;
    dynamic expire;
    dynamic createdAt;
    dynamic updatedAt;

    Provider({
        this.id,
        this.email,
        this.name,
        this.passwordConfirmation,
        this.emailVerifiedAt,
        this.city,
        this.productsType,
        this.address,
        this.servicess,
        this.websiteLink,
        this.phoneNumber,
        this.taxNum,
        this.postalCode,
        this.state,
        this.code,
        this.expire,
        this.createdAt,
        this.updatedAt,
    });

    factory Provider.fromJson(Map<String, dynamic> json) => Provider(
        id: json["id"],
        email: json["email"],
        name: json["name"],
        passwordConfirmation: json["password_confirmation"],
        emailVerifiedAt: json["email_verified_at"],
        city: json["city"],
        productsType: json["products_type"],
        address: json["address"],
        servicess: json["servicess"],
        websiteLink: json["website_link"],
        phoneNumber: json["phone_number"],
        taxNum: json["tax_num"],
        postalCode: json["postal_code"],
        state: json["state"],
        code: json["code"],
        expire: json["expire"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "name": name,
        "password_confirmation": passwordConfirmation,
        "email_verified_at": emailVerifiedAt,
        "city": city,
        "products_type": productsType,
        "address": address,
        "servicess": servicess,
        "website_link": websiteLink,
        "phone_number": phoneNumber,
        "tax_num": taxNum,
        "postal_code": postalCode,
        "state": state,
        "code": code,
        "expire": expire,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
}
