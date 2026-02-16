import 'dart:convert';

import 'package:test/test.dart';
import 'package:core_server/core_server.dart';

void main() {
  group('HttpResponseHelper', () {
    group('toResponse', () {
      test('should return 200 OK for Success with simple data', () async {
        // Arrange
        final result = Success('test data');

        // Act
        final response = HttpResponseHelper.toResponse(result);

        // Assert
        expect(response.statusCode, 200);
        expect(response.headers['content-type'], contains('application/json'));

        final body = json.decode(await response.readAsString());
        expect(body['data'], 'test data');
      });

      test('should return custom success code when specified', () async {
        // Arrange
        final result = Success({'id': '123'});

        // Act
        final response = HttpResponseHelper.toResponse(
          result,
          successCode: 201,
        );

        // Assert
        expect(response.statusCode, 201);
      });

      test('should apply onSuccess transformation', () async {
        // Arrange
        final result = Success({'name': 'Test'});

        // Act
        final response = HttpResponseHelper.toResponse(
          result,
          onSuccess: (data) => {'transformed': data},
        );

        // Assert
        final body = json.decode(await response.readAsString());
        expect(body['transformed']['name'], 'Test');
      });

      test('should return 400 with ErrorResponse for ValidationException', () async {
        // Arrange
        final result = Failure<String>(
          ValidationException({
            'email': ['Email é obrigatório'],
            'password': ['Senha muito curta'],
          }),
        );

        // Act
        final response = HttpResponseHelper.toResponse(result);

        // Assert
        expect(response.statusCode, 400);
        expect(response.headers['content-type'], contains('application/json'));

        final body = json.decode(await response.readAsString());
        expect(body['error'], 'Dados inválidos');
        expect(body['message'], 'Verifique os campos e tente novamente');
        expect(body['statusCode'], 400);
        expect(body['details'], isNotNull);
        expect(body['details']['email'], ['Email é obrigatório']);
      });

      test('should \1', () async {
        // Arrange
        final result = Failure<String>(
          UnauthorizedException('Invalid token'),
        );

        // Act
        final response = HttpResponseHelper.toResponse(result);

        // Assert
        expect(response.statusCode, 401);

        final body = json.decode(await response.readAsString());
        expect(body['error'], 'Não autorizado');
        expect(body['message'], 'Faça login novamente');
        expect(body['statusCode'], 401);
      });

      test('should \1', () async {
        // Arrange
        final result = Failure<String>(
          StorageException('Database error'),
        );

        // Act
        final response = HttpResponseHelper.toResponse(result);

        // Assert
        expect(response.statusCode, 500);

        final body = json.decode(await response.readAsString());
        expect(body['error'], 'Erro no servidor');
        expect(
          body['message'],
          'Erro ao acessar dados. Tente novamente mais tarde.',
        );
        expect(body['statusCode'], 500);
      });

      test('should \1', () async {
        // Arrange
        final result = Failure<String>(
          DataException('User not found', statusCode: 404),
        );

        // Act
        final response = HttpResponseHelper.toResponse(result);

        // Assert
        expect(response.statusCode, 404);

        final body = json.decode(await response.readAsString());
        expect(body['error'], 'Erro ao processar requisição');
        expect(body['message'], 'User not found');
        expect(body['statusCode'], 404);
      });
    });

    group('successList', () {
      test('should \1', () async {
        // Arrange
        final items = [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ];

        // Act
        final response = HttpResponseHelper.successList(items);

        // Assert
        expect(response.statusCode, 200);
        expect(response.headers['content-type'], contains('application/json'));

        final body = json.decode(await response.readAsString());
        expect(body['data'], hasLength(2));
        expect(body['data'][0]['id'], '1');
      });

      test('should \1', () async {
        // Arrange
        final items = <Map<String, String>>[];

        // Act
        final response = HttpResponseHelper.successList(items, code: 201);

        // Assert
        expect(response.statusCode, 201);
      });
    });

    group('error', () {
      test('should \1', () async {
        // Arrange
        final error = ValidationException({
          'field': ['Error message'],
        });

        // Act
        final response = HttpResponseHelper.error(error);

        // Assert
        expect(response.statusCode, 400);

        final body = json.decode(await response.readAsString());
        expect(body['error'], 'Dados inválidos');
        expect(body['message'], 'Verifique os campos e tente novamente');
        expect(body['details'], isNotNull);
      });

      test('should \1', () async {
        // Arrange
        final error = UnauthorizedException('Token expired');

        // Act
        final response = HttpResponseHelper.error(error);

        // Assert
        expect(response.statusCode, 401);

        final body = json.decode(await response.readAsString());
        expect(body['error'], 'Não autorizado');
        expect(body['message'], 'Faça login novamente');
      });

      test('should \1', () async {
        // Arrange
        final error = 'Simple error string';

        // Act
        final response = HttpResponseHelper.error(error);

        // Assert
        expect(response.statusCode, 400);

        final body = json.decode(await response.readAsString());
        expect(body['error'], 'Simple error string');
      });

      test('should \1', () async {
        // Arrange
        final error = 'Error object';

        // Act
        final response = HttpResponseHelper.error(
          error,
          message: 'Custom message',
        );

        // Assert
        final body = json.decode(await response.readAsString());
        expect(body['error'], 'Custom message');
        expect(body['details'], 'Error object');
      });
    });
  });
}
