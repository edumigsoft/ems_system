/// Auth Server Library
///
/// Contains database tables, services, middlewares and routes for Authentication.
library auth_server;

// Database Tables
export 'src/database/tables/user_credentials_table.dart';
export 'src/database/tables/refresh_tokens_table.dart';
export 'src/database/tables/resource_members_table.dart';

// Repositories
export 'src/repository/auth_repository.dart';
export 'src/repository/resource_permission_repository.dart';

// Services
export 'src/service/auth_service.dart';
export 'src/service/resource_permission_service.dart';

// Middleware
export 'src/middleware/auth_middleware.dart';
export 'src/middleware/resource_permission_middleware.dart';

// Routes
export 'src/routes/auth_routes.dart';
export 'src/routes/resource_permission_routes.dart';

// Module
export 'src/module/init_auth_module.dart';
