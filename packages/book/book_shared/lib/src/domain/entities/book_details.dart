import 'package:core_shared/core_shared.dart';
import 'book.dart';

class BookDetails implements BaseDetails {
  @override
  final String id;
  @override
  final bool isDeleted;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final Book data;

  BookDetails({
    required this.id,
    required this.isDeleted,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required String title,
    required String isbn,
    required int publishYear,
  }) : data = Book(
         title: title,
         isbn: isbn,
         publishYear: publishYear
       );

  String get title => data.title;
  String get isbn => data.isbn;
  int get publishYear => data.publishYear;
  factory BookDetails.empty() {
    return BookDetails(
      id: '',
      isDeleted: false,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      title: '',
      isbn: '',
      publishYear: 0,    );
  }

  BookDetails copyWith({
    String? id,
    bool? isDeleted,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? isbn,
    int? publishYear,  }) {
    return BookDetails(
      id: id ?? this.id,
      isDeleted: isDeleted ?? this.isDeleted,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      isbn: isbn ?? this.isbn,
      publishYear: publishYear ?? this.publishYear,    );
  }
}
