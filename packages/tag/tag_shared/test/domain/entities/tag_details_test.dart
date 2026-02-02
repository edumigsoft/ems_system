import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

void main() {
  group('TagDetails', () {
    group('constructor', () {
      test('should create TagDetails with all required fields', () {
        // Arrange
        final now = DateTime.now();

        // Act
        final details = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
          isActive: true,
          isDeleted: false,
          usageCount: 5,
          createdAt: now,
          updatedAt: now,
        );

        // Assert
        expect(details.id, 'tag-123');
        expect(details.name, 'Work');
        expect(details.description, 'Work tasks');
        expect(details.color, '#FF5733');
        expect(details.isActive, true);
        expect(details.isDeleted, false);
        expect(details.usageCount, 5);
        expect(details.createdAt, now);
        expect(details.updatedAt, now);
      });

      test('should create TagDetails with default values', () {
        // Arrange
        final now = DateTime.now();

        // Act
        final details = TagDetails(
          id: 'tag-456',
          name: 'Personal',
          description: null,
          color: null,
          createdAt: now,
          updatedAt: now,
        );

        // Assert
        expect(details.isActive, true);
        expect(details.isDeleted, false);
        expect(details.usageCount, 0);
      });
    });

    group('convenience getters', () {
      test('should return name from data', () {
        // Arrange
        final details = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
          usageCount: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(details.name, 'Work');
      });

      test('should return description from data', () {
        // Arrange
        final details = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
          usageCount: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(details.description, 'Work tasks');
      });

      test('should return color from data', () {
        // Arrange
        final details = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
          usageCount: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(details.color, '#FF5733');
      });

      test('should return null when description is null', () {
        // Arrange
        final details = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: '#FF5733',
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(details.description, isNull);
      });

      test('should return null when color is null', () {
        // Arrange
        final details = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: 'Work tasks',
          color: null,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(details.color, isNull);
      });

      test('should return true when tag is used (usageCount > 0)', () {
        // Arrange
        final details = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          usageCount: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(details.isUsed, true);
      });

      test('should return false when tag is not used (usageCount = 0)', () {
        // Arrange
        final details = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(details.isUsed, false);
      });
    });

    group('equality', () {
      test('should be equal when ids are the same', () {
        // Arrange
        final now = DateTime.now();

        final details1 = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          isActive: true,
          isDeleted: false,
          usageCount: 5,
          createdAt: now,
          updatedAt: now,
        );

        final details2 = TagDetails(
          id: 'tag-123',
          name: 'Personal',
          description: null,
          color: null,
          isActive: false,
          isDeleted: true,
          usageCount: 10,
          createdAt: now.add(Duration(days: 1)),
          updatedAt: now.add(Duration(days: 1)),
        );

        // Assert - equality is based on id only
        expect(details1, equals(details2));
        expect(details1.hashCode, equals(details2.hashCode));
      });

      test('should not be equal when ids differ', () {
        // Arrange
        final now = DateTime.now();

        final details1 = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          usageCount: 5,
          createdAt: now,
          updatedAt: now,
        );

        final details2 = TagDetails(
          id: 'tag-456',
          name: 'Work',
          description: null,
          color: null,
          usageCount: 5,
          createdAt: now,
          updatedAt: now,
        );

        // Assert
        expect(details1, isNot(equals(details2)));
      });
    });

    group('BaseDetails interface', () {
      test('should implement BaseDetails', () {
        // Arrange
        final details = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert - TagDetails should have all BaseDetails properties
        expect(details.id, isNotNull);
        expect(details.isActive, isA<bool>());
        expect(details.isDeleted, isA<bool>());
        expect(details.createdAt, isA<DateTime>());
        expect(details.updatedAt, isA<DateTime>());
      });
    });

    group('edge cases', () {
      test('should handle very large usageCount', () {
        // Arrange
        final details = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          usageCount: 999999999,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(details.usageCount, 999999999);
        expect(details.isUsed, true);
      });

      test('should handle inactive and deleted tag', () {
        // Arrange
        final details = TagDetails(
          id: 'tag-123',
          name: 'Archived',
          description: null,
          color: null,
          isActive: false,
          isDeleted: true,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(details.isActive, false);
        expect(details.isDeleted, true);
      });

      test('should handle updatedAt being after createdAt', () {
        // Arrange
        final createdAt = DateTime(2024, 1, 1);
        final updatedAt = DateTime(2024, 12, 31);

        final details = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          usageCount: 5,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        // Assert
        expect(details.updatedAt.isAfter(details.createdAt), true);
      });
    });
  });
}
