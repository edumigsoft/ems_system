import 'dart:convert';

import 'package:auth_server/src/routes/auth_routes.dart';
import 'package:auth_server/src/service/auth_service.dart';
import 'package:auth_shared/auth_shared.dart';
import 'package:core_shared/core_shared.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:user_shared/user_shared.dart';

class MockAuthService extends Mock implements AuthService {}

class MockRequest extends Mock implements Request {}

/// Helper para criar AuthResponse de teste
AuthResponse _createAuthResponse(String email) {
  return AuthResponse(
    tokens: const TokenPair(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
    ),
    user: UserDetails.create(
      id: '1',
      email: email,
      name: 'Test User',
      username: 'testuser',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    ),
    expiresIn: 3600,
  );
}

void main() {
  setUpAll(() {
    // Registrar fallback para LoginRequest
    registerFallbackValue(
      const LoginRequest(email: 'test@example.com', password: 'password123'),
    );
  });

  group('AuthRoutes - Basic Auth', () {
    late AuthRoutes authRoutes;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      authRoutes = AuthRoutes(
        mockAuthService,
        backendBaseApi: '/api/v1',
      );
    });

    group('_login - header válido', () {
      test('extrai credenciais de header válido', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const credentials = '$email:$password';
        final encoded = base64Encode(utf8.encode(credentials));

        final request = Request(
          'POST',
          Uri.parse('http://localhost/login'),
          headers: {'Authorization': 'Basic $encoded'},
        );

        final expectedResponse = _createAuthResponse(email);

        when(() => mockAuthService.login(any()))
            .thenAnswer((_) async => Success(expectedResponse));

        // Act
        final response = await authRoutes.router.call(request);

        // Assert
        expect(response.statusCode, equals(200));
        verify(() => mockAuthService.login(any())).called(1);
      });

      test('lida com senhas contendo múltiplos ":"', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'pass:word:123:test';
        const credentials = '$email:$password';
        final encoded = base64Encode(utf8.encode(credentials));

        final request = Request(
          'POST',
          Uri.parse('http://localhost/login'),
          headers: {'Authorization': 'Basic $encoded'},
        );

        final expectedResponse = _createAuthResponse(email);

        when(() => mockAuthService.login(any()))
            .thenAnswer((_) async => Success(expectedResponse));

        // Act
        final response = await authRoutes.router.call(request);

        // Assert
        expect(response.statusCode, equals(200));

        // Verificar que o LoginRequest foi chamado com a senha completa
        final capturedRequest = verify(() => mockAuthService.login(captureAny()))
            .captured
            .single as LoginRequest;
        expect(capturedRequest.email, equals(email));
        expect(capturedRequest.password, equals(password));
      });

      test('lida com caracteres especiais UTF-8', () async {
        // Arrange
        const email = 'tëst@éxãmplé.com';
        const password = 'pássw0rd!@#ñ';
        const credentials = '$email:$password';
        final encoded = base64Encode(utf8.encode(credentials));

        final request = Request(
          'POST',
          Uri.parse('http://localhost/login'),
          headers: {'Authorization': 'Basic $encoded'},
        );

        final expectedResponse = _createAuthResponse(email);

        when(() => mockAuthService.login(any()))
            .thenAnswer((_) async => Success(expectedResponse));

        // Act
        final response = await authRoutes.router.call(request);

        // Assert
        expect(response.statusCode, equals(200));

        final captured = verify(() => mockAuthService.login(captureAny()))
            .captured
            .single as LoginRequest;
        expect(captured.email, equals(email));
        expect(captured.password, equals(password));
      });

      test('case-insensitive para "Basic" (aceita "basic", "Basic", "BASIC")',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const credentials = '$email:$password';
        final encoded = base64Encode(utf8.encode(credentials));

        final testCases = ['basic', 'Basic', 'BASIC', 'BaSiC'];

        for (final prefix in testCases) {
          final request = Request(
            'POST',
            Uri.parse('http://localhost/login'),
            headers: {'Authorization': '$prefix $encoded'},
          );

          final expectedResponse = _createAuthResponse(email);

          when(() => mockAuthService.login(any()))
              .thenAnswer((_) async => Success(expectedResponse));

          // Act
          final response = await authRoutes.router.call(request);

          // Assert
          expect(
            response.statusCode,
            equals(200),
            reason: 'Falhou com prefix: $prefix',
          );
        }
      });
    });

    group('_login - header inválido', () {
      test('rejeita header Authorization ausente (401)', () async {
        // Arrange
        final request = Request(
          'POST',
          Uri.parse('http://localhost/login'),
        );

        // Act
        final response = await authRoutes.router.call(request);

        // Assert
        expect(response.statusCode, equals(401));
        final body = await response.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        expect(json['error'], equals('Credenciais inválidas'));

        // Nunca deve chamar AuthService
        verifyNever(() => mockAuthService.login(any()));
      });

      test('rejeita formato inválido ("Bearer" em vez de "Basic") (401)',
          () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const credentials = '$email:$password';
        final encoded = base64Encode(utf8.encode(credentials));

        final request = Request(
          'POST',
          Uri.parse('http://localhost/login'),
          headers: {'Authorization': 'Bearer $encoded'},
        );

        // Act
        final response = await authRoutes.router.call(request);

        // Assert
        expect(response.statusCode, equals(401));
        final body = await response.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        expect(json['error'], equals('Credenciais inválidas'));

        verifyNever(() => mockAuthService.login(any()));
      });

      test('rejeita base64 inválido (401)', () async {
        // Arrange
        final request = Request(
          'POST',
          Uri.parse('http://localhost/login'),
          headers: {'Authorization': 'Basic invalid!!!base64'},
        );

        // Act
        final response = await authRoutes.router.call(request);

        // Assert
        expect(response.statusCode, equals(401));
        final body = await response.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        expect(json['error'], equals('Credenciais inválidas'));

        verifyNever(() => mockAuthService.login(any()));
      });

      test('rejeita credenciais sem separador ":" (401)', () async {
        // Arrange - codifica string sem ':'
        const credentials = 'testexamplecompassword123';
        final encoded = base64Encode(utf8.encode(credentials));

        final request = Request(
          'POST',
          Uri.parse('http://localhost/login'),
          headers: {'Authorization': 'Basic $encoded'},
        );

        // Act
        final response = await authRoutes.router.call(request);

        // Assert
        expect(response.statusCode, equals(401));
        final body = await response.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        expect(json['error'], equals('Credenciais inválidas'));

        verifyNever(() => mockAuthService.login(any()));
      });

      test('rejeita email vazio (401)', () async {
        // Arrange - email vazio
        const credentials = ':password123';
        final encoded = base64Encode(utf8.encode(credentials));

        final request = Request(
          'POST',
          Uri.parse('http://localhost/login'),
          headers: {'Authorization': 'Basic $encoded'},
        );

        // Act
        final response = await authRoutes.router.call(request);

        // Assert
        expect(response.statusCode, equals(401));
        final body = await response.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        expect(json['error'], equals('Credenciais inválidas'));

        verifyNever(() => mockAuthService.login(any()));
      });

      test('rejeita password vazio (401)', () async {
        // Arrange - password vazio
        const credentials = 'test@example.com:';
        final encoded = base64Encode(utf8.encode(credentials));

        final request = Request(
          'POST',
          Uri.parse('http://localhost/login'),
          headers: {'Authorization': 'Basic $encoded'},
        );

        // Act
        final response = await authRoutes.router.call(request);

        // Assert
        expect(response.statusCode, equals(401));
        final body = await response.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        expect(json['error'], equals('Credenciais inválidas'));

        verifyNever(() => mockAuthService.login(any()));
      });

      test('rejeita header vazio (401)', () async {
        // Arrange
        final request = Request(
          'POST',
          Uri.parse('http://localhost/login'),
          headers: {'Authorization': ''},
        );

        // Act
        final response = await authRoutes.router.call(request);

        // Assert
        expect(response.statusCode, equals(401));
        verifyNever(() => mockAuthService.login(any()));
      });

      test('rejeita "Basic" sem valor base64 (401)', () async {
        // Arrange
        final request = Request(
          'POST',
          Uri.parse('http://localhost/login'),
          headers: {'Authorization': 'Basic '},
        );

        // Act
        final response = await authRoutes.router.call(request);

        // Assert
        expect(response.statusCode, equals(401));
        verifyNever(() => mockAuthService.login(any()));
      });
    });

    group('_login - validação AuthService', () {
      test('retorna 400 para ValidationException', () async {
        // Arrange
        const email = 'invalid-email';
        const password = '123';
        const credentials = '$email:$password';
        final encoded = base64Encode(utf8.encode(credentials));

        final request = Request(
          'POST',
          Uri.parse('http://localhost/login'),
          headers: {'Authorization': 'Basic $encoded'},
        );

        when(() => mockAuthService.login(any())).thenAnswer(
          (_) async => Failure(
            ValidationException({
              'email': ['Email inválido']
            }),
          ),
        );

        // Act
        final response = await authRoutes.router.call(request);

        // Assert
        expect(response.statusCode, equals(400));
        final body = await response.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        expect(json['error'], contains('Email inválido'));
      });

      test('retorna 401 para credenciais incorretas', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong_password';
        const credentials = '$email:$password';
        final encoded = base64Encode(utf8.encode(credentials));

        final request = Request(
          'POST',
          Uri.parse('http://localhost/login'),
          headers: {'Authorization': 'Basic $encoded'},
        );

        when(() => mockAuthService.login(any())).thenAnswer(
          (_) async => Failure(
            UnauthorizedException('Credenciais inválidas'),
          ),
        );

        // Act
        final response = await authRoutes.router.call(request);

        // Assert
        expect(response.statusCode, equals(401));
        final body = await response.readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        expect(json['error'], contains('Credenciais inválidas'));
      });
    });
  });
}
