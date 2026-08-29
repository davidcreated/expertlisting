import 'package:expertlisting/features/feed/domain/author.dart';
import 'package:expertlisting/features/feed/domain/media_item.dart';
import 'package:expertlisting/features/feed/domain/post_category.dart';
import 'package:expertlisting/features/feed/domain/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionType wire mapping', () {
    test('every member round-trips through its wire value', () {
      for (final type in TransactionType.values) {
        expect(
          TransactionType.fromWire(type.wire),
          type,
          reason: '${type.name} did not round-trip via "${type.wire}"',
        );
      }
    });

    test('wire values are unique and never the display label', () {
      final wires = TransactionType.values.map((t) => t.wire).toSet();
      expect(wires.length, TransactionType.values.length);

      for (final type in TransactionType.values) {
        expect(type.wire, isNot(equals(type.label)));
      }
    });

    test('unknown and null values parse to null rather than a default', () {
      expect(TransactionType.fromWire(null), isNull);
      expect(TransactionType.fromWire('LEASEHOLD_SWAP'), isNull);
      expect(TransactionType.fromWire(''), isNull);
    });

    test('parsing tolerates casing and surrounding whitespace', () {
      expect(TransactionType.fromWire('  for_sale '), TransactionType.forSale);
    });

    test('every member has a distinct chip colour pair', () {
      final pairs = TransactionType.values
          .map((t) => '${t.foreground.toARGB32()}/${t.background.toARGB32()}')
          .toSet();
      expect(pairs.length, TransactionType.values.length);
    });
  });

  group('PostCategory wire mapping', () {
    test('every member round-trips through its wire value', () {
      for (final category in PostCategory.values) {
        expect(PostCategory.fromWire(category.wire), category);
      }
    });

    test('unknown values parse to null', () {
      expect(PostCategory.fromWire('ANNOUNCEMENT'), isNull);
      expect(PostCategory.fromWire(null), isNull);
    });
  });

  group('AuthorRole wire mapping', () {
    test('every member round-trips through its wire value', () {
      for (final role in AuthorRole.values) {
        expect(AuthorRole.fromWire(role.wire), role);
      }
    });

    test('unknown values parse to null', () {
      expect(AuthorRole.fromWire('LANDLORD'), isNull);
    });
  });

  group('MediaKind wire mapping', () {
    test('every member round-trips through its wire value', () {
      for (final kind in MediaKind.values) {
        expect(MediaKind.fromWire(kind.wire), kind);
      }
    });

    test('unknown values fall back to image so media still renders', () {
      expect(MediaKind.fromWire('GIF'), MediaKind.image);
      expect(MediaKind.fromWire(null), MediaKind.image);
    });
  });
}
