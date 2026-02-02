import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

void main() {
  group('TagUpdate', () {
    group('constructor', () {
      test('should create TagUpdate with id and all optional fields', () {
        // Arrange & Act
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Work',
          description: 'Work related tasks',
          color: '#FF5733',
          isActive: true,
          isDeleted: false,
        );

        // Assert
        expect(tagUpdate.id, 'tag-123');
        expect(tagUpdate.name, 'Work');
        expect(tagUpdate.description, 'Work related tasks');
        expect(tagUpdate.color, '#FF5733');
        expect(tagUpdate.isActive, true);
        expect(tagUpdate.isDeleted, false);
      });

      test('should create TagUpdate with only id', () {
        // Arrange & Act
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Assert
        expect(tagUpdate.id, 'tag-123');
        expect(tagUpdate.name, isNull);
        expect(tagUpdate.description, isNull);
        expect(tagUpdate.color, isNull);
        expect(tagUpdate.isActive, isNull);
        expect(tagUpdate.isDeleted, isNull);
      });
    });

    group('hasChanges', () {
      test('should return true when name is provided', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act & Assert
        expect(tagUpdate.hasChanges, true);
      });

      test('should return true when description is provided', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: 'Work tasks',
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act & Assert
        expect(tagUpdate.hasChanges, true);
      });

      test('should return true when color is provided', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: '#FF5733',
          isActive: null,
          isDeleted: null,
        );

        // Act & Assert
        expect(tagUpdate.hasChanges, true);
      });

      test('should return true when isActive is provided', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: true,
          isDeleted: null,
        );

        // Act & Assert
        expect(tagUpdate.hasChanges, true);
      });

      test('should return true when isDeleted is provided', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: false,
        );

        // Act & Assert
        expect(tagUpdate.hasChanges, true);
      });

      test('should return true when multiple fields are provided', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
          isActive: true,
          isDeleted: false,
        );

        // Act & Assert
        expect(tagUpdate.hasChanges, true);
      });

      test('should return false when no fields are provided', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act & Assert
        expect(tagUpdate.hasChanges, false);
      });

      test('should return true even when isActive is false', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: false,
          isDeleted: null,
        );

        // Act & Assert
        expect(tagUpdate.hasChanges, true);
      });

      test('should return true even when isDeleted is true', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: true,
        );

        // Act & Assert
        expect(tagUpdate.hasChanges, true);
      });
    });

    group('isValid', () {
      test('should return true when id is not empty', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act & Assert
        expect(tagUpdate.isValid, true);
      });

      test('should return false when id is empty', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: '',
          name: 'Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act & Assert
        expect(tagUpdate.isValid, false);
      });

      test('should return false when id is whitespace only', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: '   ',
          name: 'Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act & Assert
        expect(tagUpdate.isValid, false);
      });

      test('should return true even when no changes', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act & Assert
        expect(tagUpdate.isValid, true);
      });
    });

    group('equality', () {
      test('should be equal when all fields are the same', () {
        // Arrange
        final tagUpdate1 = TagUpdate(
          id: 'tag-123',
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
          isActive: true,
          isDeleted: false,
        );
        final tagUpdate2 = TagUpdate(
          id: 'tag-123',
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
          isActive: true,
          isDeleted: false,
        );

        // Assert
        expect(tagUpdate1, equals(tagUpdate2));
        expect(tagUpdate1.hashCode, equals(tagUpdate2.hashCode));
      });

      test('should not be equal when ids differ', () {
        // Arrange
        final tagUpdate1 = TagUpdate(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );
        final tagUpdate2 = TagUpdate(
          id: 'tag-456',
          name: 'Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Assert
        expect(tagUpdate1, isNot(equals(tagUpdate2)));
      });

      test('should not be equal when names differ', () {
        // Arrange
        final tagUpdate1 = TagUpdate(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );
        final tagUpdate2 = TagUpdate(
          id: 'tag-123',
          name: 'Personal',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Assert
        expect(tagUpdate1, isNot(equals(tagUpdate2)));
      });

      test('should be equal when both have null optional fields', () {
        // Arrange
        final tagUpdate1 = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );
        final tagUpdate2 = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Assert
        expect(tagUpdate1, equals(tagUpdate2));
        expect(tagUpdate1.hashCode, equals(tagUpdate2.hashCode));
      });
    });

    group('partial update scenarios', () {
      test('should support updating only name', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Updated Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Assert
        expect(tagUpdate.hasChanges, true);
        expect(tagUpdate.name, 'Updated Work');
        expect(tagUpdate.description, isNull);
        expect(tagUpdate.color, isNull);
      });

      test('should support updating only isActive flag', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: false,
          isDeleted: null,
        );

        // Assert
        expect(tagUpdate.hasChanges, true);
        expect(tagUpdate.isActive, false);
      });

      test('should support soft delete via isDeleted', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: true,
        );

        // Assert
        expect(tagUpdate.hasChanges, true);
        expect(tagUpdate.isDeleted, true);
      });

      test('should support restoring via isDeleted', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: false,
        );

        // Assert
        expect(tagUpdate.hasChanges, true);
        expect(tagUpdate.isDeleted, false);
      });

      test('should support updating name and color only', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Updated',
          description: null,
          color: '#00FF00',
          isActive: null,
          isDeleted: null,
        );

        // Assert
        expect(tagUpdate.hasChanges, true);
        expect(tagUpdate.name, 'Updated');
        expect(tagUpdate.color, '#00FF00');
        expect(tagUpdate.description, isNull);
      });
    });

    group('edge cases', () {
      test('should handle empty string name as a change', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: '',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Assert
        expect(tagUpdate.hasChanges, true);
        expect(tagUpdate.name, '');
      });

      test('should handle very long id', () {
        // Arrange
        final longId = 'tag-${'a' * 100}';
        final tagUpdate = TagUpdate(
          id: longId,
          name: 'Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Assert
        expect(tagUpdate.id, longId);
        expect(tagUpdate.isValid, true);
      });
    });
  });
}
