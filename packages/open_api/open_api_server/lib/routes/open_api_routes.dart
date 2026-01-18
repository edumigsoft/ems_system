// import 'dart:convert';
// import 'dart:io';

// import 'package:core_server/core_server.dart';
// import '../open_api.dart' as open;
// import 'package:reflectable/reflectable.dart';
// import 'package:shelf/shelf.dart';
// import 'package:shelf_router/shelf_router.dart' hide Route;

import 'dart:io';

import 'package:ems_system_core_server/core_server.dart' show Routes;
import 'package:ems_system_core_shared/core_shared.dart' show Loggable;
import 'package:open_api_shared/open_api_shared.dart' hide Response;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class OpenApiRoutes extends Routes with Loggable {
  final String _backendBaseApi;
  final String _staticPath;

  OpenApiRoutes({
    required String backendBaseApi,
    String staticPath = 'assets',
  }) : _backendBaseApi = backendBaseApi,
       _staticPath = staticPath;

  @override
  String get path => '$_backendBaseApi/docs';

  @override
  Router get router {
    final router = Router();

    // UI
    router.get('/', _openApiUI);

    // Doc json
    router.get('/openapi.json', _getOpenApiSpec);

    return router;
  }

  Future<Response> _openApiUI(Request request) async {
    final specUrl = '$path/openapi.json';

    final possiblePaths = [
      '$_staticPath/swagger.html',
      'packages/open_api/open_api_server/$_staticPath/swagger.html',
      '../../packages/open_api/open_api_server/$_staticPath/swagger.html',
    ];

    File? swaggerFile;
    for (final p in possiblePaths) {
      final f = File(p);
      if (await f.exists()) {
        swaggerFile = f;
        break;
      }
    }

    if (swaggerFile != null) {
      String content = await swaggerFile.readAsString();
      content = content.replaceFirst('{{SPEC_URL}}', specUrl);

      return Response.ok(
        content,
        headers: {'content-type': 'text/html'},
      );
    } else {
      return Response.internalServerError(
        body:
            'Swagger UI template not found at any of: ${possiblePaths.join(", ")}',
      );
    }
  }

  Response _getOpenApiSpec(Request request) {
    final generator = OpenApiGenerator(
      backendBaseApi: _backendBaseApi,
    );
    generator.generateDoc();

    return Response.ok(
      generator.generateJson(),
      headers: {'content-type': 'application/json'},
    );
  }
}
