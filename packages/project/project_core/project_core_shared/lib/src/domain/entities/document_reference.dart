import '../enums/document_storage_type.dart';

class DocumentReference {
  final String id;
  final String name; // Nome do arquivo/documento
  final String path; // Caminho ou URL
  final DocumentStorageType storageType; // server, local, url
  final String? mimeType; // Ex: application/pdf, image/png
  final int? sizeBytes; // Tamanho do arquivo (se aplicável)
  final DateTime uploadedAt;

  const DocumentReference({
    required this.id,
    required this.name,
    required this.path,
    required this.storageType,
    this.mimeType,
    this.sizeBytes,
    required this.uploadedAt,
  });

  /// Verifica se é um PDF
  bool get isPdf => mimeType?.contains('pdf') ?? false;

  /// Verifica se é uma imagem
  bool get isImage => mimeType?.startsWith('image/') ?? false;

  /// Verifica se está no servidor (pode fazer download)
  bool get isOnServer => storageType == DocumentStorageType.server;

  /// Verifica se é apenas uma URL externa
  bool get isExternalUrl => storageType == DocumentStorageType.url;

  /// Retorna tamanho formatado
  String get formattedSize {
    if (sizeBytes == null) return 'Desconhecido';
    if (sizeBytes! < 1024) return '$sizeBytes B';
    if (sizeBytes! < 1024 * 1024)
      return '${(sizeBytes! / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
