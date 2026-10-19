import 'package:eventhub/shared/validation/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('qty', () {
    test('accepts the whole range from 1 to 10', () {
      for (var qty = 1; qty <= 10; qty++) {
        expect(Validators.qty(qty), isNull, reason: '$qty');
      }
    });

    test('rejects values outside the range', () {
      expect(Validators.qty(0), isNotNull);
      expect(Validators.qty(-1), isNotNull);
      expect(Validators.qty(11), isNotNull);
      expect(Validators.qty(null), isNotNull);
    });

    test('parses only whole numbers in range', () {
      expect(Validators.parseQty('3'), 3);
      expect(Validators.parseQty(' 10 '), 10);
      expect(Validators.parseQty('0'), isNull);
      expect(Validators.parseQty('11'), isNull);
      expect(Validators.parseQty('2.5'), isNull);
      expect(Validators.parseQty('abc'), isNull);
      expect(Validators.parseQty(null), isNull);
    });
  });

  group('email', () {
    test('accepts a regular address', () {
      expect(Validators.email('anna@mail.ru'), isNull);
      expect(Validators.email('  a.b+c@sub.example.com '), isNull);
    });

    test('rejects empty and malformed addresses', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('anna'), isNotNull);
      expect(Validators.email('anna@mail'), isNotNull);
      expect(Validators.email('anna @mail.ru'), isNotNull);
      expect(Validators.email('@mail.ru'), isNotNull);
    });
  });

  group('password', () {
    test('requires the minimum length', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  group('name', () {
    test('must not be blank', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name('   '), isNotNull);
      expect(Validators.name('Анна'), isNull);
    });
  });
}
