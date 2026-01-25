import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

void main() {
  group('TagCreateModel', () {
    group('fromJson', () {
      test('should deserialize complete JSON', () {
        // Arrange
        final json = {
          'name': 'Work',
          'description': 'Work related tasks',
          'color': '#FF5733',
        };

        // Act
        final model = TagCreateModel.fromJson(json);

        // Assert
        expect(model.dto.name, 'Work');
        expect(model.dto.description, 'Work related tasks');
        expect(model.dto.color, '#FF5733');
      });

      test('should deserialize with null description', () {
        // Arrange
        final json = {
          'name': 'Personal',
          'description': null,
          'color': '#00FF00',
        };

        // Act
        final model = TagCreateModel.fromJson(json);

        // Assert
        expect(model.dto.name, 'Personal');
        expect(model.dto.description, isNull);
        expect(model.dto.color, '#00FF00');
      });

      test('should deserialize with null color', () {
        // Arrange
        final json = {
          'name': 'Important',
          'description': 'Important tasks',
          'color': null,
        };

        // Act
        final model = TagCreateModel.fromJson(json);

        // Assert
        expect(model.dto.name, 'Important');
        expect(model.dto.description, 'Important tasks');
        expect(model.dto.color, isNull);
      });

      test('should deserialize with both optional fields null', () {
        // Arrange
        final json = {
          'name': 'Minimal',
          'description': null,
          'color': null,
        };

        // Act
        final model = TagCreateModel.fromJson(json);

        // Assert
        expect(model.dto.name, 'Minimal');
        expect(model.dto.description, isNull);
        expect(model.dto.color, isNull);
      });
    });

    group('toJson', () {
      test('should serialize complete DTO', () {
        // Arrange
        final dto = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );
        final model = TagCreateModel(dto);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['name'], 'Work');
        expect(json['description'], 'Work tasks');
        expect(json['color'], '#FF5733');
        expect(json.length, 3);
      });

      test('should serialize with null description', () {
        // Arrange
        final dto = TagCreate(
          name: 'Personal',
          description: null,
          color: '#00FF00',
        );
        final model = TagCreateModel(dto);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['name'], 'Personal');
        expect(json['description'], isNull);
        expect(json['color'], '#00FF00');
      });

      test('should serialize with null color', () {
        // Arrange
        final dto = TagCreate(
          name: 'Important',
          description: 'Important tasks',
          color: null,
        );
        final model = TagCreateModel(dto);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['name'], 'Important');
        expect(json['description'], 'Important tasks');
        expect(json['color'], isNull);
      });

      test('should serialize with both optional fields null', () {
        // Arrange
        final dto = TagCreate(
          name: 'Minimal',
          description: null,
          color: null,
        );
        final model = TagCreateModel(dto);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['name'], 'Minimal');
        expect(json['description'], isNull);
        expect(json['color'], isNull);
      });

      test('should include null values in JSON', () {
        // Arrange
        final dto = TagCreate(
          name: 'Test',
          description: null,
          color: null,
        );
        final model = TagCreateModel(dto);

        // Act
        final json = model.toJson();

        // Assert
        expect(json.containsKey('description'), true);
        expect(json.containsKey('color'), true);
      });
    });

    group('toDomain', () {
      test('should return wrapped DTO', () {
        // Arrange
        final dto = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );
        final model = TagCreateModel(dto);

        // Act
        final result = model.toDomain();

        // Assert
        expect(result, dto);
        expect(result.name, 'Work');
        expect(result.description, 'Work tasks');
        expect(result.color, '#FF5733');
      });
    });

    group('fromDomain', () {
      test('should create model from DTO', () {
        // Arrange
        final dto = TagCreate(
          name: 'Personal',
          description: null,
          color: null,
        );

        // Act
        final model = TagCreateModel.fromDomain(dto);

        // Assert
        expect(model.dto, dto);
        expect(model.dto.name, 'Personal');
      });
    });

    group('round-trip serialization', () {
      test('should maintain data through toJson -> fromJson', () {
        // Arrange
        final original = TagCreate(
          name: 'Work',
          description: 'Work related tasks',
          color: '#FF5733',
        );
        final model = TagCreateModel(original);

        // Act
        final json = model.toJson();
        final deserialized = TagCreateModel.fromJson(json);

        // Assert
        expect(deserialized.dto, original);
        expect(deserialized.dto.name, original.name);
        expect(deserialized.dto.description, original.description);
        expect(deserialized.dto.color, original.color);
      });

      test('should maintain data with null fields', () {
        // Arrange
        final original = TagCreate(
          name: 'Minimal',
          description: null,
          color: null,
        );
        final model = TagCreateModel(original);

        // Act
        final json = model.toJson();
        final deserialized = TagCreateModel.fromJson(json);

        // Assert
        expect(deserialized.dto, original);
        expect(deserialized.dto.name, original.name);
        expect(deserialized.dto.description, isNull);
        expect(deserialized.dto.color, isNull);
      });
    });

    group('equality', () {
      test('should be equal when DTOs are equal', () {
        // Arrange
        final dto = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );
        final model1 = TagCreateModel(dto);
        final model2 = TagCreateModel(dto);

        // Assert
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when DTOs differ', () {
        // Arrange
        final dto1 = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );
        final dto2 = TagCreate(
          name: 'Personal',
          description: 'Personal tasks',
          color: '#00FF00',
        );
        final model1 = TagCreateModel(dto1);
        final model2 = TagCreateModel(dto2);

        // Assert
        expect(model1, isNot(equals(model2)));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        // Arrange
        final dto = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );
        final model = TagCreateModel(dto);

        // Act
        final string = model.toString();

        // Assert
        expect(string, contains('TagCreateModel'));
        expect(string, contains('Work'));
      });
    });

    group('edge cases', () {
      test('should handle empty string fields', () {
        // Arrange
        final json = {
          'name': '',
          'description': '',
          'color': '',
        };

        // Act
        final model = TagCreateModel.fromJson(json);

        // Assert
        expect(model.dto.name, '');
        expect(model.dto.description, '');
        expect(model.dto.color, '');
      });

      test('should handle special characters', () {
        // Arrange
        final json = {
          'name': 'Work@#\$%',
          'description': 'Special chars: éàü',
          'color': '#FF5733',
        };

        // Act
        final model = TagCreateModel.fromJson(json);

        // Assert
        expect(model.dto.name, 'Work@#\$%');
        expect(model.dto.description, 'Special chars: éàü');
      });

      test('should handle unicode characters', () {
        // Arrange
        final json = {
          'name': 'Работа 工作',
          'description': 'Description with 日本語',
          'color': null,
        };

        // Act
        final model = TagCreateModel.fromJson(json);

        // Assert
        expect(model.dto.name, 'Работа 工作');
        expect(model.dto.description, 'Description with 日本語');
      });
    });
  });
}
