import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:core_shared/core_shared.dart';
import 'package:core_server/core_server.dart';
import 'package:auth_shared/auth_shared.dart';

import '../service/auth_service.dart';

/// Rotas de autenticação.
class AuthRoutes extends Routes {
  final AuthService _authService;

  AuthRoutes(this._authService)
    : super(
        security: false,
      ); // Rotas de auth não requerem autenticação (exceto refresh/logout que tratam internamente)

  @override
  String get path => '/auth';

  @override
  Router get router {
    final router = Router();

    router.post('/login', _login);
    router.post('/register', _register);
    router.post('/refresh', _refresh);
    router.post('/logout', _logout);
    router.post('/forgot-password', _forgotPassword);
    router.post('/reset-password', _resetPassword);

    return router;
  }

  /// POST /auth/login
  Future<Response> _login(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final loginRequest = LoginRequest.fromJson(json);

      final result = await _authService.login(loginRequest);

      return switch (result) {
        Success(value: final value) => Response.ok(
          jsonEncode(value.toJson()),
          headers: {'Content-Type': 'application/json'},
        ),
        Failure(error: final error) =>
          error is ValidationException
              ? Response(400, body: jsonEncode({'error': error.toString()}))
              : Response(401, body: jsonEncode({'error': error.toString()})),
      };
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao processar login: $e'}),
      );
    }
  }

  /// POST /auth/register
  Future<Response> _register(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final registerRequest = RegisterRequest.fromJson(json);

      final result = await _authService.register(registerRequest);

      return switch (result) {
        Success(value: final value) => Response(
          201,
          body: jsonEncode(value.toJson()),
          headers: {'Content-Type': 'application/json'},
        ),
        Failure(error: final error) =>
          error is ValidationException
              ? Response(400, body: jsonEncode({'error': error.toString()}))
              : Response(400, body: jsonEncode({'error': error.toString()})),
        // Nota: Response 400 genérico para falha de registro
      };
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao processar registro: $e'}),
      );
    }
  }

  /// POST /auth/refresh
  Future<Response> _refresh(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final refreshToken = json['refresh_token'] as String?;

      if (refreshToken == null) {
        return Response(
          400,
          body: jsonEncode({'error': 'Refresh token required'}),
        );
      }

      final result = await _authService.refresh(refreshToken);

      return switch (result) {
        Success(value: final value) => Response.ok(
          jsonEncode(value.toJson()),
          headers: {'Content-Type': 'application/json'},
        ),
        Failure(error: final error) => Response(
          401,
          body: jsonEncode({'error': error.toString()}),
        ),
      };
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao renovar token: $e'}),
      );
    }
  }

  /// POST /auth/logout
  Future<Response> _logout(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final refreshToken = json['refresh_token'] as String?;

      if (refreshToken == null) {
        return Response.ok(jsonEncode({'message': 'Logged out'}));
      }

      await _authService.logout(refreshToken);

      return Response.ok(
        jsonEncode({'message': 'Logged out'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao processar logout: $e'}),
      );
    }
  }

  /// POST /auth/forgot-password
  Future<Response> _forgotPassword(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final email = json['email'] as String?;

      if (email == null) {
        return Response(400, body: jsonEncode({'error': 'Email required'}));
      }

      await _authService.forgotPassword(email);

      // Sempre retorna sucesso por segurança
      return Response.ok(
        jsonEncode({'message': 'If email exists, reset instructions sent.'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao processar request: $e'}),
      );
    }
  }

  /// POST /auth/reset-password
  Future<Response> _resetPassword(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final token = json['token'] as String?;
      final newPassword = json['new_password'] as String?;

      if (token == null || newPassword == null) {
        return Response(
          400,
          body: jsonEncode({'error': 'Token and new password required'}),
        );
      }

      final result = await _authService.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      return switch (result) {
        Success(value: final _) => Response.ok(
          jsonEncode({'message': 'Password reset successfully'}),
          headers: {'Content-Type': 'application/json'},
        ),
        Failure(error: final error) => Response(
          400,
          body: jsonEncode({'error': error.toString()}),
        ),
      };
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao processar reset: $e'}),
      );
    }
  }
}
