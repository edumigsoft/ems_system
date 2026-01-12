import 'dart:io';

import 'package:core_shared/core_shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

class Server with Loggable {
  Future<void> initialize({
    required Handler handler,
    required InternetAddress address,
    required String backendPathApi,
    required int port,
    required bool urlDoc,
  }) async {
    await serve(handler, address, port);
    logger.info(
      'Server listening on -> http://${address.host}:$port$backendPathApi',
    );
    if (urlDoc) {
      logger.info(
        'Docs (Open Api) -> http://${address.host}:$port$backendPathApi/docs',
      );
    }
  }
}
