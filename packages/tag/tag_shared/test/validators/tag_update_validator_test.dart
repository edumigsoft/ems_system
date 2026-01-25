import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

void main() {
  group('TagUpdateValidator', () {
    late TagUpdateValidator validator;

    setUp(() {
      validator = const TagUpdateValidator();
    });

    group('valid inputs', () {
      test('should pass validation with valid name update', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Updated Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with valid description update', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: 'Updated description',
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with valid color update', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: '#FF5733',
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with isActive update', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: false,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with isDeleted update', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: true,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with multiple field updates', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Updated',
          description: 'Updated description',
          color: '#00FF00',
          isActive: true,
          isDeleted: false,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with minimal name length', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'A',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with maximum name length', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'A' * 50,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with maximum description length', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: 'A' * 200,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });
    });

    group('id validation errors', () {
      test('should fail when id is empty', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: '',
          name: 'Updated',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.field == 'id'), true);
        expect(
          result.errors.firstWhere((e) => e.field == 'id').message,
          'ID é obrigatório',
        );
      });
    });

    group('hasChanges validation errors', () {
      test('should fail when no changes are specified', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.field == 'general'), true);
        expect(
          result.errors.firstWhere((e) => e.field == 'general').message,
          'Nenhuma alteração foi especificada',
        );
      });
    });

    group('name validation errors', () {
      test('should fail when name is empty string', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: '',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.field == 'name'), true);
        expect(
          result.errors.firstWhere((e) => e.field == 'name').message,
          'Nome não pode ser vazio',
        );
      });

      test('should fail when name exceeds max length', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'A' * 51,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.field == 'name'), true);
        expect(
          result.errors.firstWhere((e) => e.field == 'name').message,
          'Nome deve ter no máximo 50 caracteres',
        );
      });
    });

    group('description validation errors', () {
      test('should fail when description exceeds max length', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: 'A' * 201,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.field == 'description'), true);
        expect(
          result.errors.firstWhere((e) => e.field == 'description').message,
          'Descrição deve ter no máximo 200 caracteres',
        );
      });

      test('should pass when description is empty string', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: '',
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
      });
    });

    group('color validation errors', () {
      test('should fail when color is invalid (missing #)', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: 'FF5733',
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.field == 'color'), true);
        expect(
          result.errors.firstWhere((e) => e.field == 'color').message,
          'Cor deve ser um código hexadecimal válido (ex: #FF5722)',
        );
      });

      test('should fail when color has invalid length', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: '#FF57',
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.field == 'color'), true);
      });

      test('should fail when color has invalid characters', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: '#GGGGGG',
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors.any((e) => e.field == 'color'), true);
      });

      test('should pass when color is empty string', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: '',
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
      });
    });

    group('valid color formats', () {
      test('should accept 3-digit hex color (#RGB)', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: '#F00',
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
      });

      test('should accept 6-digit hex color (#RRGGBB)', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: '#FF5733',
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
      });

      test('should accept 8-digit hex color with alpha (#RRGGBBAA)', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: '#FF5733AA',
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
      });
    });

    group('multiple validation errors', () {
      test('should return all validation errors', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: '',
          name: '',
          description: 'A' * 201,
          color: 'invalid',
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors.length, greaterThanOrEqualTo(3));

        final fields = result.errors.map((e) => e.field).toList();
        expect(fields, containsAll(['id', 'name', 'description', 'color']));
      });

      test('should return id and hasChanges errors together', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: '',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors, hasLength(2));

        final fields = result.errors.map((e) => e.field).toList();
        expect(fields, containsAll(['id', 'general']));
      });
    });

    group('partial update scenarios', () {
      test('should validate update with only isActive change', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: false,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should validate soft delete operation', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: true,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should validate restore operation', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: false,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });
    });

    group('edge cases', () {
      test('should accept special characters in name', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Work@#\$%&*()',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
      });

      test('should accept unicode characters in name', () {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Работа 工作',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = validator.validate(tagUpdate);

        // Assert
        expect(result.isValid, true);
      });
    });
  });
}
