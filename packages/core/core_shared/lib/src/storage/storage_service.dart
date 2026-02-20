import 'dart:typed_data';

/// Interface abstrata para serviços de armazenamento de arquivos.
/// 
/// Permite desacoplar a lógica de armazenamento da aplicação,
/// facilitando migração entre diferentes provedores (local, S3, etc.).
abstract class StorageService {
  /// Armazena um arquivo e retorna a chave de acesso
  /// 
  /// [bytes] - Conteúdo do arquivo
  /// [originalName] - Nome original do arquivo (para validação)
  /// [mimeType] - Tipo MIME do arquivo
  /// 
  /// Retorna a chave/identificador único para recuperar o arquivo
  Future<String> storeFile(
    Uint8List bytes,
    String originalName,
    String mimeType,
  );

  /// Recupera o conteúdo de um arquivo
  /// 
  /// [key] - Chave única retornada por [storeFile]
  Future<Uint8List> retrieveFile(String key);

  /// Deleta um arquivo armazenado
  /// 
  /// [key] - Chave única do arquivo
  Future<void> deleteFile(String key);

  /// Retorna um stream para leitura do arquivo (ideal para downloads)
  /// 
  /// [key] - Chave única do arquivo
  Stream<Uint8List> streamFile(String key);

  /// Verifica se um arquivo existe
  /// 
  /// [key] - Chave única do arquivo
  Future<bool> fileExists(String key);
}
