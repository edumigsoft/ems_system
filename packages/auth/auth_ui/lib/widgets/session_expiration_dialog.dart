// SessionExpirationDialog removido - não é mais necessário
//
// O refresh de tokens agora é gerenciado automaticamente pelo TokenRefreshService
// em background. O usuário não precisa mais ser avisado sobre expiração de sessão
// pois a renovação acontece de forma transparente antes do token expirar.
//
// Este arquivo foi mantido para evitar quebrar imports existentes, mas pode
// ser removido completamente se nenhum arquivo o importar.
