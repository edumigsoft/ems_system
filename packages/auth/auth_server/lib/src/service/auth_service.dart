import 'package:auth_shared/auth_shared.dart';
import 'package:core_server/core_server.dart';
import 'package:core_shared/core_shared.dart'; // Required for Result, Exceptions
import 'package:drift/drift.dart';
import 'package:user_server/user_server.dart';
import 'package:user_shared/user_shared.dart';

import '../database/auth_database.dart';
import '../repository/auth_repository.dart';

/// Serviço de autenticação.
///
/// Orquestra autenticação, registro, tokens e segurança.
class AuthService {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;
  final SecurityService _securityService; // JWT
  final CryptService _cryptService; // Password Hash
  final EmailService _emailService;
  final LoginRequestValidator _loginValidator;
  final RegisterRequestValidator _registerValidator;
  final ChangePasswordRequestValidator _changePasswordValidator;

  // Configurações (injetadas ou env)
  final int accessTokenExpiresMinutes;
  final int refreshTokenExpiresDays;

  AuthService({
    required AuthRepository authRepo,
    required UserRepository userRepo,
    required SecurityService securityService,
    required CryptService cryptService,
    required EmailService emailService,
    this.accessTokenExpiresMinutes = 15,
    this.refreshTokenExpiresDays = 7,
  }) : _authRepo = authRepo,
       _userRepo = userRepo,
       _securityService = securityService,
       _cryptService = cryptService,
       _emailService = emailService,
       _loginValidator = const LoginRequestValidator(),
       _registerValidator = const RegisterRequestValidator(),
       _changePasswordValidator = const ChangePasswordRequestValidator();

  /// Realiza login com email e senha.
  Future<Result<AuthResponse>> login(LoginRequest request) async {
    // 1. Validar request
    final validation = _loginValidator.validate(request);
    if (!validation.isValid) {
      return Failure(
        ValidationException(_mapValidationErrors(validation.errors)),
      );
    }

    // 2. Buscar usuário
    final userResult = await _userRepo.findByEmail(request.email);
    if (userResult.isFailure) {
      // Retornar erro genérico para não enumerar emails
      return Failure(UnauthorizedException('Credenciais inválidas'));
    }
    final user = userResult
        .valueOrNull!; // valueOrNull é seguro pois já checamos isFailure? Não, valueOrNull retorna null. valueOrThrow é melhor ou cast.
    // Mas userResult.content na versao original implicava acesso direto.
    // userResult é Result<UserDetails>. Se !isFailure, é Success.
    // userResult.valueOrThrow

    // 3. Verificar usuário ativo
    if (!user.isActive) {
      return Failure(UnauthorizedException('Conta desativada'));
    }

    // 4. Buscar credenciais
    final credentials = await _authRepo.getCredentials(user.id);
    if (credentials == null) {
      return Failure(UnauthorizedException('Credenciais inválidas'));
    }

    // 5. Verificar senha
    final isValidPassword = _cryptService.verify(
      request.password,
      credentials.passwordHash,
    );
    if (!isValidPassword) {
      await _authRepo.incrementFailedAttempts(user.id);
      return Failure(UnauthorizedException('Credenciais inválidas'));
    }

    // 6. Resetar tentativas falhas
    await _authRepo.resetFailedAttempts(user.id);

    // 7. Gerar tokens
    return _generateTokens(user);
  }

  /// Registra novo usuário.
  Future<Result<AuthResponse>> register(RegisterRequest request) async {
    // 1. Validar request
    final validation = _registerValidator.validate(request);
    if (!validation.isValid) {
      return Failure(
        ValidationException(_mapValidationErrors(validation.errors)),
      );
    }

    // 2. Criar usuário (UserRepository valida unicidade de email/username)
    final userCreate = UserCreate(
      name: request.name,
      email: request.email,
      username: request.username,
      password: request.password,
      phone: request.phone,
    );

    final userResult = await _userRepo.create(userCreate);

    // Tratamento de Result
    // if (userResult case Failure(:final error)) return Failure(error); // Pattern matching mais limpo
    if (userResult.isFailure) {
      return Failure((userResult as Failure).error);
    }

    final user = (userResult as Success).value;

    // 3. Salvar credenciais (hash)
    final passwordHash = _cryptService.generateHash(request.password);

    try {
      await _authRepo.saveCredentials(
        UserCredentialsCompanion(
          userId: Value(user.id),
          passwordHash: Value(passwordHash),
          lastLoginAt: Value(DateTime.now()),
        ),
      );
    } catch (e) {
      // Rollback: deletar usuário se falhar ao salvar credenciais
      await _userRepo.softDelete(user.id);
      return Failure(Exception('Falha ao criar credenciais: $e'));
    }

    // 4. Enviar email de verificação (fire and forget)
    _emailService.sendVerificationEmail(
      to: user.email,
      userName: user.name,
      verificationLink: 'http://todo-config/verify', // Configurar link real
    );

    // 5. Autenticar usuário criado
    return _generateTokens(user);
  }

