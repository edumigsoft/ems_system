import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Classe de utilitários para validação e sanitização de arquivos
class StorageValidation {
  static const List<String> allowedMimeTypes = [
    'application/pdf',
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'text/plain',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  ];

  static const List<String> allowedExtensions = [
    '.pdf',
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.txt',
    '.doc',
    '.docx',
  ];

  static const int maxFileSizeBytes = 50 * 1024 * 1024; // 50MB

  /// Valida o arquivo antes do upload
  /// 
  /// [bytes] - Conteúdo do arquivo
  /// [originalName] - Nome original do arquivo
  /// [mimeType] - Tipo MIME informado
  /// 
  /// Retorna [StorageValidationResult] com o resultado da validação
  static StorageValidationResult validateFile(
    Uint8List bytes,
    String originalName,
    String mimeType,
  ) {
    // Validar tamanho
    if (bytes.length > maxFileSizeBytes) {
      return StorageValidationResult.error(
        'Arquivo muito grande. Tamanho máximo: ${maxFileSizeBytes ~/ (1024 * 1024)}MB',
      );
    }

    // Validar MIME type
    if (!allowedMimeTypes.contains(mimeType)) {
      return StorageValidationResult.error(
        'Tipo de arquivo não permitido. Tipos permitidos: ${allowedMimeTypes.join(", ")}',
      );
    }

    // Validar extensão
    final extension = p.extension(originalName).toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return StorageValidationResult.error(
        'Extensão de arquivo não permitida. Extensões permitidas: ${allowedExtensions.join(", ")}',
      );
    }

    // Validar correspondência MIME vs extensão
    final expectedMime = lookupMimeType(originalName);
    if (expectedMime != null && expectedMime != mimeType) {
      return StorageValidationResult.error(
        'Extensão do arquivo não corresponde ao tipo MIME informado',
      );
    }

    return StorageValidationResult.success();
  }

  /// Gera um nome de arquivo seguro usando UUID
  /// 
  /// [originalName] - Nome original do arquivo
  /// Retorna nome único com extensão validada
  static String generateSecureFileName(String originalName) {
    final uuid = const Uuid().v4();
    final extension = p.extension(originalName).toLowerCase();
    final baseName = p.basenameWithoutExtension(originalName);
    
    // Remove caracteres especiais do nome base
    final sanitizedBaseName = baseName
        .replaceAll(RegExp(r'[^\w\-_\.]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    
    return '${sanitizedBaseName}_$uuid$extension';
  }

  /// Extrai a extensão de um nome de arquivo de forma segura
  static String getSafeExtension(String fileName) {
    final extension = p.extension(fileName).toLowerCase();
    return allowedExtensions.contains(extension) ? extension : '';
  }
}

/// Resultado da validação de arquivo
class StorageValidationResult {
  final bool isValid;
  final String? errorMessage;

  const StorageValidationResult._({required this.isValid, this.errorMessage});

  factory StorageValidationResult.success() => 
      const StorageValidationResult._(isValid: true);

  factory StorageValidationResult.error(String message) => 
      StorageValidationResult._(isValid: false, errorMessage: message);
}
