import 'package:test/test.dart';
import 'package:notebook_server/notebook_server.dart';

void main() {
  group('StringListConverter', () {
    late StringListConverter converter;

    setUp(() {
      converter = const StringListConverter();
    });

    group('fromSql', () {
      test('should convert JSON array string to List<String>', () {
        final result = converter.fromSql('["tag1","tag2","tag3"]');
        expect(result, ['tag1', 'tag2', 'tag3']);
      });

      test('should handle empty JSON array', () {
        final result = converter.fromSql('[]');
        expect(result, <String>[]);
      });

      test('should handle single item array', () {
        final result = converter.fromSql('["single"]');
        expect(result, ['single']);
      });

      test('should handle array with spaces in JSON', () {
        final result = converter.fromSql('["item 1", "item 2"]');
        expect(result, ['item 1', 'item 2']);
      });

      test('should return empty list for null input (not null)', () {
        final result = converter.fromSql(null);
        expect(result, <String>[]);
      });

      test('should handle array with special characters', () {
        final result = converter.fromSql('["tag@1","tag#2","tag\$3"]');
        expect(result, ['tag@1', 'tag#2', 'tag\$3']);
      });

      test('should handle empty strings in array', () {
        final result = converter.fromSql('["","non-empty",""]');
        expect(result, ['', 'non-empty', '']);
      });

      test('should handle null as empty string', () {
        final result = converter.fromSql(null);
        expect(result, <String>[]);
      });
    });

    group('toSql', () {
      test('should convert List<String> to JSON array string', () {
        final result = converter.toSql(['tag1', 'tag2', 'tag3']);
        expect(result, '["tag1","tag2","tag3"]');
      });

      test('should convert empty list to empty string (not JSON array)', () {
        final result = converter.toSql([]);
        expect(
          result,
          '',
        ); // Implementation returns empty string for empty list
      });

      test('should convert single item list', () {
        final result = converter.toSql(['single']);
        expect(result, '["single"]');
      });

      test('should handle strings with spaces', () {
        final result = converter.toSql(['item 1', 'item 2']);
        expect(result, '["item 1","item 2"]');
      });

      test('should handle special characters in strings', () {
        final result = converter.toSql(['tag@1', 'tag#2', 'tag\$3']);
        expect(result, '["tag@1","tag#2","tag\$3"]');
      });

      test('should escape quotes in strings', () {
        final result = converter.toSql(['tag"1', 'tag"2']);
        // JSON encoding should escape quotes
        expect(result, contains('\\"'));
      });

      test('should convert empty list to empty string', () {
        final result = converter.toSql([]);
        expect(result, '');
      });
    });

    group('Round-trip Conversion', () {
      test('should maintain data integrity for regular list', () {
        final original = ['tag1', 'tag2', 'tag3'];
        final sql = converter.toSql(original);
        final converted = converter.fromSql(sql);
        expect(converted, original);
      });

      test('should maintain data integrity for empty list', () {
        final original = <String>[];
        final sql = converter.toSql(original);
        // Empty list converts to empty string
        expect(sql, '');
        // Round-trip from empty string or null
        final converted = converter.fromSql(sql);
        expect(converted, original);
      });

      test('should maintain data integrity with special characters', () {
        final original = ['tag@1', 'tag#2', 'tag with spaces'];
        final sql = converter.toSql(original);
        final converted = converter.fromSql(sql);
        expect(converted, original);
      });

      test('should maintain data integrity with quotes', () {
        final original = ['tag"1', 'tag"2'];
        final sql = converter.toSql(original);
        final converted = converter.fromSql(sql);
        expect(converted, original);
      });
    });
  });
}
