import 'dart:convert';

import 'package:auth_shared/auth_shared.dart'
    show LoginRequest, RegisterRequest, AuthContext, ChangePasswordRequest;
import 'package:core_server/core_server.dart' show Routes;
import 'package:core_shared/core_shared.dart'
    show ValidationException, Failure, Success, UnauthorizedException;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../service/auth_service.dart';

/// Rotas de autenticação.
class AuthRoutes extends Routes {
  final AuthService _authService;
  final String _backendBaseApi;

  AuthRoutes(this._authService, {required String backendBaseApi})
    : _backendBaseApi = backendBaseApi,
      super(
        security: false,
      ); // Rotas de auth não requerem autenticação (exceto refresh/logout que tratam internamente)

  @override
  String get path => '$_backendBaseApi/auth';

  @override
  Router get router {
    final router = Router();

    router.post('/login', _login);
    router.post('/register', _register);
    router.post('/refresh', _refresh);
    router.post('/logout', _logout);
    router.post('/forgot-password', _forgotPassword);
    router.post('/reset-password', _resetPassword);
    router.post('/change-password', _changePassword);

    return router;
  }

  /// POST /auth/login
  Future<Response> _login(Request request) async {
    try {
      // Extrair credenciais do header Authorization
      final loginRequest = _extractBasicAuthCredentials(request);

      if (loginRequest == null) {
        return Response(
          401,
          body: jsonEncode({'error': 'Credenciais inválidas'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

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
      final json = jsonDecode(body) as Map<String, dynamic>;
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
      final json = jsonDecode(body) as Map<String, dynamic>;
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
      final json = jsonDecode(body) as Map<String, dynamic>;
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
      final json = jsonDecode(body) as Map<String, dynamic>;
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
      final json = jsonDecode(body) as Map<String, dynamic>;
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

  /// POST /auth/change-password (requires authentication)
  ///
  /// IMPORTANTE: Esta rota deve ser protegida por middleware de autenticação JWT.
  /// O userId é extraído do contexto de autenticação populado pelo middleware.
  Future<Response> _changePassword(Request request) async {
    try {
      // Extrair contexto de autenticação (populado pelo middleware)
      final authContext = request.context['authContext'] as AuthContext?;
      if (authContext == null) {
        return Response(
          401,
          body: jsonEncode({'error': 'Not authenticated'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Parse request body
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final changeRequest = ChangePasswordRequest.fromJson(json);

      // Extrair refresh token (se disponível) para não revogar a sessão atual
      final currentRefreshToken = json['refresh_token'] as String?;

      // Chamar service
      final result = await _authService.changePassword(
        userId: authContext.userId,
        request: changeRequest,
        currentRefreshToken: currentRefreshToken,
      );

      return switch (result) {
        Success(value: final _) => Response.ok(
          jsonEncode({'message': 'Password changed successfully'}),
          headers: {'Content-Type': 'application/json'},
        ),
        Failure(error: final error) =>
          error is ValidationException
              ? Response(
                  400,
                  body: jsonEncode({'error': error.toString()}),
                  headers: {'Content-Type': 'application/json'},
                )
              : error is UnauthorizedException
              ? Response(
                  401,
                  body: jsonEncode({'error': error.toString()}),
                  headers: {'Content-Type': 'application/json'},
                )
              : Response(
                  500,
                  body: jsonEncode({'error': error.toString()}),
                  headers: {'Content-Type': 'application/json'},
                ),
      };
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao processar mudança de senha: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// Extrai e valida credenciais Basic Auth da requisição.
  ///
  /// Retorna LoginRequest se válido, null se ausente ou inválido.
  /// NÃO loga credenciais por segurança.
  LoginRequest? _extractBasicAuthCredentials(Request request) {
    try {
      // Obter header Authorization (Shelf sempre usa lowercase)
      final authHeader = request.headers['authorization'];

      if (authHeader == null || authHeader.isEmpty) {
        return null;
      }

      // Validar formato: "Basic {base64}"
      final trimmed = authHeader.trim();
      if (!trimmed.toLowerCase().startsWith('basic ')) {
        return null;
      }

      // Extrair porção base64 (pular prefixo "Basic ")
      final encoded = trimmed.substring(6).trim();
      if (encoded.isEmpty) {
        return null;
      }

      // Decodificar base64 → bytes → UTF-8 string
      final bytes = base64Decode(encoded);
      final decoded = utf8.decode(bytes);

      // Dividir no PRIMEIRO ':' (permite senhas com ':')
      final separatorIndex = decoded.indexOf(':');
      if (separatorIndex == -1) {
        return null;
      }

      final email = decoded.substring(0, separatorIndex);
      final password = decoded.substring(separatorIndex + 1);

      // Validação básica de presença (LoginRequestValidator faz validação profunda)
      if (email.isEmpty || password.isEmpty) {
        return null;
      }

      return LoginRequest(email: email, password: password);
    } on FormatException {
      // Base64 inválido
      return null;
    } catch (e) {
      // Outros erros de decodificação (UTF-8, etc.)
      return null;
    }
  }
}
