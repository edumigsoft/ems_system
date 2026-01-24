/// Tag Shared Library
///
/// Core domain logic and entities for tag management feature.
/// This is a pure Dart library with no platform dependencies.
library;

// Domain - Entities
export 'src/domain/entities/tag.dart';
export 'src/domain/entities/tag_details.dart';

// Domain - DTOs
export 'src/domain/dtos/tag_create.dart';
export 'src/domain/dtos/tag_update.dart';

// Domain - Repositories
export 'src/domain/repositories/tag_repository.dart';

// Domain - Use Cases
export 'src/domain/use_cases/create_tag_use_case.dart';
export 'src/domain/use_cases/delete_tag_use_case.dart';
export 'src/domain/use_cases/get_all_tags_use_case.dart';
export 'src/domain/use_cases/get_tag_by_id_use_case.dart';
export 'src/domain/use_cases/update_tag_use_case.dart';

// Data - Models
export 'src/data/models/tag_create_model.dart';
export 'src/data/models/tag_details_model.dart';
export 'src/data/models/tag_update_model.dart';

// Validators
export 'src/validators/validation_result.dart';
export 'src/validators/tag_create_validator.dart';
export 'src/validators/tag_update_validator.dart';

// Constants
export 'src/constants/tag_constants.dart';
