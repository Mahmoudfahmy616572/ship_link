// To parse this JSON data, do
//
//     final sneakers = sneakersFromJson(jsonString);

import 'dart:convert';

Sneakers sneakersFromJson(String str) => Sneakers.fromJson(json.decode(str));

class Sneakers {
  final Collection collection;

  Sneakers({
    required this.collection,
  });

  factory Sneakers.fromJson(Map<String, dynamic> json) => Sneakers(
        collection: Collection.fromJson(json["collection"]),
      );
}

class Collection {
  final Info info;
  final List<CollectionItem> item;

  Collection({
    required this.info,
    required this.item,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        info: Info.fromJson(json["info"]),
        item: List<CollectionItem>.from(
            json["item"].map((x) => CollectionItem.fromJson(x))),
      );
}

class Info {
  final String postmanId;
  final String name;
  final String schema;
  final DateTime updatedAt;
  final String uid;
  final dynamic createdAt;
  final dynamic lastUpdatedBy;

  Info({
    required this.postmanId,
    required this.name,
    required this.schema,
    required this.updatedAt,
    required this.uid,
    required this.createdAt,
    required this.lastUpdatedBy,
  });

  factory Info.fromJson(Map<String, dynamic> json) => Info(
        postmanId: json["_postman_id"],
        name: json["name"],
        schema: json["schema"],
        updatedAt: DateTime.parse(json["updatedAt"]),
        uid: json["uid"],
        createdAt: json["createdAt"],
        lastUpdatedBy: json["lastUpdatedBy"],
      );
}

class CollectionItem {
  final String name;
  final List<PurpleItem> item;
  final String id;
  final String uid;

  CollectionItem({
    required this.name,
    required this.item,
    required this.id,
    required this.uid,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) => CollectionItem(
        name: json["name"],
        item: List<PurpleItem>.from(
            json["item"].map((x) => PurpleItem.fromJson(x))),
        id: json["id"],
        uid: json["uid"],
      );
}

//////////////////////////////////////

class PurpleItem {
  final String name;
  final List<FluffyItem> item;
  final String id;
  final String uid;

  PurpleItem({
    required this.name,
    required this.item,
    required this.id,
    required this.uid,
  });

  factory PurpleItem.fromJson(Map<String, dynamic> json) => PurpleItem(
        name: json["name"],
        item: List<FluffyItem>.from(
            json["item"].map((x) => FluffyItem.fromJson(x))),
        id: json["id"],
        uid: json["uid"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "item": List<dynamic>.from(item.map((x) => x.toJson())),
        "id": id,
        "uid": uid,
      };
}

class FluffyItem {
  final String name;
  final String id;
  final ProtocolProfileBehavior protocolProfileBehavior;
  final Request request;
  final List<dynamic> response;
  final String uid;

  FluffyItem({
    required this.name,
    required this.id,
    required this.protocolProfileBehavior,
    required this.request,
    required this.response,
    required this.uid,
  });

  factory FluffyItem.fromJson(Map<String, dynamic> json) => FluffyItem(
        name: json["name"],
        id: json["id"],
        protocolProfileBehavior:
            ProtocolProfileBehavior.fromJson(json["protocolProfileBehavior"]),
        request: Request.fromJson(json["request"]),
        response: List<dynamic>.from(json["response"].map((x) => x)),
        uid: json["uid"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "protocolProfileBehavior": protocolProfileBehavior.toJson(),
        "request": request.toJson(),
        "response": List<dynamic>.from(response.map((x) => x)),
        "uid": uid,
      };
}

class ProtocolProfileBehavior {
  final bool disableBodyPruning;

  ProtocolProfileBehavior({
    required this.disableBodyPruning,
  });

  factory ProtocolProfileBehavior.fromJson(Map<String, dynamic> json) =>
      ProtocolProfileBehavior(
        disableBodyPruning: json["disableBodyPruning"],
      );

  Map<String, dynamic> toJson() => {
        "disableBodyPruning": disableBodyPruning,
      };
}

class Request {
  final Auth auth;
  final Method method;
  final List<Header> header;
  final Body body;
  final Url url;

  Request({
    required this.auth,
    required this.method,
    required this.header,
    required this.body,
    required this.url,
  });

  factory Request.fromJson(Map<String, dynamic> json) => Request(
        auth: Auth.fromJson(json["auth"]),
        method: methodValues.map[json["method"]]!,
        header:
            List<Header>.from(json["header"].map((x) => Header.fromJson(x))),
        body: Body.fromJson(json["body"]),
        url: Url.fromJson(json["url"]),
      );

  Map<String, dynamic> toJson() => {
        "auth": auth.toJson(),
        "method": methodValues.reverse[method],
        "header": List<dynamic>.from(header.map((x) => x.toJson())),
        "body": body.toJson(),
        "url": url.toJson(),
      };
}

class Auth {
  final AuthType type;
  final List<Header> bearer;

  Auth({
    required this.type,
    required this.bearer,
  });

  factory Auth.fromJson(Map<String, dynamic> json) => Auth(
        type: authTypeValues.map[json["type"]]!,
        bearer:
            List<Header>.from(json["bearer"].map((x) => Header.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "type": authTypeValues.reverse[type],
        "bearer": List<dynamic>.from(bearer.map((x) => x.toJson())),
      };
}

class Header {
  final Key key;
  final String value;
  final HeaderType type;

  Header({
    required this.key,
    required this.value,
    required this.type,
  });

  factory Header.fromJson(Map<String, dynamic> json) => Header(
        key: keyValues.map[json["key"]]!,
        value: json["value"],
        type: headerTypeValues.map[json["type"]]!,
      );

  Map<String, dynamic> toJson() => {
        "key": keyValues.reverse[key],
        "value": value,
        "type": headerTypeValues.reverse[type],
      };
}

enum Key { CONTENT_TYPE, TOKEN, X_REQUESTED_WITH }

final keyValues = EnumValues({
  "Content-Type": Key.CONTENT_TYPE,
  "token": Key.TOKEN,
  "X-Requested-With": Key.X_REQUESTED_WITH
});

enum HeaderType { STRING, TEXT }

final headerTypeValues =
    EnumValues({"string": HeaderType.STRING, "text": HeaderType.TEXT});

enum AuthType { BEARER }

final authTypeValues = EnumValues({"bearer": AuthType.BEARER});

class Body {
  final Mode mode;
  final String raw;

  Body({
    required this.mode,
    required this.raw,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        mode: modeValues.map[json["mode"]]!,
        raw: json["raw"],
      );

  Map<String, dynamic> toJson() => {
        "mode": modeValues.reverse[mode],
        "raw": raw,
      };
}

enum Mode { RAW }

final modeValues = EnumValues({"raw": Mode.RAW});

enum Method { POST }

final methodValues = EnumValues({"POST": Method.POST});

class Url {
  final String raw;
  final Protocol protocol;
  final List<String> host;
  final String port;
  final List<String> path;

  Url({
    required this.raw,
    required this.protocol,
    required this.host,
    required this.port,
    required this.path,
  });

  factory Url.fromJson(Map<String, dynamic> json) => Url(
        raw: json["raw"],
        protocol: protocolValues.map[json["protocol"]]!,
        host: List<String>.from(json["host"].map((x) => x)),
        port: json["port"],
        path: List<String>.from(json["path"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "raw": raw,
        "protocol": protocolValues.reverse[protocol],
        "host": List<dynamic>.from(host.map((x) => x)),
        "port": port,
        "path": List<dynamic>.from(path.map((x) => x)),
      };
}

enum Protocol { HTTP }

final protocolValues = EnumValues({"http": Protocol.HTTP});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
