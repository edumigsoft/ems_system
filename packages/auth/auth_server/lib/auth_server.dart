/// Auth Server Library
///
/// Contains database tables, services, middlewares and routes for Authentication.
library auth_server;

// Database Tables
export 'src/database/tables/user_credentials_table.dart';
export 'src/database/tables/refresh_tokens_table.dart';
export 'src/database/tables/project_user_role_table.dart';

// Database Converters
export 'src/database/converters/feature_user_role_converter.dart';

// Repositories
export 'src/repository/auth_repository.dart';
export 'src/repository/project_user_role_repository.dart';

// Services
export 'src/service/auth_service.dart';
export 'src/service/project_user_role_service.dart';

// Middleware
export 'src/middleware/auth_middleware.dart';
export 'src/middleware/feature_role_middleware.dart';

// Routes
export 'src/routes/auth_routes.dart';
export 'src/routes/project_user_role_routes.dart';

// Module
export 'src/module/init_auth_module.dart';
