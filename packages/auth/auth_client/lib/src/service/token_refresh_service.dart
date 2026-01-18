import 'dart:async';

import 'package:ems_system_core_shared/core_shared.dart' show Loggable;

import '../storage/token_storage.dart';
import 'auth_api_service.dart';

/// Serviço para gerenciamento proativo de refresh de tokens.
///
/// Monitora a expiração do access token e realiza refresh automático
/// antes que expire, mantendo a sessão ativa sem interrupções.
class TokenRefreshService with Loggable {
  final TokenStorage _tokenStorage;
  final AuthApiService _apiService;

  Timer? _refreshTimer;
  bool _isRefreshing = false;

  // Configurações
  static const _checkInterval = Duration(minutes: 1);
  static const _refreshThreshold = Duration(minutes: 10);

  TokenRefreshService({
    required TokenStorage tokenStorage,
    required AuthApiService apiService,
  }) : _tokenStorage = tokenStorage,
       _apiService = apiService;

  /// Inicia o monitoramento em background.
  ///
  /// Um timer periódico verifica a cada minuto se o token está próximo
  /// da expiração e realiza o refresh automaticamente.
  void startMonitoring() {
    stopMonitoring(); // Prevenir timers duplicados
    logger.info('Iniciando monitoramento de token refresh');
    _refreshTimer = Timer.periodic(_checkInterval, (_) => _checkAndRefresh());
  }

  /// Para o monitoramento em background.
  void stopMonitoring() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    logger.info('Monitoramento de token refresh parado');
  }

  /// Verifica se o token está próximo de expirar e renova se necessário.
  Future<void> _checkAndRefresh() async {
    if (_isRefreshing) {
      logger.info('Refresh já em andamento, pulando verificação');
      return;
    }

    final needsRefresh = await _tokenStorage.tokenExpiresWithin(
      _refreshThreshold,
    );
    if (!needsRefresh) {
      logger.info('Token ainda válido, não precisa refresh');
      return;
    }

    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      logger.warning(
        'Token expirando mas sem refresh token disponível. Parando monitoramento.',
      );
      stopMonitoring();
      return;
    }

    _isRefreshing = true;
    try {
      logger.info('Renovando token proativamente (expira em <10 min)');

      final response = await _apiService.refresh({
        'refresh_token': refreshToken,
      });

      final rememberMe = await _tokenStorage.getRememberMe();

      await _tokenStorage.saveTokens(
        response.tokens,
        expiresIn: response.expiresIn,
        rememberMe: rememberMe,
      );

      logger.info('Token renovado com sucesso');
    } catch (e) {
      logger.warning('Falha ao renovar token proativamente: $e');
      // Não para o monitoramento - pode ser erro temporário de rede
    } finally {
      _isRefreshing = false;
    }
  }

  /// Tenta renovar o token ao iniciar o app se estiver expirado.
  ///
  /// Retorna `true` se conseguiu renovar ou se o token ainda está válido.
  /// Retorna `false` se não há refresh token ou se a renovação falhou.
  Future<bool> refreshOnStartup() async {
    final hasToken = await _tokenStorage.getAccessToken() != null;
    if (!hasToken) {
      logger.info('Nenhum token encontrado no startup');
      return false;
    }

    final isValid = await _tokenStorage.hasValidToken();
    if (isValid) {
      logger.info('Token ainda válido no startup');
      return true;
    }

    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      logger.info(
        'Access token expirado e sem refresh token - logout necessário',
      );
      return false;
    }

    logger.info('Access token expirado - tentando refresh no startup');

    try {
      final response = await _apiService.refresh({
        'refresh_token': refreshToken,
      });

      final rememberMe = await _tokenStorage.getRememberMe();

      await _tokenStorage.saveTokens(
        response.tokens,
        expiresIn: response.expiresIn,
        rememberMe: rememberMe,
      );

      logger.info('Token renovado com sucesso no startup');
      return true;
    } catch (e) {
      logger.warning('Falha ao renovar token no startup: $e');
      await _tokenStorage.clearTokens();
      return false;
    }
  }

  /// Libera recursos utilizados pelo serviço.
  void dispose() {
    stopMonitoring();
  }
}
