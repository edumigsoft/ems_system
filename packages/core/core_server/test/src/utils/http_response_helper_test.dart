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

        final body =
            json.decode(await response.readAsString()) as Map<String, dynamic>;
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
        final body =
            json.decode(await response.readAsString()) as Map<String, dynamic>;
        final transformed = body['transformed'] as Map<String, dynamic>;
        expect(transformed['name'], 'Test');
      });

      test(
        'should return 400 with ErrorResponse for ValidationException',
        () async {
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
          expect(
            response.headers['content-type'],
            contains('application/json'),
          );

          final body =
              json.decode(await response.readAsString())
                  as Map<String, dynamic>;
          expect(body['error'], 'Dados inválidos');
          expect(body['message'], 'Verifique os campos e tente novamente');
          expect(body['statusCode'], 400);
          expect(body['details'], isNotNull);
          final details = body['details'] as Map<String, dynamic>;
          expect(details['email'], ['Email é obrigatório']);
        },
      );

      test(
        'should return 401 with ErrorResponse for UnauthorizedException',
        () async {
          // Arrange
          final result = Failure<String>(
            UnauthorizedException('Invalid token'),
          );

          // Act
          final response = HttpResponseHelper.toResponse(result);

          // Assert
          expect(response.statusCode, 401);

          final body =
              json.decode(await response.readAsString())
                  as Map<String, dynamic>;
          expect(body['error'], 'Não autorizado');
          expect(body['message'], 'Faça login novamente');
          expect(body['statusCode'], 401);
        },
      );

      test(
        'should return 500 with ErrorResponse for StorageException',
        () async {
          // Arrange
          final result = Failure<String>(
            StorageException('Database error'),
          );

          // Act
          final response = HttpResponseHelper.toResponse(result);

          // Assert
          expect(response.statusCode, 500);

          final body =
              json.decode(await response.readAsString())
                  as Map<String, dynamic>;
          expect(body['error'], 'Erro no servidor');
          expect(
            body['message'],
            'Erro ao acessar dados. Tente novamente mais tarde.',
          );
          expect(body['statusCode'], 500);
        },
      );

      test('should return custom statusCode from DataException', () async {
        // Arrange
        final result = Failure<String>(
          DataException('User not found', statusCode: 404),
        );

        // Act
        final response = HttpResponseHelper.toResponse(result);

        // Assert
        expect(response.statusCode, 404);

        final body =
            json.decode(await response.readAsString()) as Map<String, dynamic>;
        expect(body['error'], 'Erro ao processar requisição');
        expect(body['message'], 'User not found');
        expect(body['statusCode'], 404);
      });
    });

    group('successList', () {
      test('should return 200 with list data', () async {
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

        final body =
            json.decode(await response.readAsString()) as Map<String, dynamic>;
        final data = body['data'] as List;
        expect(data, hasLength(2));
        final firstItem = data[0] as Map<String, dynamic>;
        expect(firstItem['id'], '1');
      });

      test('should accept custom status code for empty list', () async {
        // Arrange
        final items = <Map<String, String>>[];

        // Act
        final response = HttpResponseHelper.successList(items, code: 201);

        // Assert
        expect(response.statusCode, 201);
      });
    });

    group('error', () {
      test('should map ValidationException to 400', () async {
        // Arrange
        final error = ValidationException({
          'field': ['Error message'],
        });

        // Act
        final response = HttpResponseHelper.error(error);

        // Assert
        expect(response.statusCode, 400);

        final body =
            json.decode(await response.readAsString()) as Map<String, dynamic>;
        expect(body['error'], 'Dados inválidos');
        expect(body['message'], 'Verifique os campos e tente novamente');
        expect(body['details'], isNotNull);
      });

      test('should map UnauthorizedException to 401', () async {
        // Arrange
        final error = UnauthorizedException('Token expired');

        // Act
        final response = HttpResponseHelper.error(error);

        // Assert
        expect(response.statusCode, 401);

        final body =
            json.decode(await response.readAsString()) as Map<String, dynamic>;
        expect(body['error'], 'Não autorizado');
        expect(body['message'], 'Faça login novamente');
      });

      test('should handle string error', () async {
        // Arrange
        const error = 'Simple error string';

        // Act
        final response = HttpResponseHelper.error(error);

        // Assert
        expect(response.statusCode, 400);

        final body =
            json.decode(await response.readAsString()) as Map<String, dynamic>;
        expect(body['error'], 'Simple error string');
      });

      test('should use custom message when provided', () async {
        // Arrange
        const error = 'Error object';

        // Act
        final response = HttpResponseHelper.error(
          error,
          message: 'Custom message',
        );

        // Assert
        final body =
            json.decode(await response.readAsString()) as Map<String, dynamic>;
        expect(body['error'], 'Custom message');
        expect(body['details'], 'Error object');
      });
    });
  });
}
