// ignore_for_file: avoid_print
import 'dart:convert' show base64Encode;
import 'dart:math' show Random;
import 'dart:typed_data' show Uint8List;

void main() {
  // Gera uma chave de 256 bits (32 bytes)
  final key = _generateSecureBytes(32);
  // Gera um IV de 128 bits (16 bytes)
  final iv = _generateSecureBytes(16);

  // Converte para base64
  final keyBase64 = base64Encode(key);
  final ivBase64 = base64Encode(iv);

  // Note: This is a utility function for generating keys during development
  // Uncomment the lines below when you need to generate new keys
  // ignore: dead_code
  if (false) {
    print('--- Chaves Geradas ---');
    print('Chave (256 bits): $keyBase64');
    print('IV (128 bits): $ivBase64');
    print('----------------------');
    print('');
    print('Cole no seu arquivo .env:');
    print('ENCRYPTION_KEY=$keyBase64');
    print('ENCRYPTION_IV=$ivBase64');
  }
}

/// Gera bytes aleatórios seguros.
Uint8List _generateSecureBytes(int length) {
  final random = Random.secure(); // Usa Random.secure() para maior segurança
  return Uint8List.fromList(List.generate(length, (i) => random.nextInt(256)));
}
