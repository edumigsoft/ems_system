import 'package:core_shared/core_shared.dart';
import '../dtos/document_reference_create.dart';
import '../dtos/document_reference_update.dart';
import '../entities/document_reference_details.dart';
import '../enums/document_storage_type.dart';

/// Repository interface for document reference operations.
///
/// All methods return [Result] to enable explicit error handling
/// without throwing exceptions (ADR-0001: Result Pattern).
///
/// Implementations:
/// - notebook_client: HTTP client using Retrofit/Dio
/// - notebook_server: Database operations using Drift
abstract class DocumentReferenceRepository {
  /// Creates a new document reference.
  ///
  /// Returns [Success] with created [DocumentReferenceDetails] or [Failure] with error.
  Future<Result<DocumentReferenceDetails>> create(DocumentReferenceCreate data);

  /// Retrieves a document reference by its ID.
  ///
  /// Returns [Success] with [DocumentReferenceDetails] or [Failure] if not found.
  Future<Result<DocumentReferenceDetails>> getById(String id);

  /// Retrieves all document references for a specific notebook.
  ///
  /// Optional filters:
  /// - [storageType]: filter by storage type
  ///
  /// Returns [Success] with list of [DocumentReferenceDetails] or [Failure] with error.
  Future<Result<List<DocumentReferenceDetails>>> getByNotebookId(
    String notebookId, {
    DocumentStorageType? storageType,
  });

  /// Updates an existing document reference.
  ///
  /// Returns [Success] with updated [DocumentReferenceDetails] or [Failure] with error.
  Future<Result<DocumentReferenceDetails>> update(
    DocumentReferenceUpdate data,
  );

  /// Deletes a document reference permanently.
  ///
  /// Returns [Success] with void or [Failure] with error.
  Future<Result<void>> delete(String id);
}
