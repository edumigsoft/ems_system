import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

void main() {
  group('TagDetailsModel', () {
    group('fromJson', () {
      test('should deserialize complete JSON with snake_case', () {
        // Arrange
        final json = {
          'id': 'tag-123',
          'is_deleted': false,
          'is_active': true,
          'created_at': '2024-01-15T10:30:00.000Z',
          'updated_at': '2024-01-20T15:45:00.000Z',
          'name': 'Work',
          'description': 'Work related tasks',
          'color': '#FF5733',
          'usage_count': 5,
        };

        // Act
        final model = TagDetailsModel.fromJson(json);

        // Assert
        expect(model.entity.id, 'tag-123');
        expect(model.entity.isDeleted, false);
        expect(model.entity.isActive, true);
        expect(model.entity.createdAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
        expect(model.entity.updatedAt, DateTime.parse('2024-01-20T15:45:00.000Z'));
        expect(model.entity.name, 'Work');
        expect(model.entity.description, 'Work related tasks');
        expect(model.entity.color, '#FF5733');
        expect(model.entity.usageCount, 5);
      });

      test('should deserialize with default values for optional fields', () {
        // Arrange
        final json = {
          'id': 'tag-456',
          'created_at': '2024-01-15T10:30:00.000Z',
          'updated_at': '2024-01-15T10:30:00.000Z',
          'name': 'Personal',
          'description': null,
          'color': null,
        };

        // Act
        final model = TagDetailsModel.fromJson(json);

        // Assert
        expect(model.entity.id, 'tag-456');
        expect(model.entity.isDeleted, false); // default value
        expect(model.entity.isActive, true); // default value
        expect(model.entity.name, 'Personal');
        expect(model.entity.description, isNull);
        expect(model.entity.color, isNull);
        expect(model.entity.usageCount, 0); // default value
      });

      test('should deserialize with null description and color', () {
        // Arrange
        final json = {
          'id': 'tag-789',
          'is_deleted': false,
          'is_active': true,
          'created_at': '2024-01-15T10:30:00.000Z',
          'updated_at': '2024-01-15T10:30:00.000Z',
          'name': 'Minimal',
          'description': null,
          'color': null,
          'usage_count': 0,
        };

        // Act
        final model = TagDetailsModel.fromJson(json);

        // Assert
        expect(model.entity.description, isNull);
        expect(model.entity.color, isNull);
      });

      test('should parse ISO 8601 datetime strings', () {
        // Arrange
        final json = {
          'id': 'tag-123',
          'is_deleted': false,
          'is_active': true,
          'created_at': '2024-06-15T08:30:45.123Z',
          'updated_at': '2024-12-20T16:25:30.456Z',
          'name': 'Test',
          'description': null,
          'color': null,
          'usage_count': 0,
        };

        // Act
        final model = TagDetailsModel.fromJson(json);

        // Assert
        expect(model.entity.createdAt.year, 2024);
        expect(model.entity.createdAt.month, 6);
        expect(model.entity.createdAt.day, 15);
        expect(model.entity.updatedAt.year, 2024);
        expect(model.entity.updatedAt.month, 12);
        expect(model.entity.updatedAt.day, 20);
      });

      test('should handle deleted and inactive tags', () {
        // Arrange
        final json = {
          'id': 'tag-deleted',
          'is_deleted': true,
          'is_active': false,
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-02T00:00:00.000Z',
          'name': 'Archived',
          'description': null,
          'color': null,
          'usage_count': 10,
        };

        // Act
        final model = TagDetailsModel.fromJson(json);

        // Assert
        expect(model.entity.isDeleted, true);
        expect(model.entity.isActive, false);
        expect(model.entity.usageCount, 10);
      });
    });

    group('toJson', () {
      test('should serialize complete entity with snake_case', () {
        // Arrange
        final entity = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
          isDeleted: false,
          isActive: true,
          usageCount: 5,
          createdAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
          updatedAt: DateTime.parse('2024-01-20T15:45:00.000Z'),
        );
        final model = TagDetailsModel(entity);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'tag-123');
        expect(json['is_deleted'], false);
        expect(json['is_active'], true);
        expect(json['created_at'], '2024-01-15T10:30:00.000Z');
        expect(json['updated_at'], '2024-01-20T15:45:00.000Z');
        expect(json['name'], 'Work');
        expect(json['description'], 'Work tasks');
        expect(json['color'], '#FF5733');
        expect(json['usage_count'], 5);
      });

      test('should serialize with null description and color', () {
        // Arrange
        final entity = TagDetails(
          id: 'tag-456',
          name: 'Personal',
          description: null,
          color: null,
          isDeleted: false,
          isActive: true,
          usageCount: 0,
          createdAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
          updatedAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
        );
        final model = TagDetailsModel(entity);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['description'], isNull);
        expect(json['color'], isNull);
        expect(json['usage_count'], 0);
      });

      test('should serialize datetime to ISO 8601 string', () {
        // Arrange
        final createdAt = DateTime.utc(2024, 6, 15, 8, 30, 45, 123);
        final updatedAt = DateTime.utc(2024, 12, 20, 16, 25, 30, 456);

        final entity = TagDetails(
          id: 'tag-789',
          name: 'Test',
          description: null,
          color: null,
          isDeleted: false,
          isActive: true,
          usageCount: 0,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final model = TagDetailsModel(entity);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['created_at'], createdAt.toIso8601String());
        expect(json['updated_at'], updatedAt.toIso8601String());
      });

      test('should serialize deleted and inactive tag', () {
        // Arrange
        final entity = TagDetails(
          id: 'tag-deleted',
          name: 'Archived',
          description: null,
          color: null,
          isDeleted: true,
          isActive: false,
          usageCount: 10,
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
        );
        final model = TagDetailsModel(entity);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['is_deleted'], true);
        expect(json['is_active'], false);
        expect(json['usage_count'], 10);
      });

      test('should include all required fields', () {
        // Arrange
        final entity = TagDetails(
          id: 'tag-123',
          name: 'Test',
          description: null,
          color: null,
          isDeleted: false,
          isActive: true,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final model = TagDetailsModel(entity);

        // Act
        final json = model.toJson();

        // Assert
        expect(json.containsKey('id'), true);
        expect(json.containsKey('is_deleted'), true);
        expect(json.containsKey('is_active'), true);
        expect(json.containsKey('created_at'), true);
        expect(json.containsKey('updated_at'), true);
        expect(json.containsKey('name'), true);
        expect(json.containsKey('description'), true);
        expect(json.containsKey('color'), true);
        expect(json.containsKey('usage_count'), true);
      });
    });

    group('toDomain', () {
      test('should return wrapped entity', () {
        // Arrange
        final entity = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
          isDeleted: false,
          isActive: true,
          usageCount: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final model = TagDetailsModel(entity);

        // Act
        final result = model.toDomain();

        // Assert
        expect(result, entity);
        expect(result.id, 'tag-123');
        expect(result.name, 'Work');
      });
    });

    group('fromDomain', () {
      test('should create model from entity', () {
        // Arrange
        final entity = TagDetails(
          id: 'tag-456',
          name: 'Personal',
          description: null,
          color: null,
          isDeleted: false,
          isActive: true,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final model = TagDetailsModel.fromDomain(entity);

        // Assert
        expect(model.entity, entity);
        expect(model.entity.id, 'tag-456');
        expect(model.entity.name, 'Personal');
      });
    });

    group('round-trip serialization', () {
      test('should maintain all data through toJson -> fromJson', () {
        // Arrange
        final original = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
          isDeleted: false,
          isActive: true,
          usageCount: 5,
          createdAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
          updatedAt: DateTime.parse('2024-01-20T15:45:00.000Z'),
        );
        final model = TagDetailsModel(original);

        // Act
        final json = model.toJson();
        final deserialized = TagDetailsModel.fromJson(json);

        // Assert
        expect(deserialized.entity.id, original.id);
        expect(deserialized.entity.name, original.name);
        expect(deserialized.entity.description, original.description);
        expect(deserialized.entity.color, original.color);
        expect(deserialized.entity.isDeleted, original.isDeleted);
        expect(deserialized.entity.isActive, original.isActive);
        expect(deserialized.entity.usageCount, original.usageCount);
        expect(deserialized.entity.createdAt, original.createdAt);
        expect(deserialized.entity.updatedAt, original.updatedAt);
      });

      test('should maintain data with null fields', () {
        // Arrange
        final original = TagDetails(
          id: 'tag-456',
          name: 'Minimal',
          description: null,
          color: null,
          isDeleted: false,
          isActive: true,
          usageCount: 0,
          createdAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
          updatedAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
        );
        final model = TagDetailsModel(original);

        // Act
        final json = model.toJson();
        final deserialized = TagDetailsModel.fromJson(json);

        // Assert
        expect(deserialized.entity.description, isNull);
        expect(deserialized.entity.color, isNull);
      });

      test('should maintain datetime precision', () {
        // Arrange
        final createdAt = DateTime.utc(2024, 6, 15, 8, 30, 45, 123);
        final updatedAt = DateTime.utc(2024, 12, 20, 16, 25, 30, 456);

        final original = TagDetails(
          id: 'tag-789',
          name: 'Test',
          description: null,
          color: null,
          isDeleted: false,
          isActive: true,
          usageCount: 0,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final model = TagDetailsModel(original);

        // Act
        final json = model.toJson();
        final deserialized = TagDetailsModel.fromJson(json);

        // Assert
        expect(deserialized.entity.createdAt, original.createdAt);
        expect(deserialized.entity.updatedAt, original.updatedAt);
      });
    });

    group('equality', () {
      test('should be equal when entities are equal', () {
        // Arrange
        final entity = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          isDeleted: false,
          isActive: true,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final model1 = TagDetailsModel(entity);
        final model2 = TagDetailsModel(entity);

        // Assert
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when entities differ', () {
        // Arrange
        final now = DateTime.now();
        final entity1 = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          isDeleted: false,
          isActive: true,
          usageCount: 0,
          createdAt: now,
          updatedAt: now,
        );
        final entity2 = TagDetails(
          id: 'tag-456',
          name: 'Personal',
          description: null,
          color: null,
          isDeleted: false,
          isActive: true,
          usageCount: 0,
          createdAt: now,
          updatedAt: now,
        );
        final model1 = TagDetailsModel(entity1);
        final model2 = TagDetailsModel(entity2);

        // Assert
        expect(model1, isNot(equals(model2)));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        // Arrange
        final entity = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          isDeleted: false,
          isActive: true,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final model = TagDetailsModel(entity);

        // Act
        final string = model.toString();

        // Assert
        expect(string, contains('TagDetailsModel'));
      });
    });

    group('edge cases', () {
      test('should handle special characters in fields', () {
        // Arrange
        final json = {
          'id': 'tag-@#\$',
          'is_deleted': false,
          'is_active': true,
          'created_at': '2024-01-15T10:30:00.000Z',
          'updated_at': '2024-01-15T10:30:00.000Z',
          'name': 'Work@#\$%',
          'description': 'Special éàü',
          'color': '#FF5733',
          'usage_count': 0,
        };

        // Act
        final model = TagDetailsModel.fromJson(json);

        // Assert
        expect(model.entity.id, 'tag-@#\$');
        expect(model.entity.name, 'Work@#\$%');
        expect(model.entity.description, 'Special éàü');
      });

      test('should handle very large usage count', () {
        // Arrange
        final json = {
          'id': 'tag-123',
          'is_deleted': false,
          'is_active': true,
          'created_at': '2024-01-15T10:30:00.000Z',
          'updated_at': '2024-01-15T10:30:00.000Z',
          'name': 'Popular',
          'description': null,
          'color': null,
          'usage_count': 999999999,
        };

        // Act
        final model = TagDetailsModel.fromJson(json);

        // Assert
        expect(model.entity.usageCount, 999999999);
      });
    });
  });
}
