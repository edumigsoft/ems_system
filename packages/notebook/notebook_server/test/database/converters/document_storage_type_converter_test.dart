import 'package:test/test.dart';
import 'package:notebook_server/notebook_server.dart';
import 'package:notebook_shared/notebook_shared.dart';

void main() {
  group('DocumentStorageTypeConverter', () {
    late DocumentStorageTypeConverter converter;

    setUp(() {
      converter = const DocumentStorageTypeConverter();
    });

    group('fromSql', () {
      test('should convert "server" to DocumentStorageType.server', () {
        final result = converter.fromSql('server');
        expect(result, DocumentStorageType.server);
      });

      test('should convert "local" to DocumentStorageType.local', () {
        final result = converter.fromSql('local');
        expect(result, DocumentStorageType.local);
      });

      test('should convert "url" to DocumentStorageType.url', () {
        final result = converter.fromSql('url');
        expect(result, DocumentStorageType.url);
      });

      test('should return DocumentStorageType.server for null input', () {
        final result = converter.fromSql(null);
        expect(result, DocumentStorageType.server);
      });

      test('should return DocumentStorageType.server for invalid string', () {
        final result = converter.fromSql('ftp');
        expect(result, DocumentStorageType.server);
      });

      test('should return DocumentStorageType.server for empty string', () {
        final result = converter.fromSql('');
        expect(result, DocumentStorageType.server);
      });
    });

    group('toSql', () {
      test('should convert DocumentStorageType.server to "server"', () {
        final result = converter.toSql(DocumentStorageType.server);
        expect(result, 'server');
      });

      test('should convert DocumentStorageType.local to "local"', () {
        final result = converter.toSql(DocumentStorageType.local);
        expect(result, 'local');
      });

      test('should convert DocumentStorageType.url to "url"', () {
        final result = converter.toSql(DocumentStorageType.url);
        expect(result, 'url');
      });
    });

    group('Round-trip Conversion', () {
      test('should maintain data integrity for server type', () {
        const original = DocumentStorageType.server;
        final sql = converter.toSql(original);
        final converted = converter.fromSql(sql);
        expect(converted, original);
      });

      test('should maintain data integrity for local type', () {
        const original = DocumentStorageType.local;
        final sql = converter.toSql(original);
        final converted = converter.fromSql(sql);
        expect(converted, original);
      });

      test('should maintain data integrity for url type', () {
        const original = DocumentStorageType.url;
        final sql = converter.toSql(original);
        final converted = converter.fromSql(sql);
        expect(converted, original);
      });
    });
  });
}
