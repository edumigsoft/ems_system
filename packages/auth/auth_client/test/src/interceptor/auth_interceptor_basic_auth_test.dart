import 'dart:convert';

import 'package:auth_client/src/interceptor/auth_interceptor.dart';
import 'package:auth_client/src/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

void main() {
  setUpAll(() {
    // Registrar fallback para RequestOptions
    registerFallbackValue(
      RequestOptions(path: '/'),
    );
  });

  group('AuthInterceptor - Basic Auth', () {
    late AuthInterceptor interceptor;
    late MockTokenStorage mockTokenStorage;
    late Dio dio;

    setUp(() {
      mockTokenStorage = MockTokenStorage();
      dio = Dio();
      interceptor = AuthInterceptor(
        tokenStorage: mockTokenStorage,
        dio: dio,
      );
    });

    group('onRequest - /login endpoint', () {
      test('adiciona header Basic Auth para endpoint /login', () async {
        // Arrange
        final options = RequestOptions(
          path: '/auth/login',
          data: {
            'email': 'test@example.com',
            'password': 'password123',
          },
        );
        final handler = MockRequestInterceptorHandler();

        // Capturar chamada ao next
        RequestOptions? capturedOptions;
        when(() => handler.next(any())).thenAnswer((invocation) {
          capturedOptions = invocation.positionalArguments[0] as RequestOptions;
        });

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        expect(capturedOptions, isNotNull);
        expect(capturedOptions!.headers['Authorization'], isNotNull);
        expect(
          capturedOptions!.headers['Authorization'],
          startsWith('Basic '),
        );

        // Verificar que body foi limpo
        expect(capturedOptions!.data, isEmpty);
      });

      test('limpa body após codificação', () async {
        // Arrange
        final options = RequestOptions(
          path: '/auth/login',
          data: {
            'email': 'test@example.com',
            'password': 'password123',
          },
        );
        final handler = MockRequestInterceptorHandler();

        RequestOptions? capturedOptions;
        when(() => handler.next(any())).thenAnswer((invocation) {
          capturedOptions = invocation.positionalArguments[0] as RequestOptions;
        });

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        expect(capturedOptions!.data, isEmpty);
        expect(capturedOptions!.data, isA<Map<String, dynamic>>());
      });

      test('decodifica corretamente credenciais simples', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final options = RequestOptions(
          path: '/auth/login',
          data: {
            'email': email,
            'password': password,
          },
        );
        final handler = MockRequestInterceptorHandler();

        RequestOptions? capturedOptions;
        when(() => handler.next(any())).thenAnswer((invocation) {
          capturedOptions = invocation.positionalArguments[0] as RequestOptions;
        });

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        final authHeader = capturedOptions!.headers['Authorization'] as String;
        final encoded = authHeader.substring(6); // Remover "Basic "
        final decoded = utf8.decode(base64Decode(encoded));

        expect(decoded, equals('$email:$password'));
      });

      test('lida com senhas contendo ":"', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'pass:word:123';
        final options = RequestOptions(
          path: '/auth/login',
          data: {
            'email': email,
            'password': password,
          },
        );
        final handler = MockRequestInterceptorHandler();

        RequestOptions? capturedOptions;
        when(() => handler.next(any())).thenAnswer((invocation) {
          capturedOptions = invocation.positionalArguments[0] as RequestOptions;
        });

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        final authHeader = capturedOptions!.headers['Authorization'] as String;
        final encoded = authHeader.substring(6);
        final decoded = utf8.decode(base64Decode(encoded));

        expect(decoded, equals('$email:$password'));
      });

      test('lida com caracteres especiais UTF-8', () async {
        // Arrange
        const email = 'tëst@éxãmplé.com';
        const password = 'pássw0rd!@#ñ';
        final options = RequestOptions(
          path: '/auth/login',
          data: {
            'email': email,
            'password': password,
          },
        );
        final handler = MockRequestInterceptorHandler();

        RequestOptions? capturedOptions;
        when(() => handler.next(any())).thenAnswer((invocation) {
          capturedOptions = invocation.positionalArguments[0] as RequestOptions;
        });

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        final authHeader = capturedOptions!.headers['Authorization'] as String;
        final encoded = authHeader.substring(6);
        final decoded = utf8.decode(base64Decode(encoded));

        expect(decoded, equals('$email:$password'));
      });

      test('lida graciosamente com credenciais ausentes', () async {
        // Arrange - email ausente
        final options = RequestOptions(
          path: '/auth/login',
          data: {
            'password': 'password123',
          },
        );
        final handler = MockRequestInterceptorHandler();

        RequestOptions? capturedOptions;
        when(() => handler.next(any())).thenAnswer((invocation) {
          capturedOptions = invocation.positionalArguments[0] as RequestOptions;
        });

        // Act
        await interceptor.onRequest(options, handler);

        // Assert - não deve adicionar header se credenciais ausentes
        expect(
          capturedOptions!.headers.containsKey('Authorization'),
          isFalse,
        );
      });

      test('lida graciosamente com password ausente', () async {
        // Arrange
        final options = RequestOptions(
          path: '/auth/login',
          data: {
            'email': 'test@example.com',
          },
        );
        final handler = MockRequestInterceptorHandler();

        RequestOptions? capturedOptions;
        when(() => handler.next(any())).thenAnswer((invocation) {
          capturedOptions = invocation.positionalArguments[0] as RequestOptions;
        });

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        expect(
          capturedOptions!.headers.containsKey('Authorization'),
          isFalse,
        );
      });

      test('lida graciosamente com data nulo', () async {
        // Arrange
        final options = RequestOptions(
          path: '/auth/login',
          data: null,
        );
        final handler = MockRequestInterceptorHandler();

        RequestOptions? capturedOptions;
        when(() => handler.next(any())).thenAnswer((invocation) {
          capturedOptions = invocation.positionalArguments[0] as RequestOptions;
        });

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        expect(
          capturedOptions!.headers.containsKey('Authorization'),
          isFalse,
        );
      });
    });

    group('onRequest - outros endpoints', () {
      test('não modifica requisições de /register', () async {
        // Arrange
        final options = RequestOptions(
          path: '/auth/register',
          data: {
            'email': 'test@example.com',
            'password': 'password123',
            'name': 'Test User',
          },
        );
        final handler = MockRequestInterceptorHandler();

        RequestOptions? capturedOptions;
        when(() => handler.next(any())).thenAnswer((invocation) {
          capturedOptions = invocation.positionalArguments[0] as RequestOptions;
        });

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        expect(
          capturedOptions!.headers.containsKey('Authorization'),
          isFalse,
        );
        expect(capturedOptions!.data, isNotEmpty);
        final dataMap = capturedOptions!.data as Map<String, dynamic>;
        expect(dataMap['email'], equals('test@example.com'));
      });

      test('não modifica requisições de /refresh', () async {
        // Arrange
        final options = RequestOptions(
          path: '/auth/refresh',
          data: {'refresh_token': 'some_token'},
        );
        final handler = MockRequestInterceptorHandler();

        RequestOptions? capturedOptions;
        when(() => handler.next(any())).thenAnswer((invocation) {
          capturedOptions = invocation.positionalArguments[0] as RequestOptions;
        });

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        expect(
          capturedOptions!.headers.containsKey('Authorization'),
          isFalse,
        );
        expect(capturedOptions!.data, isNotEmpty);
      });

      test('não modifica requisições de /forgot-password', () async {
        // Arrange
        final options = RequestOptions(
          path: '/auth/forgot-password',
          data: {'email': 'test@example.com'},
        );
        final handler = MockRequestInterceptorHandler();

        RequestOptions? capturedOptions;
        when(() => handler.next(any())).thenAnswer((invocation) {
          capturedOptions = invocation.positionalArguments[0] as RequestOptions;
        });

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        expect(
          capturedOptions!.headers.containsKey('Authorization'),
          isFalse,
        );
        expect(capturedOptions!.data, isNotEmpty);
      });

      test('adiciona Bearer token para endpoints protegidos', () async {
        // Arrange
        const accessToken = 'test_access_token';
        when(() => mockTokenStorage.getAccessToken())
            .thenAnswer((_) async => accessToken);

        final options = RequestOptions(
          path: '/users/me',
          data: <String, dynamic>{},
        );
        final handler = MockRequestInterceptorHandler();

        RequestOptions? capturedOptions;
        when(() => handler.next(any())).thenAnswer((invocation) {
          capturedOptions = invocation.positionalArguments[0] as RequestOptions;
        });

        // Act
        await interceptor.onRequest(options, handler);

        // Assert
        expect(capturedOptions!.headers['Authorization'], isNotNull);
        expect(
          capturedOptions!.headers['Authorization'],
          equals('Bearer $accessToken'),
        );
      });
    });
  });
}
