import '../enums/document_storage_type.dart';

/// Entity de domínio pura para DocumentReference
///
/// Representa uma referência a um documento anexado a um notebook.
/// NÃO contém campos de persistência (id, uploadedAt, etc) - esses estão em [DocumentReferenceDetails].
class DocumentReference {
  final String name; // Nome do arquivo/documento
  final String path; // Caminho ou URL
  final DocumentStorageType storageType; // server, local, url
  final String? mimeType; // Ex: application/pdf, image/png
  final int? sizeBytes; // Tamanho do arquivo (se aplicável)

  const DocumentReference({
    required this.name,
    required this.path,
    required this.storageType,
    this.mimeType,
    this.sizeBytes,
  });

  /// Verifica se é um PDF
  bool get isPdf => mimeType?.contains('pdf') ?? false;

  /// Verifica se é uma imagem
  bool get isImage => mimeType?.startsWith('image/') ?? false;

  /// Verifica se é um documento de texto
  bool get isDocument =>
      mimeType?.contains('document') ??
      mimeType?.contains('msword') ??
      mimeType?.contains('text') ??
      false;

  /// Verifica se está no servidor (pode fazer download)
  bool get isOnServer => storageType == DocumentStorageType.server;

  /// Verifica se está armazenado localmente
  bool get isLocal => storageType == DocumentStorageType.local;

  /// Verifica se é apenas uma URL externa
  bool get isExternalUrl => storageType == DocumentStorageType.url;

  /// Retorna tamanho formatado
  String get formattedSize {
    if (sizeBytes == null) return 'Desconhecido';
    if (sizeBytes! < 1024) return '$sizeBytes B';
    if (sizeBytes! < 1024 * 1024) {
      return '${(sizeBytes! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Verifica se o arquivo é grande (> 10MB)
  bool get isLargeFile {
    if (sizeBytes == null) return false;
    return sizeBytes! > 10 * 1024 * 1024;
  }

  /// Nome de exibição simplificado
  String get displayName => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentReference &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          path == other.path &&
          storageType == other.storageType &&
          mimeType == other.mimeType &&
          sizeBytes == other.sizeBytes;

  @override
  int get hashCode => Object.hash(
        name,
        path,
        storageType,
        mimeType,
        sizeBytes,
      );

  @override
  String toString() => 'DocumentReference(name: $name, type: $storageType)';
}
