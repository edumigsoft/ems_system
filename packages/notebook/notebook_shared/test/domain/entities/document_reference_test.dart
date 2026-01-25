import 'package:test/test.dart';
import 'package:notebook_shared/notebook_shared.dart';

void main() {
  group('DocumentReference', () {
    group('Constructor', () {
      test('should create instance with required fields', () {
        final doc = DocumentReference(
          name: 'document.pdf',
          path: '/path/to/document.pdf',
          storageType: DocumentStorageType.server,
        );

        expect(doc.name, 'document.pdf');
        expect(doc.path, '/path/to/document.pdf');
        expect(doc.storageType, DocumentStorageType.server);
        expect(doc.mimeType, isNull);
        expect(doc.sizeBytes, isNull);
      });

      test('should create instance with all fields', () {
        final doc = DocumentReference(
          name: 'report.pdf',
          path: '/downloads/report.pdf',
          storageType: DocumentStorageType.local,
          mimeType: 'application/pdf',
          sizeBytes: 1024000,
        );

        expect(doc.name, 'report.pdf');
        expect(doc.path, '/downloads/report.pdf');
        expect(doc.storageType, DocumentStorageType.local);
        expect(doc.mimeType, 'application/pdf');
        expect(doc.sizeBytes, 1024000);
      });
    });

    group('Type Detection - isPdf', () {
      test('should return true for PDF mime type', () {
        final doc = DocumentReference(
          name: 'doc.pdf',
          path: '/path',
          storageType: DocumentStorageType.server,
          mimeType: 'application/pdf',
        );

        expect(doc.isPdf, isTrue);
      });

      test('should return false for non-PDF mime type', () {
        final doc = DocumentReference(
          name: 'image.png',
          path: '/path',
          storageType: DocumentStorageType.server,
          mimeType: 'image/png',
        );

        expect(doc.isPdf, isFalse);
      });

      test('should return false when mimeType is null', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
        );

        expect(doc.isPdf, isFalse);
      });
    });

    group('Type Detection - isImage', () {
      test('should return true for image/png', () {
        final doc = DocumentReference(
          name: 'photo.png',
          path: '/path',
          storageType: DocumentStorageType.server,
          mimeType: 'image/png',
        );

        expect(doc.isImage, isTrue);
      });

      test('should return true for image/jpeg', () {
        final doc = DocumentReference(
          name: 'photo.jpg',
          path: '/path',
          storageType: DocumentStorageType.server,
          mimeType: 'image/jpeg',
        );

        expect(doc.isImage, isTrue);
      });

      test('should return false for non-image mime type', () {
        final doc = DocumentReference(
          name: 'doc.pdf',
          path: '/path',
          storageType: DocumentStorageType.server,
          mimeType: 'application/pdf',
        );

        expect(doc.isImage, isFalse);
      });

      test('should return false when mimeType is null', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
        );

        expect(doc.isImage, isFalse);
      });
    });

    group('Type Detection - isDocument', () {
      test('should return true for mime type containing "document"', () {
        final doc = DocumentReference(
          name: 'file.docx',
          path: '/path',
          storageType: DocumentStorageType.server,
          mimeType:
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        );

        expect(doc.isDocument, isTrue);
      });

      test('should return true for mime type containing "msword"', () {
        final doc = DocumentReference(
          name: 'file.doc',
          path: '/path',
          storageType: DocumentStorageType.server,
          mimeType: 'application/msword',
        );

        expect(doc.isDocument, isTrue);
      });

      test('should return true for mime type containing "text"', () {
        final doc = DocumentReference(
          name: 'file.txt',
          path: '/path',
          storageType: DocumentStorageType.server,
          mimeType: 'text/plain',
        );

        expect(doc.isDocument, isTrue);
      });

      test('should return false for non-document mime type', () {
        final doc = DocumentReference(
          name: 'image.png',
          path: '/path',
          storageType: DocumentStorageType.server,
          mimeType: 'image/png',
        );

        expect(doc.isDocument, isFalse);
      });

      test('should return false when mimeType is null', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
        );

        expect(doc.isDocument, isFalse);
      });
    });

    group('Storage Type Detection', () {
      test('isOnServer should return true for server storage', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/server/path',
          storageType: DocumentStorageType.server,
        );

        expect(doc.isOnServer, isTrue);
        expect(doc.isLocal, isFalse);
        expect(doc.isExternalUrl, isFalse);
      });

      test('isLocal should return true for local storage', () {
        final doc = DocumentReference(
          name: 'file',
          path: 'file:///local/path',
          storageType: DocumentStorageType.local,
        );

        expect(doc.isLocal, isTrue);
        expect(doc.isOnServer, isFalse);
        expect(doc.isExternalUrl, isFalse);
      });

      test('isExternalUrl should return true for url storage', () {
        final doc = DocumentReference(
          name: 'file',
          path: 'https://example.com/file.pdf',
          storageType: DocumentStorageType.url,
        );

        expect(doc.isExternalUrl, isTrue);
        expect(doc.isOnServer, isFalse);
        expect(doc.isLocal, isFalse);
      });
    });

    group('Size Formatting - formattedSize', () {
      test('should return "Desconhecido" when sizeBytes is null', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
        );

        expect(doc.formattedSize, 'Desconhecido');
      });

      test('should format bytes (< 1KB)', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          sizeBytes: 500,
        );

        expect(doc.formattedSize, '500 B');
      });

      test('should format kilobytes (>= 1KB, < 1MB)', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          sizeBytes: 1536, // 1.5 KB
        );

        expect(doc.formattedSize, '1.5 KB');
      });

      test('should format exactly 1KB', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          sizeBytes: 1024,
        );

        expect(doc.formattedSize, '1.0 KB');
      });

      test('should format megabytes (>= 1MB)', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          sizeBytes: 2621440, // 2.5 MB
        );

        expect(doc.formattedSize, '2.5 MB');
      });

      test('should format exactly 1MB', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          sizeBytes: 1024 * 1024,
        );

        expect(doc.formattedSize, '1.0 MB');
      });

      test('should format large files', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          sizeBytes: 52428800, // 50 MB
        );

        expect(doc.formattedSize, '50.0 MB');
      });
    });

    group('Large File Detection - isLargeFile', () {
      test('should return false when sizeBytes is null', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
        );

        expect(doc.isLargeFile, isFalse);
      });

      test('should return false for files smaller than 10MB', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          sizeBytes: 5 * 1024 * 1024, // 5 MB
        );

        expect(doc.isLargeFile, isFalse);
      });

      test('should return false for exactly 10MB', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          sizeBytes: 10 * 1024 * 1024, // Exactly 10 MB
        );

        expect(doc.isLargeFile, isFalse);
      });

      test('should return true for files larger than 10MB', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          sizeBytes: 11 * 1024 * 1024, // 11 MB
        );

        expect(doc.isLargeFile, isTrue);
      });

      test('should return true for very large files', () {
        final doc = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          sizeBytes: 100 * 1024 * 1024, // 100 MB
        );

        expect(doc.isLargeFile, isTrue);
      });
    });

    group('Display Name', () {
      test('displayName should return the name', () {
        final doc = DocumentReference(
          name: 'my-document.pdf',
          path: '/path',
          storageType: DocumentStorageType.server,
        );

        expect(doc.displayName, 'my-document.pdf');
      });
    });

    group('Equality and HashCode', () {
      test('should be equal when all fields match', () {
        final doc1 = DocumentReference(
          name: 'file.pdf',
          path: '/path',
          storageType: DocumentStorageType.server,
          mimeType: 'application/pdf',
          sizeBytes: 1024,
        );

        final doc2 = DocumentReference(
          name: 'file.pdf',
          path: '/path',
          storageType: DocumentStorageType.server,
          mimeType: 'application/pdf',
          sizeBytes: 1024,
        );

        expect(doc1, equals(doc2));
        expect(doc1.hashCode, equals(doc2.hashCode));
      });

      test('should not be equal when name differs', () {
        final doc1 = DocumentReference(
          name: 'file1.pdf',
          path: '/path',
          storageType: DocumentStorageType.server,
        );

        final doc2 = DocumentReference(
          name: 'file2.pdf',
          path: '/path',
          storageType: DocumentStorageType.server,
        );

        expect(doc1, isNot(equals(doc2)));
      });

      test('should not be equal when path differs', () {
        final doc1 = DocumentReference(
          name: 'file.pdf',
          path: '/path1',
          storageType: DocumentStorageType.server,
        );

        final doc2 = DocumentReference(
          name: 'file.pdf',
          path: '/path2',
          storageType: DocumentStorageType.server,
        );

        expect(doc1, isNot(equals(doc2)));
      });

      test('should not be equal when storageType differs', () {
        final doc1 = DocumentReference(
          name: 'file.pdf',
          path: '/path',
          storageType: DocumentStorageType.server,
        );

        final doc2 = DocumentReference(
          name: 'file.pdf',
          path: '/path',
          storageType: DocumentStorageType.local,
        );

        expect(doc1, isNot(equals(doc2)));
      });

      test('should not be equal when mimeType differs', () {
        final doc1 = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          mimeType: 'application/pdf',
        );

        final doc2 = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          mimeType: 'image/png',
        );

        expect(doc1, isNot(equals(doc2)));
      });

      test('should not be equal when sizeBytes differs', () {
        final doc1 = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          sizeBytes: 1024,
        );

        final doc2 = DocumentReference(
          name: 'file',
          path: '/path',
          storageType: DocumentStorageType.server,
          sizeBytes: 2048,
        );

        expect(doc1, isNot(equals(doc2)));
      });
    });

    group('toString', () {
      test('should include name and storage type', () {
        final doc = DocumentReference(
          name: 'document.pdf',
          path: '/path',
          storageType: DocumentStorageType.server,
        );

        expect(
          doc.toString(),
          equals(
            'DocumentReference(name: document.pdf, type: DocumentStorageType.server)',
          ),
        );
      });

      test('should work with different storage types', () {
        final doc = DocumentReference(
          name: 'local-file.txt',
          path: 'file:///local',
          storageType: DocumentStorageType.local,
        );

        expect(
          doc.toString(),
          equals(
            'DocumentReference(name: local-file.txt, type: DocumentStorageType.local)',
          ),
        );
      });
    });
  });
}
