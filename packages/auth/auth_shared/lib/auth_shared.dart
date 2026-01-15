/// Auth Shared Library
///
/// Contains shared models and contracts for Authentication.
library auth_shared;

// Models
export 'src/models/auth_request.dart';
export 'src/models/auth_response.dart';
export 'src/models/token_payload.dart';

// Authorization
export 'src/authorization/auth_context.dart';
export 'src/authorization/feature_user_role_enum.dart';
export 'src/authorization/feature_user_role.dart' hide FeatureUserRole;
// Note: O enum FeatureUserRole é exportado de feature_user_role_enum.dart
// A classe entity FeatureUserRole (de feature_user_role.dart) é ocultada para evitar conflito de nomes
// A classe será acessada através de FeatureUserRoleDetails

// Domain - Entities
export 'src/domain/entities/feature_user_role_details.dart';

// Domain - DTOs
export 'src/domain/dtos/feature_user_role_create.dart';
export 'src/domain/dtos/feature_user_role_update.dart';

// Domain - Repositories
export 'src/domain/repositories/feature_user_role_repository.dart';

// Data - Models
export 'src/data/models/feature_user_role_details_model.dart';
export 'src/data/models/feature_user_role_create_model.dart';
export 'src/data/models/feature_user_role_update_model.dart';

// Validators
export 'src/validators/auth_validators.dart';
