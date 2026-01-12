/// DTO para criação de Book.
///
/// - NÃO tem campo 'id' (gerado automaticamente)
/// - NÃO tem timestamps (gerenciados automaticamente)
/// - Validações usam constants compartilhadas
class BookCreate {
  final String title;
  final String isbn;
  final int publishYear;
  const BookCreate({
    required this.title,
    required this.isbn,
    required this.publishYear
  });

  // Validação de negócio
  bool get isValid {
    // Implementar validação usando constants
    return true;
  }
  
  String? validate() {
    // Implementar validações usando constants compartilhadas
    // Ex: if (name.isEmpty) return nameRequiredMessage;
    return null;
  }
}