  /// Renova tokens usando refresh token.
  Future<Result<AuthResponse>> refresh(String refreshToken) async {
    // 1. Buscar token no banco
    final storedToken = await _authRepo.getRefreshToken(refreshToken);
    if (storedToken == null) {
      return Failure(UnauthorizedException('Token inválido ou expirado'));
    }

    // 2. Rotation: Invalidar token usado
    await _authRepo.revokeRefreshToken(refreshToken);

    // 3. Buscar usuário
    final userResult = await _userRepo.findById(storedToken.userId);
    if (userResult.isFailure) {
      return Failure(UnauthorizedException('Usuário não encontrado'));
    }
    final user = (userResult as Success<UserDetails>).value;

    // 4. Gerar novos tokens
    return _generateTokens(user);
  }

  /// Realiza logout (revoga refresh token).
  Future<Result<void>> logout(String refreshToken) async {
    await _authRepo.revokeRefreshToken(refreshToken);
    return Success(null);
  }

  /// Inicia fluxo de recuperação de senha.
  Future<Result<void>> forgotPassword(String email) async {
    // 1. Buscar usuário
    final userResult = await _userRepo.findByEmail(email);
    // Não revelar se email existe ou não (segurança por obscuridade?)
    // A especificação diz para retornar 200 OK sempre.
    if (userResult.isFailure) {
      // Logar tentativa inválida?
      return Success(null);
    }
    final user = (userResult as Success<UserDetails>).value;

    // 2. Gerar token de reset (JWT de curta duração ou token opaco)
    // Vamos usar JWT assinado com propósito específico
    final resetTokenPayload = {
      'sub': user.id,
      'purpose': 'password_reset',
      'exp':
          DateTime.now()
              .add(const Duration(minutes: 60))
              .millisecondsSinceEpoch ~/
          1000,
    };

    final tokenResult = await _securityService.generateToken(
      resetTokenPayload,
      'ems_system_reset',
    );

    if (tokenResult.isFailure) {
      return Failure((tokenResult as Failure).error);
    }
    final resetToken = (tokenResult as Success).value;

    // 3. Enviar email
    final resetLink = 'http://localhost:3000/reset-password?token=$resetToken';

    _emailService.sendPasswordResetEmail(
      to: user.email,
      userName: user.name,
      resetLink: resetLink,
      expiresIn: const Duration(minutes: 60),
    );

    return Success(null);
  }

  /// Redefine a senha usando token.
  Future<Result<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    // 1. Validar token
    final payloadResult = await _securityService.verifyToken(
      token,
      'ems_system_reset',
    );
    if (payloadResult.isFailure) {
      return Failure(UnauthorizedException('Token inválido ou expirado'));
    }

    final payload = (payloadResult as Success).value;
    if (payload['purpose'] != 'password_reset') {
      return Failure(UnauthorizedException('Token inválido'));
    }

    final userId = payload['sub'] as String;

    // 2. Buscar credenciais atuais para garantir que usuário existe
    final credentials = await _authRepo.getCredentials(userId);
    if (credentials == null) {
      return Failure(UnauthorizedException('Usuário não encontrado'));
    }

    // 3. Atualizar senha
    final passwordHash = _cryptService.generateHash(newPassword);

    // Atualizar no repo
    // Precisaria de um método updateCredentials ou similar.
    // AuthRepository tem saveCredentials (insert), mas update?
    // UserCredentials é PK userId. drift `into(..).insertOnConflictUpdate` pode funcionar se configurado,
    // ou update(userCredentials)..where..

    // Vou assumir que saveCredentials usa insertOnConflictUpdate ou adicionar método update.
    // Olhando AuthRepository: `into(userCredentials).insert(credentials)` -> default é exception on conflict.
    // Preciso adicionar updatePassword em AuthRepository.

    // Como não posso editar AuthRepository agora (estou focado em AuthService), vou tentar usar o que tenho ou anotar todo.
    // Mas preciso entregar funcionando. Vou adicionar updatePassword no AuthRepository num passo seguinte se não existir.
    // Vou verificar AuthRepository em seguida. Por enquanto, vou codar a chamada imaginária `updatePassword`.

