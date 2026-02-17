import 'package:test/test.dart';
import 'package:core_server/core_server.dart';

void main() {
  group('ErrorMessageMapper', () {
    group('fromException', () {
      test('should map ValidationException to 400 with field details', () {
        // Arrange
        final exception = ValidationException({
          'name': ['Nome é obrigatório'],
          'email': ['Email inválido', 'Email já está em uso'],
          'password': ['Senha deve ter no mínimo 8 caracteres'],
        });

        // Act
        final response = ErrorMessageMapper.fromException(exception);

        // Assert
        expect(response.error, 'Dados inválidos');
        expect(response.message, 'Verifique os campos e tente novamente');
        expect(response.statusCode, 400);
        expect(response.details, isNotNull);
        expect(response.details!['name'], ['Nome é obrigatório']);
        expect(response.details!['email'], hasLength(2));
        expect(
          response.details!['password'],
          ['Senha deve ter no mínimo 8 caracteres'],
        );
      });

      test('should map UnauthorizedException to 401', () {
        // Arrange
        final exception = UnauthorizedException('Invalid credentials');

        // Act
        final response = ErrorMessageMapper.fromException(exception);

        // Assert
        expect(response.error, 'Não autorizado');
        expect(response.message, 'Faça login novamente');
        expect(response.statusCode, 401);
        expect(response.details, isNull);
      });

      test('should map DataException with statusCode 400', () {
        // Arrange
        final exception = DataException(
          'Usuário não encontrado',
          statusCode: 404,
        );

        // Act
        final response = ErrorMessageMapper.fromException(exception);

        // Assert
        expect(response.error, 'Erro ao processar requisição');
        expect(response.message, 'Usuário não encontrado');
        expect(response.statusCode, 404);
        expect(response.details, isNull);
      });

      test('should map DataException with statusCode 500', () {
        // Arrange
        final exception = DataException(
          'Erro ao processar dados',
          statusCode: 500,
        );

        // Act
        final response = ErrorMessageMapper.fromException(exception);

        // Assert
        expect(response.error, 'Erro no servidor');
        expect(response.message, 'Erro ao processar dados');
        expect(response.statusCode, 500);
        expect(response.details, isNull);
      });

      test('should map DataException without statusCode to 500', () {
        // Arrange
        final exception = DataException('Erro genérico');

        // Act
        final response = ErrorMessageMapper.fromException(exception);

        // Assert
        expect(response.error, 'Erro no servidor');
        expect(response.message, 'Erro genérico');
        expect(response.statusCode, 500);
      });

      test('should map StorageException to 500', () {
        // Arrange
        final exception = StorageException('Database connection failed');

        // Act
        final response = ErrorMessageMapper.fromException(exception);

        // Assert
        expect(response.error, 'Erro no servidor');
        expect(
          response.message,
          'Erro ao acessar dados. Tente novamente mais tarde.',
        );
        expect(response.statusCode, 500);
        expect(response.details, isNull);
      });

      test('should map generic Exception to 500', () {
        // Arrange
        final exception = Exception('Unknown error');

        // Act
        final response = ErrorMessageMapper.fromException(exception);

        // Assert
        expect(response.error, 'Erro interno');
        expect(
          response.message,
          'Ocorreu um erro inesperado. Tente novamente mais tarde.',
        );
        expect(response.statusCode, 500);
        expect(response.details, isNull);
      });
    });
  });

  group('ErrorResponse', () {
    test('should convert to JSON with all fields', () {
      // Arrange
      final response = ErrorResponse(
        error: 'Test Error',
        message: 'Test message',
        statusCode: 400,
        details: {
          'field1': ['error1', 'error2'],
          'field2': ['error3'],
        },
      );

      // Act
      final json = response.toJson();

      // Assert
      expect(json['error'], 'Test Error');
      expect(json['message'], 'Test message');
      expect(json['statusCode'], 400);
      expect(json['details'], isNotNull);
      final details = json['details'] as Map<String, dynamic>;
      expect(details['field1'], ['error1', 'error2']);
      expect(details['field2'], ['error3']);
    });

    test('should convert to JSON without details when null', () {
      // Arrange
      final response = ErrorResponse(
        error: 'Test Error',
        message: 'Test message',
        statusCode: 500,
      );

      // Act
      final json = response.toJson();

      // Assert
      expect(json['error'], 'Test Error');
      expect(json['message'], 'Test message');
      expect(json['statusCode'], 500);
      expect(json.containsKey('details'), isFalse);
    });

    test('should convert to JSON without details when empty map', () {
      // Arrange
      final response = ErrorResponse(
        error: 'Test Error',
        message: 'Test message',
        statusCode: 500,
        details: {},
      );

      // Act
      final json = response.toJson();

      // Assert
      expect(json.containsKey('details'), isFalse);
    });

    test('should have meaningful toString', () {
      // Arrange
      final response = ErrorResponse(
        error: 'Test Error',
        message: 'Test message',
        statusCode: 404,
      );

      // Act
      final string = response.toString();

      // Assert
      expect(string, contains('Test Error'));
      expect(string, contains('Test message'));
      expect(string, contains('404'));
    });
  });
}
