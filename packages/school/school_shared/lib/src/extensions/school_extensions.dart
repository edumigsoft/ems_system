import '../domain/entities/school_details.dart';

extension SchoolDetailsExtension on SchoolDetails {
  /// Converts [SchoolDetails] to itself.
  /// Useful for consistency when a mapper is required or to decouple response from entity in the future.
  SchoolDetails toDetails() => this;
}