    await _authRepo.updatePassword(userId, passwordHash);

    // 4. Invalidar todos os refresh tokens (logout de todos os dispositivos)
    // AuthRepository deve ter revokeAllRefreshTokens(userId).
    await _authRepo.revokeAllRefreshTokens(userId);

    return Success(null);
  }

  /// Muda a senha do usuário autenticado.
  ///
  /// Verifica a senha atual, valida a nova senha, atualiza o hash e
  /// revoga todos os refresh tokens EXCETO o token da requisição atual.
  Future<Result<void>> changePassword({
    required String userId,
    required ChangePasswordRequest request,
    String? currentRefreshToken, // Token da sessão atual para NÃO revogar
  }) async {
    // 1. Validar request
    final validation = _changePasswordValidator.validate(request);
    if (!validation.isValid) {
      return Failure(
        ValidationException(_mapValidationErrors(validation.errors)),
      );
    }

    // 2. Buscar credenciais
    final credentials = await _authRepo.getCredentials(userId);
    if (credentials == null) {
      return Failure(UnauthorizedException('Usuário não encontrado'));
    }

    // 3. Verificar senha atual
    final isValidPassword = _cryptService.verify(
      request.currentPassword,
      credentials.passwordHash,
    );
    if (!isValidPassword) {
      return Failure(UnauthorizedException('Senha atual incorreta'));
    }

    // 4. Verificar se nova senha é diferente da atual
    final isSamePassword = _cryptService.verify(
      request.newPassword,
      credentials.passwordHash,
    );
    if (isSamePassword) {
      return Failure(
        ValidationException({
          'newPassword': ['Nova senha deve ser diferente da senha atual'],
        }),
      );
    }

    // 5. Gerar hash da nova senha
    final newPasswordHash = _cryptService.generateHash(request.newPassword);

    // 6. Atualizar senha
    await _authRepo.updatePassword(userId, newPasswordHash);

    // 7. Revogar OUTROS refresh tokens (segurança)
    // Mantém o token atual ativo para não deslogar o usuário
    await _authRepo.revokeAllRefreshTokensExcept(userId, currentRefreshToken);

    return Success(null);
  }

  /// Gera par de tokens (Access + Refresh).
  Future<Result<AuthResponse>> _generateTokens(UserDetails user) async {
    try {
      // Access Token
      final tokenPayload = TokenPayload(
        sub: user.id,
        email: user.email,
        role: user.role,
        iat: DateTime.now(),
        exp: DateTime.now().add(Duration(minutes: accessTokenExpiresMinutes)),
      );

      // Converte para Map<String, dynamic> para o SecurityService
      final accessTokenResult = await _securityService.generateToken(
        tokenPayload.toJson(),
        'ems_system', // Audience
      );

      if (accessTokenResult.isFailure) {
        return Failure((accessTokenResult as Failure).error);
      }

      // Refresh Token (Opaco ou JWT)
      final refreshPayload = TokenPayload(
        sub: user.id,
        email: user.email,
        role: user.role,
        iat: DateTime.now(),
        exp: DateTime.now().add(Duration(days: refreshTokenExpiresDays)),
        jti: DateTime.now().millisecondsSinceEpoch.toString(), // JTI único
      );

      final refreshTokenResult = await _securityService.generateToken(
        refreshPayload.toJson(),
        'ems_system_refresh',
      );

      if (refreshTokenResult.isFailure) {
        return Failure((refreshTokenResult as Failure).error);
      }

      final accessToken = (accessTokenResult as Success).value;
      final refreshToken = (refreshTokenResult as Success).value;
      final expiresAt =
          refreshPayload.exp; // Data exata de expiração do Refresh

      // Persistir Refresh Token
      await _authRepo.saveRefreshToken(
        RefreshTokensCompanion(
          userId: Value(user.id),
          tokenHash: Value(refreshToken),
          expiresAt: Value(expiresAt),
        ),
      );

      return Success(
        AuthResponse(
          tokens: TokenPair(
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
          user: user,
          expiresIn: accessTokenExpiresMinutes * 60, // Segundos
        ),
      );
    } catch (e) {
      return Failure(Exception('Erro ao gerar tokens: $e'));
    }
  }

  Map<String, List<String>> _mapValidationErrors(
    List<CoreValidationError> errors,
  ) {
    final map = <String, List<String>>{};
    for (final error in errors) {
      if (!map.containsKey(error.field)) {
        map[error.field] = [];
      }
      map[error.field]!.add(error.message);
    }
    return map;
  }
}
