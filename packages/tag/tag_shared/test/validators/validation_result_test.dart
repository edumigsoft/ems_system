import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

void main() {
  group('ValidationResult', () {
    group('constructor', () {
      test('should create ValidationResult with empty errors list', () {
        // Arrange & Act
        final result = ValidationResult([]);

        // Assert
        expect(result.errors, isEmpty);
      });

      test('should create ValidationResult with single error', () {
        // Arrange
        final error = ValidationError(
          field: 'name',
          message: 'Name is required',
        );

        // Act
        final result = ValidationResult([error]);

        // Assert
        expect(result.errors, hasLength(1));
        expect(result.errors.first, error);
      });

      test('should create ValidationResult with multiple errors', () {
        // Arrange
        final errors = [
          ValidationError(field: 'name', message: 'Name is required'),
          ValidationError(field: 'color', message: 'Invalid color format'),
        ];

        // Act
        final result = ValidationResult(errors);

        // Assert
        expect(result.errors, hasLength(2));
        expect(result.errors, errors);
      });
    });

    group('isValid', () {
      test('should return true when errors list is empty', () {
        // Arrange
        final result = ValidationResult([]);

        // Act & Assert
        expect(result.isValid, true);
      });

      test('should return false when errors list is not empty', () {
        // Arrange
        final result = ValidationResult([
          ValidationError(field: 'name', message: 'Name is required'),
        ]);

        // Act & Assert
        expect(result.isValid, false);
      });
    });

    group('isInvalid', () {
      test('should return false when errors list is empty', () {
        // Arrange
        final result = ValidationResult([]);

        // Act & Assert
        expect(result.isInvalid, false);
      });

      test('should return true when errors list is not empty', () {
        // Arrange
        final result = ValidationResult([
          ValidationError(field: 'name', message: 'Name is required'),
        ]);

        // Act & Assert
        expect(result.isInvalid, true);
      });
    });

    group('firstErrorMessage', () {
      test('should return null when no errors', () {
        // Arrange
        final result = ValidationResult([]);

        // Act & Assert
        expect(result.firstErrorMessage, isNull);
      });

      test('should return first error message when single error', () {
        // Arrange
        final result = ValidationResult([
          ValidationError(field: 'name', message: 'Name is required'),
        ]);

        // Act & Assert
        expect(result.firstErrorMessage, 'Name is required');
      });

      test('should return first error message when multiple errors', () {
        // Arrange
        final result = ValidationResult([
          ValidationError(field: 'name', message: 'Name is required'),
          ValidationError(field: 'color', message: 'Invalid color format'),
        ]);

        // Act & Assert
        expect(result.firstErrorMessage, 'Name is required');
      });
    });
  });

  group('ValidationError', () {
    group('constructor', () {
      test('should create ValidationError with field and message', () {
        // Arrange & Act
        final error = ValidationError(
          field: 'name',
          message: 'Name is required',
        );

        // Assert
        expect(error.field, 'name');
        expect(error.message, 'Name is required');
      });

      test('should create ValidationError with empty strings', () {
        // Arrange & Act
        final error = ValidationError(
          field: '',
          message: '',
        );

        // Assert
        expect(error.field, '');
        expect(error.message, '');
      });
    });

    group('equality', () {
      test('should be equal when field and message are the same', () {
        // Arrange
        final error1 = ValidationError(
          field: 'name',
          message: 'Name is required',
        );
        final error2 = ValidationError(
          field: 'name',
          message: 'Name is required',
        );

        // Assert
        expect(error1, equals(error2));
        expect(error1.hashCode, equals(error2.hashCode));
      });

      test('should not be equal when fields differ', () {
        // Arrange
        final error1 = ValidationError(
          field: 'name',
          message: 'Name is required',
        );
        final error2 = ValidationError(
          field: 'color',
          message: 'Name is required',
        );

        // Assert
        expect(error1, isNot(equals(error2)));
      });

      test('should not be equal when messages differ', () {
        // Arrange
        final error1 = ValidationError(
          field: 'name',
          message: 'Name is required',
        );
        final error2 = ValidationError(
          field: 'name',
          message: 'Name is too short',
        );

        // Assert
        expect(error1, isNot(equals(error2)));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        // Arrange
        final error = ValidationError(
          field: 'name',
          message: 'Name is required',
        );

        // Act
        final string = error.toString();

        // Assert
        expect(string, 'name: Name is required');
      });
    });
  });
}
