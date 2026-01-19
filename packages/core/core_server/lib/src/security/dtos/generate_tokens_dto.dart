/// DTO com os parâmetros necessários para gerar tokens de acesso e refresh.
class GenerateTokensDto {
  /// O ID do usuário.
  final String id;

  /// O email do usuário.
  final String email;

  /// Duração do token de acesso.
  final Duration accessDuration;

  /// Duração do token de refresh.
  final Duration refreshDuration;

  const GenerateTokensDto({
    required this.id,
    required this.email,
    required this.accessDuration,
    required this.refreshDuration,
  });
}
