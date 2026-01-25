import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

void main() {
  group('TagCreateValidator', () {
    late TagCreateValidator validator;

    setUp(() {
      validator = const TagCreateValidator();
    });

    group('valid inputs', () {
      test('should pass validation with all fields valid', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: 'Work related tasks',
          color: '#FF5733',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with minimal valid name', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'A',
          description: null,
          color: null,
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with maximum length name', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'A' * 50,
          description: null,
          color: null,
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with null description', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: '#FF5733',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with null color', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: null,
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with empty color', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should pass validation with max length description', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: 'A' * 200,
          color: null,
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });
    });

    group('valid color formats', () {
      test('should accept 3-digit hex color (#RGB)', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: '#F00',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should accept 6-digit hex color (#RRGGBB)', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: '#FF5733',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should accept 8-digit hex color with alpha (#RRGGBBAA)', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: '#FF5733AA',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should accept lowercase hex color', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: '#ff5733',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should accept mixed case hex color', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: '#Ff5733',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });
    });

    group('name validation errors', () {
      test('should fail when name is empty', () {
        // Arrange
        final tagCreate = TagCreate(
          name: '',
          description: null,
          color: null,
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors, hasLength(1));
        expect(result.errors.first.field, 'name');
        expect(result.errors.first.message, 'Nome é obrigatório');
      });

      test('should fail when name exceeds max length', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'A' * 51,
          description: null,
          color: null,
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors, hasLength(1));
        expect(result.errors.first.field, 'name');
        expect(result.errors.first.message, 'Nome deve ter no máximo 50 caracteres');
      });
    });

    group('description validation errors', () {
      test('should fail when description exceeds max length', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: 'A' * 201,
          color: null,
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors, hasLength(1));
        expect(result.errors.first.field, 'description');
        expect(result.errors.first.message, 'Descrição deve ter no máximo 200 caracteres');
      });
    });

    group('color validation errors', () {
      test('should fail when color is missing # prefix', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: 'FF5733',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors, hasLength(1));
        expect(result.errors.first.field, 'color');
        expect(result.errors.first.message, 'Cor deve ser um código hexadecimal válido (ex: #FF5722)');
      });

      test('should fail when color has invalid length (4 digits)', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: '#FF57',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors, hasLength(1));
        expect(result.errors.first.field, 'color');
      });

      test('should fail when color has invalid length (5 digits)', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: '#FF573',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors, hasLength(1));
        expect(result.errors.first.field, 'color');
      });

      test('should fail when color has invalid length (7 digits)', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: '#FF5733A',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors, hasLength(1));
        expect(result.errors.first.field, 'color');
      });

      test('should fail when color contains invalid characters', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: '#GGGGGG',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors, hasLength(1));
        expect(result.errors.first.field, 'color');
      });

      test('should fail when color is just #', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: '#',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors, hasLength(1));
        expect(result.errors.first.field, 'color');
      });
    });

    group('multiple validation errors', () {
      test('should return all validation errors', () {
        // Arrange
        final tagCreate = TagCreate(
          name: '',
          description: 'A' * 201,
          color: 'invalid',
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors, hasLength(3));

        final fields = result.errors.map((e) => e.field).toList();
        expect(fields, containsAll(['name', 'description', 'color']));
      });

      test('should return errors for name and description', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'A' * 51,
          description: 'A' * 201,
          color: null,
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, false);
        expect(result.errors, hasLength(2));

        final fields = result.errors.map((e) => e.field).toList();
        expect(fields, containsAll(['name', 'description']));
      });
    });

    group('edge cases', () {
      test('should accept special characters in name', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work@#\$%&*()',
          description: null,
          color: null,
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
      });

      test('should accept unicode characters in name', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Работа 工作',
          description: null,
          color: null,
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
      });

      test('should accept emojis in description', () {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: '💼 Work related tasks 🚀',
          color: null,
        );

        // Act
        final result = validator.validate(tagCreate);

        // Assert
        expect(result.isValid, true);
      });
    });
  });
}
