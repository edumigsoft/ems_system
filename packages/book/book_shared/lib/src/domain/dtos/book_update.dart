/// DTO para atualização de Book.
///
/// - Campo 'id' é required
/// - Outros campos são optional (atualização parcial)
/// - Inclui isActive e isDeleted para controle
class BookUpdate {
  final String id;  // ✅ Required
  final String? title;  // ✅ Optional
  final String? isbn;  // ✅ Optional
  final int? publishYear;  // ✅ Optional
  final bool? isActive;  // ✅ Controle
  final bool? isDeleted;   // ✅ Soft delete
  BookUpdate({
    required this.id,
    this.title,
    this.isbn,
    this.publishYear,
    this.isActive,
    this.isDeleted,
  });
  
  bool get hasChanges => 
      title != null ||
      isbn != null ||
      publishYear != null ||
      isActive != null ||
      isDeleted != null;
  
  String? validate() {
    if (id.isEmpty) return 'ID é obrigatório';
    if (!hasChanges) return 'Nenhuma alteração fornecida';
    
    // Validações usando constants
    return null;
  }
}
