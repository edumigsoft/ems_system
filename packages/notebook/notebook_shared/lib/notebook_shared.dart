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

// Enums
export 'src/domain/enums/notebook_type.dart';
export 'src/domain/enums/document_storage_type.dart';
