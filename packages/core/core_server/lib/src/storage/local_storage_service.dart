import 'dart:io';
import 'dart:typed_data';
import 'package:core_shared/core_shared.dart';
import 'package:path/path.dart' as p;

/// Implementação local do StorageService usando sistema de arquivos
///
/// Armazena arquivos em diretório local com estrutura organizada:
/// uploads/ano/mês/uuid.extensão
class LocalStorageService implements StorageService {
  final String basePath;
  final int maxFileSizeBytes;

  LocalStorageService({
    required this.basePath,
    this.maxFileSizeBytes = 50 * 1024 * 1024, // 50MB
  });

  /// Armazena um arquivo e retorna a chave de acesso
  @override
  Future<String> storeFile(
    Uint8List bytes,
    String originalName,
    String mimeType,
  ) async {
    // Validar arquivo
    final validation = StorageValidation.validateFile(
      bytes,
      originalName,
      mimeType,
    );
    if (!validation.isValid) {
      throw Exception(validation.errorMessage);
    }

    // Gerar nome seguro
    final secureName = StorageValidation.generateSecureFileName(originalName);

    // Criar estrutura de diretórios (ano/mês)
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');

    final yearMonthPath = p.join(basePath, year, month);
    final yearMonthDir = Directory(yearMonthPath);

    if (!await yearMonthDir.exists()) {
      await yearMonthDir.create(recursive: true);
    }

    // Salvar arquivo
    final filePath = p.join(yearMonthPath, secureName);
    final file = File(filePath);

    await file.writeAsBytes(bytes);

    // Retornar chave relativa (ano/mês/nome_arquivo)
    return p.join(year, month, secureName);
  }

  /// Recupera um arquivo pela chave
  @override
  Future<Uint8List> retrieveFile(String key) async {
    final filePath = p.join(basePath, key);
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: $key');
    }

    return await file.readAsBytes();
  }

  /// Deleta um arquivo pela chave
  @override
  Future<void> deleteFile(String key) async {
    final filePath = p.join(basePath, key);
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: $key');
    }

    await file.delete();
  }

  /// Stream de arquivo para download progressivo
  @override
  Stream<Uint8List> streamFile(String key) async* {
    final filePath = p.join(basePath, key);
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: $key');
    }

    final fileSize = await file.length();
    const chunkSize = 8192; // Ler bytes do stream
    final randomAccessFile = await file.open();
    int position = 0;

    try {
      while (position < fileSize) {
        final remainingBytes = fileSize - position;
        final bytesToRead = remainingBytes < chunkSize
            ? remainingBytes
            : chunkSize;

        final chunk = await randomAccessFile.read(bytesToRead);
        yield chunk;

        position += bytesToRead;
      }
    } finally {
      await randomAccessFile.close();
    }
  }

  /// Verifica se arquivo existe
  @override
  Future<bool> fileExists(String key) async {
    final filePath = p.join(basePath, key);
    final file = File(filePath);
    return await file.exists();
  }

  /// Obtém o caminho completo do arquivo no sistema
  String getFullPath(String key) => p.join(basePath, key);

  /// Obtém o tamanho do arquivo em bytes
  Future<int> getFileSize(String key) async {
    final filePath = p.join(basePath, key);
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: $key');
    }

    return await file.length();
  }

  /// Lista todos os arquivos no diretório de uploads
  Future<List<String>> listFiles({String? prefix}) async {
    final baseDir = Directory(basePath);

    if (!await baseDir.exists()) {
      return [];
    }

    final files = <String>[];

    await for (final entity in baseDir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: basePath);

        if (prefix == null || relativePath.startsWith(prefix)) {
          files.add(relativePath);
        }
      }
    }

    return files;
  }

  /// Limpa arquivos antigos (opcional para manutenção)
  Future<void> cleanupOldFiles({
    Duration maxAge = const Duration(days: 365),
  }) async {
    final baseDir = Directory(basePath);
    final cutoffDate = DateTime.now().subtract(maxAge);

    if (!await baseDir.exists()) {
      return;
    }

    await for (final entity in baseDir.list(recursive: true)) {
      if (entity is File) {
        final stat = await entity.stat();

        if (stat.modified.isBefore(cutoffDate)) {
          try {
            await entity.delete();
            // Arquivo antigo removido silenciosamente
          } catch (e) {
            // Erro ao remover arquivo antigo ignorado
          }
        }
      }
    }
  }
}
