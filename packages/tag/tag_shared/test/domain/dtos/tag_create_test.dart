import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

void main() {
  group('TagCreate', () {
    group('constructor', () {
      test('should create TagCreate with all fields', () {
        // Arrange & Act
        final tagCreate = TagCreate(
          name: 'Work',
          description: 'Work related tasks',
          color: '#FF5733',
        );

        // Assert
        expect(tagCreate.name, 'Work');
        expect(tagCreate.description, 'Work related tasks');
        expect(tagCreate.color, '#FF5733');
      });

      test('should create TagCreate with null optional fields', () {
        // Arrange & Act
        final tagCreate = TagCreate(
          name: 'Personal',
          description: null,
          color: null,
        );

        // Assert
        expect(tagCreate.name, 'Personal');
        expect(tagCreate.description, isNull);
        expect(tagCreate.color, isNull);
      });
    });

    group('isValid', () {
      test('should return true when name is not empty', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: null,
        );

        // Act & Assert
        expect(tagCreate.isValid, true);
      });

      test('should return false when name is empty', () {
        // Arrange
        final tagCreate = TagCreate(
          name: '',
          description: null,
          color: null,
        );

        // Act & Assert
        expect(tagCreate.isValid, false);
      });

      test('should return false when name is whitespace only', () {
        // Arrange
        final tagCreate = TagCreate(
          name: '   ',
          description: null,
          color: null,
        );

        // Act & Assert
        expect(tagCreate.isValid, false);
      });

      test('should return true with optional fields populated', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );

        // Act & Assert
        expect(tagCreate.isValid, true);
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        // Arrange
        final tagCreate1 = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );
        final tagCreate2 = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );

        // Assert
        expect(tagCreate1, equals(tagCreate2));
        expect(tagCreate1.hashCode, equals(tagCreate2.hashCode));
      });

      test('should not be equal when names differ', () {
        // Arrange
        final tagCreate1 = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );
        final tagCreate2 = TagCreate(
          name: 'Personal',
          description: 'Work tasks',
          color: '#FF5733',
        );

        // Assert
        expect(tagCreate1, isNot(equals(tagCreate2)));
      });

      test('should not be equal when descriptions differ', () {
        // Arrange
        final tagCreate1 = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );
        final tagCreate2 = TagCreate(
          name: 'Work',
          description: 'Personal tasks',
          color: '#FF5733',
        );

        // Assert
        expect(tagCreate1, isNot(equals(tagCreate2)));
      });

      test('should not be equal when colors differ', () {
        // Arrange
        final tagCreate1 = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );
        final tagCreate2 = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#00FF00',
        );

        // Assert
        expect(tagCreate1, isNot(equals(tagCreate2)));
      });

      test('should be equal when both have null optional fields', () {
        // Arrange
        final tagCreate1 = TagCreate(
          name: 'Work',
          description: null,
          color: null,
        );
        final tagCreate2 = TagCreate(
          name: 'Work',
          description: null,
          color: null,
        );

        // Assert
        expect(tagCreate1, equals(tagCreate2));
        expect(tagCreate1.hashCode, equals(tagCreate2.hashCode));
      });
    });

    group('edge cases', () {
      test('should handle single character name', () {
        // Arrange & Act
        final tagCreate = TagCreate(
          name: 'A',
          description: null,
          color: null,
        );

        // Assert
        expect(tagCreate.name, 'A');
        expect(tagCreate.isValid, true);
      });

      test('should handle very long name', () {
        // Arrange
        final longName = 'A' * 100;

        // Act
        final tagCreate = TagCreate(
          name: longName,
          description: null,
          color: null,
        );

        // Assert
        expect(tagCreate.name, longName);
        expect(tagCreate.isValid, true);
      });

      test('should handle special characters in all fields', () {
        // Arrange & Act
        final tagCreate = TagCreate(
          name: 'Work@#\$%',
          description: 'Special chars: éàü',
          color: '#FF5733',
        );

        // Assert
        expect(tagCreate.name, 'Work@#\$%');
        expect(tagCreate.description, 'Special chars: éàü');
        expect(tagCreate.isValid, true);
      });

      test('should handle very long description', () {
        // Arrange
        final longDescription = 'A' * 500;

        // Act
        final tagCreate = TagCreate(
          name: 'Work',
          description: longDescription,
          color: null,
        );

        // Assert
        expect(tagCreate.description, longDescription);
        expect(tagCreate.isValid, true);
      });
    });
  });
}
