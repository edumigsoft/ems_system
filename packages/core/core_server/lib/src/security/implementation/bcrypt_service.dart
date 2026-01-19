import 'package:bcrypt/bcrypt.dart';
import '../crypt_service.dart';

class BCryptService implements CryptService {
  /// Verifica se uma senha corresponde a um hash armazenado.
  /// Retorna `true` se corresponder, `false` caso contrário.
  @override
  bool verify(String password, String hash) {
    try {
      return BCrypt.checkpw(password, hash);
    } catch (e) {
      // Ocorre se o hash for inválido (ex: formato incorreto)
      return false;
    }
  }

  /// Gera um hash de uma senha usando BCrypt.
  /// O BCrypt gera seu próprio salt aleatório internamente.
  @override
  String generateHash(String password) {
    // BCrypt.gensalt() gera um novo salt aleatório a cada chamada
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }
}
