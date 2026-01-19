abstract class CryptService {
  String generateHash(String password);
  bool verify(String password, String hash);
}
