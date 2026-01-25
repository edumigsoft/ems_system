import 'package:test/test.dart';
import 'package:notebook_server/notebook_server.dart';
import 'package:notebook_shared/notebook_shared.dart';

void main() {
  group('NotebookTypeConverter', () {
    late NotebookTypeConverter converter;

    setUp(() {
      converter = const NotebookTypeConverter();
    });

    group('fromSql', () {
      test('should convert "quick" to NotebookType.quick', () {
        final result = converter.fromSql('quick');
        expect(result, NotebookType.quick);
      });

      test('should convert "organized" to NotebookType.organized', () {
        final result = converter.fromSql('organized');
        expect(result, NotebookType.organized);
      });

      test('should convert "reminder" to NotebookType.reminder', () {
        final result = converter.fromSql('reminder');
        expect(result, NotebookType.reminder);
      });

      test('should return NotebookType.quick for null input', () {
        final result = converter.fromSql(null);
        expect(result, NotebookType.quick);
      });

      test('should return NotebookType.quick for invalid string', () {
        final result = converter.fromSql('invalid_type');
        expect(result, NotebookType.quick);
      });

      test('should return NotebookType.quick for empty string', () {
        final result = converter.fromSql('');
        expect(result, NotebookType.quick);
      });

      test('should handle case-sensitive input correctly', () {
        // Should not match because enum uses lowercase
        final result = converter.fromSql('QUICK');
        expect(result, NotebookType.quick); // Falls back to default
      });
    });

    group('toSql', () {
      test('should convert NotebookType.quick to "quick"', () {
        final result = converter.toSql(NotebookType.quick);
        expect(result, 'quick');
      });

      test('should convert NotebookType.organized to "organized"', () {
        final result = converter.toSql(NotebookType.organized);
        expect(result, 'organized');
      });

      test('should convert NotebookType.reminder to "reminder"', () {
        final result = converter.toSql(NotebookType.reminder);
        expect(result, 'reminder');
      });
    });

    group('Round-trip Conversion', () {
      test('should maintain data integrity for quick type', () {
        const original = NotebookType.quick;
        final sql = converter.toSql(original);
        final converted = converter.fromSql(sql);
        expect(converted, original);
      });

      test('should maintain data integrity for organized type', () {
        const original = NotebookType.organized;
        final sql = converter.toSql(original);
        final converted = converter.fromSql(sql);
        expect(converted, original);
      });

      test('should maintain data integrity for reminder type', () {
        const original = NotebookType.reminder;
        final sql = converter.toSql(original);
        final converted = converter.fromSql(sql);
        expect(converted, original);
      });
    });
  });
}
