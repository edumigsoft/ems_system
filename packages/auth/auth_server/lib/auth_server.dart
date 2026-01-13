/// Auth Server Library
///
/// Contains database tables, services, middlewares and routes for Authentication.
library auth_server;

// Database Tables
export 'src/database/tables/user_credentials_table.dart';
export 'src/database/tables/refresh_tokens_table.dart';
export 'src/database/tables/resource_members_table.dart';

// Middleware
export 'src/middleware/auth_middleware.dart';

// Routes
export 'src/routes/auth_routes.dart';

// Module
export 'src/module/init_auth_module.dart';
