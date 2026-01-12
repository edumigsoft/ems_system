import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class EncryptDecryptService {
  Uint8List _key = Uint8List(0);
  Uint8List _iv = Uint8List(0);

  /// Inicializa o serviço com a KEY e o IV fornecido.
  void initialize(String key, String iv) {
    final keyBase64 = key;
    final ivBase64 = iv;

    if (key.isEmpty || ivBase64.isEmpty) {
      throw Exception('Chaves ENCRYPTION_KEY ou ENCRYPTION_IV não fornecidas');
    }

    _key = Uint8List.fromList(base64Decode(keyBase64));
    _iv = Uint8List.fromList(base64Decode(ivBase64));

    // Valida o tamanho
    if (_key.length != 32) {
      throw Exception('A chave de criptografia deve ter 32 bytes (256 bits).');
    }
    if (_iv.length != 16) {
      throw Exception('O IV de criptografia deve ter 16 bytes (128 bits).');
    }
  }

  /// Criptografa uma string e retorna o resultado como uma string base64.
  String encrypt(String plainText) {
    if (_key.isEmpty || _iv.isEmpty) {
      throw Exception(
        'EncryptionService não foi inicializado. Chame initialize() primeiro.',
      );
    }

    final plainTextBytes = Uint8List.fromList(utf8.encode(plainText));

    final cipher = CBCBlockCipher(AESEngine())
      ..init(true, ParametersWithIV(KeyParameter(_key), _iv));

    final paddedInput = _pkcs7Pad(plainTextBytes, cipher.blockSize);
    final output = Uint8List(paddedInput.length);
    cipher.processBlock(paddedInput, 0, output, 0);

    return base64Encode(output);
  }

  /// Descriptografa uma string base64 e retorna o texto original.
  String decrypt(String encryptedBase64) {
    if (_key.isEmpty || _iv.isEmpty) {
      throw Exception(
        'EncryptionService não foi inicializado. Chame initialize() primeiro.',
      );
    }

    final encryptedBytes = Uint8List.fromList(base64Decode(encryptedBase64));

    final cipher = CBCBlockCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(_key), _iv));

    final output = Uint8List(encryptedBytes.length);
    cipher.processBlock(encryptedBytes, 0, output, 0);

    final unpaddedOutput = _pkcs7Unpad(output);
    return utf8.decode(unpaddedOutput);
  }

  /// Adiciona padding PKCS7
  Uint8List _pkcs7Pad(Uint8List data, int blockSize) {
    final paddingLength = blockSize - (data.length % blockSize);
    final padding = Uint8List(paddingLength)
      ..fillRange(0, paddingLength, paddingLength);
    return Uint8List.fromList(data + padding);
  }

  /// Remove padding PKCS7
  Uint8List _pkcs7Unpad(Uint8List data) {
    final paddingLength = data.last;
    return data.sublist(0, data.length - paddingLength);
  }
}
