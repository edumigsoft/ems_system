/// Core domain logic and entities for notebook management feature
library;

// Domain Entities (Pure Domain - No ID, No Persistence Concerns)
export 'src/domain/entities/notebook.dart';
export 'src/domain/entities/document_reference.dart';

// Entity Details (Complete Aggregation with BaseDetails)
export 'src/domain/entities/notebook_details.dart';
export 'src/domain/entities/document_reference_details.dart';

// DTOs (Data Transfer Objects)
export 'src/domain/dtos/notebook_create.dart';
export 'src/domain/dtos/notebook_update.dart';
export 'src/domain/dtos/document_reference_create.dart';
export 'src/domain/dtos/document_reference_update.dart';

// Domain - Repositories
export 'src/domain/repositories/notebook_repository.dart';
export 'src/domain/repositories/document_reference_repository.dart';

// Data - Models
export 'src/data/models/notebook_details_model.dart';
export 'src/data/models/notebook_create_model.dart';
export 'src/data/models/notebook_update_model.dart';
export 'src/data/models/document_reference_details_model.dart';
export 'src/data/models/document_reference_create_model.dart';
export 'src/data/models/document_reference_update_model.dart';

// Enums
export 'src/domain/enums/notebook_type.dart';
export 'src/domain/enums/document_storage_type.dart';

// Validators
export 'src/validators/notebook_validator.dart';
