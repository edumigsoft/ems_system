import '../enums/document_storage_type.dart';

/// DTO para criação de DocumentReference
///
/// Contém apenas os campos necessários para criar uma nova referência de documento.
/// O [id] é gerado pelo banco de dados e metadados são automáticos.
class DocumentReferenceCreate {
  final String name; // Nome do arquivo/documento
  final String path; // Caminho ou URL
  final DocumentStorageType storageType; // server, local, url
  final String? mimeType; // Ex: application/pdf, image/png
  final int? sizeBytes; // Tamanho do arquivo
  final String? notebookId; // ID do notebook ao qual anexar

  DocumentReferenceCreate({
    required this.name,
    required this.path,
    required this.storageType,
    this.mimeType,
    this.sizeBytes,
    this.notebookId,
  });

  /// Validação básica de negócio
  bool get isValid =>
      name.trim().isNotEmpty && path.trim().isNotEmpty && _validatePath();

  /// Valida o caminho/URL conforme o tipo de armazenamento
  bool _validatePath() {
    if (storageType == DocumentStorageType.url) {
      // URLs devem começar com http:// ou https://
      return path.startsWith('http://') || path.startsWith('https://');
    }
    if (storageType == DocumentStorageType.local) {
      // Caminhos locais devem começar com file://
      return path.startsWith('file://') || path.contains('/');
    }
    // Para servidor, qualquer caminho é válido
    return true;
  }

  /// Verifica se tem notebook associado
  bool get hasNotebook => notebookId != null;

  /// Verifica se o tamanho é conhecido
  bool get hasSizeInfo => sizeBytes != null;

  @override
  String toString() =>
      'DocumentReferenceCreate(name: $name, type: $storageType)';
}
