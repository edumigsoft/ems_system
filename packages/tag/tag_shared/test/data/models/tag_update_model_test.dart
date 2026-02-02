import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

void main() {
  group('TagUpdateModel', () {
    group('fromJson', () {
      test('should deserialize complete JSON with snake_case', () {
        // Arrange
        final json = {
          'id': 'tag-123',
          'name': 'Updated Work',
          'description': 'Updated description',
          'color': '#00FF00',
          'is_active': true,
          'is_deleted': false,
        };

        // Act
        final model = TagUpdateModel.fromJson(json);

        // Assert
        expect(model.dto.id, 'tag-123');
        expect(model.dto.name, 'Updated Work');
        expect(model.dto.description, 'Updated description');
        expect(model.dto.color, '#00FF00');
        expect(model.dto.isActive, true);
        expect(model.dto.isDeleted, false);
      });

      test('should deserialize with only id and name', () {
        // Arrange
        final json = {
          'id': 'tag-456',
          'name': 'New Name',
          'description': null,
          'color': null,
          'is_active': null,
          'is_deleted': null,
        };

        // Act
        final model = TagUpdateModel.fromJson(json);

        // Assert
        expect(model.dto.id, 'tag-456');
        expect(model.dto.name, 'New Name');
        expect(model.dto.description, isNull);
        expect(model.dto.color, isNull);
        expect(model.dto.isActive, isNull);
        expect(model.dto.isDeleted, isNull);
      });

      test('should deserialize with only id', () {
        // Arrange
        final json = {
          'id': 'tag-789',
          'name': null,
          'description': null,
          'color': null,
          'is_active': null,
          'is_deleted': null,
        };

        // Act
        final model = TagUpdateModel.fromJson(json);

        // Assert
        expect(model.dto.id, 'tag-789');
        expect(model.dto.name, isNull);
        expect(model.dto.description, isNull);
        expect(model.dto.color, isNull);
        expect(model.dto.isActive, isNull);
        expect(model.dto.isDeleted, isNull);
      });

      test('should deserialize with boolean flags only', () {
        // Arrange
        final json = {
          'id': 'tag-123',
          'name': null,
          'description': null,
          'color': null,
          'is_active': false,
          'is_deleted': true,
        };

        // Act
        final model = TagUpdateModel.fromJson(json);

        // Assert
        expect(model.dto.id, 'tag-123');
        expect(model.dto.isActive, false);
        expect(model.dto.isDeleted, true);
      });
    });

    group('toJson', () {
      test('should serialize with all fields', () {
        // Arrange
        final dto = TagUpdate(
          id: 'tag-123',
          name: 'Updated',
          description: 'Updated desc',
          color: '#FF5733',
          isActive: true,
          isDeleted: false,
        );
        final model = TagUpdateModel(dto);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'tag-123');
        expect(json['name'], 'Updated');
        expect(json['description'], 'Updated desc');
        expect(json['color'], '#FF5733');
        expect(json['is_active'], true);
        expect(json['is_deleted'], false);
        expect(json.length, 6);
      });

      test('should only include id when no other fields are set', () {
        // Arrange
        final dto = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );
        final model = TagUpdateModel(dto);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'tag-123');
        expect(json.length, 1);
        expect(json.containsKey('name'), false);
        expect(json.containsKey('description'), false);
        expect(json.containsKey('color'), false);
        expect(json.containsKey('is_active'), false);
        expect(json.containsKey('is_deleted'), false);
      });

      test('should include only non-null fields for partial update', () {
        // Arrange
        final dto = TagUpdate(
          id: 'tag-456',
          name: 'New Name',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );
        final model = TagUpdateModel(dto);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'tag-456');
        expect(json['name'], 'New Name');
        expect(json.length, 2);
        expect(json.containsKey('description'), false);
        expect(json.containsKey('color'), false);
      });

      test('should use snake_case for boolean fields', () {
        // Arrange
        final dto = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: false,
          isDeleted: true,
        );
        final model = TagUpdateModel(dto);

        // Act
        final json = model.toJson();

        // Assert
        expect(json.containsKey('is_active'), true);
        expect(json.containsKey('is_deleted'), true);
        expect(json['is_active'], false);
        expect(json['is_deleted'], true);
      });

      test('should include false values for boolean fields', () {
        // Arrange
        final dto = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: false,
          isDeleted: false,
        );
        final model = TagUpdateModel(dto);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['is_active'], false);
        expect(json['is_deleted'], false);
        expect(json.length, 3); // id + is_active + is_deleted
      });

      test('should not include null string fields', () {
        // Arrange
        final dto = TagUpdate(
          id: 'tag-789',
          name: null,
          description: null,
          color: '#FF5733',
          isActive: null,
          isDeleted: null,
        );
        final model = TagUpdateModel(dto);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'tag-789');
        expect(json['color'], '#FF5733');
        expect(json.length, 2);
        expect(json.containsKey('name'), false);
        expect(json.containsKey('description'), false);
      });
    });

    group('toDomain', () {
      test('should return wrapped DTO', () {
        // Arrange
        final dto = TagUpdate(
          id: 'tag-123',
          name: 'Updated',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );
        final model = TagUpdateModel(dto);

        // Act
        final result = model.toDomain();

        // Assert
        expect(result, dto);
        expect(result.id, 'tag-123');
        expect(result.name, 'Updated');
      });
    });

    group('fromDomain', () {
      test('should create model from DTO', () {
        // Arrange
        final dto = TagUpdate(
          id: 'tag-456',
          name: 'Personal',
          description: 'Personal tasks',
          color: null,
          isActive: true,
          isDeleted: null,
        );

        // Act
        final model = TagUpdateModel.fromDomain(dto);

        // Assert
        expect(model.dto, dto);
        expect(model.dto.id, 'tag-456');
        expect(model.dto.name, 'Personal');
      });
    });

    group('round-trip serialization', () {
      test('should maintain all data through toJson -> fromJson', () {
        // Arrange
        final original = TagUpdate(
          id: 'tag-123',
          name: 'Updated Work',
          description: 'Updated description',
          color: '#00FF00',
          isActive: true,
          isDeleted: false,
        );
        final model = TagUpdateModel(original);

        // Act
        final json = model.toJson();
        final deserialized = TagUpdateModel.fromJson(json);

        // Assert
        expect(deserialized.dto, original);
        expect(deserialized.dto.id, original.id);
        expect(deserialized.dto.name, original.name);
        expect(deserialized.dto.description, original.description);
        expect(deserialized.dto.color, original.color);
        expect(deserialized.dto.isActive, original.isActive);
        expect(deserialized.dto.isDeleted, original.isDeleted);
      });

      test('should maintain partial data (only id)', () {
        // Arrange
        final original = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );
        final model = TagUpdateModel(original);

        // Act
        final json = model.toJson();

        // Note: fromJson requires explicit null keys, so we need to add them
        json['name'] = null;
        json['description'] = null;
        json['color'] = null;
        json['is_active'] = null;
        json['is_deleted'] = null;

        final deserialized = TagUpdateModel.fromJson(json);

        // Assert
        expect(deserialized.dto.id, original.id);
        expect(deserialized.dto.name, isNull);
        expect(deserialized.dto.description, isNull);
        expect(deserialized.dto.color, isNull);
        expect(deserialized.dto.isActive, isNull);
        expect(deserialized.dto.isDeleted, isNull);
      });

      test('should maintain partial data (name only)', () {
        // Arrange
        final original = TagUpdate(
          id: 'tag-456',
          name: 'New Name',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );
        final model = TagUpdateModel(original);

        // Act
        final json = model.toJson();
        json['description'] = null;
        json['color'] = null;
        json['is_active'] = null;
        json['is_deleted'] = null;

        final deserialized = TagUpdateModel.fromJson(json);

        // Assert
        expect(deserialized.dto.id, original.id);
        expect(deserialized.dto.name, original.name);
        expect(deserialized.dto.description, isNull);
      });
    });

    group('equality', () {
      test('should be equal when DTOs are equal', () {
        // Arrange
        final dto = TagUpdate(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );
        final model1 = TagUpdateModel(dto);
        final model2 = TagUpdateModel(dto);

        // Assert
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when DTOs differ', () {
        // Arrange
        final dto1 = TagUpdate(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );
        final dto2 = TagUpdate(
          id: 'tag-456',
          name: 'Personal',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );
        final model1 = TagUpdateModel(dto1);
        final model2 = TagUpdateModel(dto2);

        // Assert
        expect(model1, isNot(equals(model2)));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        // Arrange
        final dto = TagUpdate(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );
        final model = TagUpdateModel(dto);

        // Act
        final string = model.toString();

        // Assert
        expect(string, contains('TagUpdateModel'));
      });
    });

    group('edge cases', () {
      test('should handle empty strings', () {
        // Arrange
        final json = {
          'id': '',
          'name': '',
          'description': '',
          'color': '',
          'is_active': null,
          'is_deleted': null,
        };

        // Act
        final model = TagUpdateModel.fromJson(json);

        // Assert
        expect(model.dto.id, '');
        expect(model.dto.name, '');
        expect(model.dto.description, '');
        expect(model.dto.color, '');
      });

      test('should handle special characters', () {
        // Arrange
        final json = {
          'id': 'tag-@#\$',
          'name': 'Work@#\$%',
          'description': 'Special éàü',
          'color': null,
          'is_active': null,
          'is_deleted': null,
        };

        // Act
        final model = TagUpdateModel.fromJson(json);

        // Assert
        expect(model.dto.id, 'tag-@#\$');
        expect(model.dto.name, 'Work@#\$%');
        expect(model.dto.description, 'Special éàü');
      });
    });
  });
}
