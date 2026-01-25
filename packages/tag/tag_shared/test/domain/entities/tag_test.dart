import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

void main() {
  group('Tag', () {
    group('constructor', () {
      test('should create Tag with all fields', () {
        // Arrange & Act
        final tag = Tag(
          name: 'Work',
          description: 'Work related tasks',
          color: '#FF5733',
        );

        // Assert
        expect(tag.name, 'Work');
        expect(tag.description, 'Work related tasks');
        expect(tag.color, '#FF5733');
      });

      test('should create Tag with optional fields as null', () {
        // Arrange & Act
        final tag = Tag(
          name: 'Personal',
          description: null,
          color: null,
        );

        // Assert
        expect(tag.name, 'Personal');
        expect(tag.description, isNull);
        expect(tag.color, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated name', () {
        // Arrange
        final original = Tag(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );

        // Act
        final updated = original.copyWith(name: 'Personal');

        // Assert
        expect(updated.name, 'Personal');
        expect(updated.description, 'Work tasks');
        expect(updated.color, '#FF5733');
      });

      test('should create copy with updated description', () {
        // Arrange
        final original = Tag(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );

        // Act
        final updated = original.copyWith(description: 'Updated description');

        // Assert
        expect(updated.name, 'Work');
        expect(updated.description, 'Updated description');
        expect(updated.color, '#FF5733');
      });

      test('should create copy with updated color', () {
        // Arrange
        final original = Tag(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );

        // Act
        final updated = original.copyWith(color: '#00FF00');

        // Assert
        expect(updated.name, 'Work');
        expect(updated.description, 'Work tasks');
        expect(updated.color, '#00FF00');
      });

      test('should create copy with multiple updated fields', () {
        // Arrange
        final original = Tag(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );

        // Act
        final updated = original.copyWith(
          name: 'Personal',
          description: 'Personal tasks',
        );

        // Assert
        expect(updated.name, 'Personal');
        expect(updated.description, 'Personal tasks');
        expect(updated.color, '#FF5733');
      });

      test('should create exact copy when no fields are updated', () {
        // Arrange
        final original = Tag(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.name, original.name);
        expect(copy.description, original.description);
        expect(copy.color, original.color);
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        // Arrange
        final tag1 = Tag(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );
        final tag2 = Tag(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );

        // Assert
        expect(tag1, equals(tag2));
        expect(tag1.hashCode, equals(tag2.hashCode));
      });

      test('should not be equal when names differ', () {
        // Arrange
        final tag1 = Tag(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );
        final tag2 = Tag(
          name: 'Personal',
          description: 'Work tasks',
          color: '#FF5733',
        );

        // Assert
        expect(tag1, isNot(equals(tag2)));
      });

      test('should not be equal when descriptions differ', () {
        // Arrange
        final tag1 = Tag(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );
        final tag2 = Tag(
          name: 'Work',
          description: 'Different description',
          color: '#FF5733',
        );

        // Assert
        expect(tag1, isNot(equals(tag2)));
      });

      test('should not be equal when colors differ', () {
        // Arrange
        final tag1 = Tag(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );
        final tag2 = Tag(
          name: 'Work',
          description: 'Work tasks',
          color: '#00FF00',
        );

        // Assert
        expect(tag1, isNot(equals(tag2)));
      });

      test('should be equal when both have null optional fields', () {
        // Arrange
        final tag1 = Tag(
          name: 'Work',
          description: null,
          color: null,
        );
        final tag2 = Tag(
          name: 'Work',
          description: null,
          color: null,
        );

        // Assert
        expect(tag1, equals(tag2));
        expect(tag1.hashCode, equals(tag2.hashCode));
      });
    });

    group('toString', () {
      test('should return string representation with all fields', () {
        // Arrange
        final tag = Tag(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );

        // Act
        final string = tag.toString();

        // Assert
        expect(
          string,
          'Tag(name: Work, description: Work tasks, color: #FF5733)',
        );
      });

      test('should return string representation with null fields', () {
        // Arrange
        final tag = Tag(
          name: 'Personal',
          description: null,
          color: null,
        );

        // Act
        final string = tag.toString();

        // Assert
        expect(string, 'Tag(name: Personal, description: null, color: null)');
      });
    });

    group('edge cases', () {
      test('should handle empty string name', () {
        // Arrange & Act
        final tag = Tag(
          name: '',
          description: null,
          color: null,
        );

        // Assert
        expect(tag.name, '');
      });

      test('should handle very long name', () {
        // Arrange
        final longName = 'A' * 100;

        // Act
        final tag = Tag(
          name: longName,
          description: null,
          color: null,
        );

        // Assert
        expect(tag.name, longName);
      });

      test('should handle special characters in name', () {
        // Arrange & Act
        final tag = Tag(
          name: 'Work@#\$%',
          description: null,
          color: null,
        );

        // Assert
        expect(tag.name, 'Work@#\$%');
      });
    });
  });
}
