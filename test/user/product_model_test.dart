import 'package:flutter_test/flutter_test.dart';
import 'package:ship_link/user/data/models/allProducts/all_products.dart';
import 'package:ship_link/user/data/models/getTopSeller/getTopSeller.dart';

void main() {
  group('Product.fromJson numeric coercion (Phase 7 runtime crash fix)', () {
    test('tolerates Postgres boolean for is_offer/qty/popular/status', () {
      final p = Product.fromJson({
        'id': 1,
        'name': 'Test',
        'price': 10.0,
        'is_offer': true,
        'qty': false,
        'status': 1,
      });
      expect(p.isOffer, 1);
      expect(p.qty, 0);
      expect(p.status, 1);
    });

    test('tolerates int and string numeric values', () {
      final p = Product.fromJson({
        'is_offer': 0,
        'price': '9.5',
        'new_price': '7.2',
      });
      expect(p.isOffer, 0);
      expect(p.price, 9.5);
      expect(p.newPrice, 7.2);
    });

    test('nullable fields stay null', () {
      final p = Product.fromJson(const {});
      expect(p.isOffer, isNull);
      expect(p.qty, isNull);
    });
  });

  group('TopSeller.fromJson numeric coercion', () {
    test('tolerates boolean is_offer/popular', () {
      final t = TopSeller.fromJson({
        'id': 2,
        'is_offer': true,
        'popular': false,
        'status': 3,
        'qty': 5,
      });
      expect(t.isOffer, 1);
      expect(t.popular, 0);
      expect(t.status, 3);
      expect(t.qty, 5);
    });
  });
}
