import 'package:shelf/shelf.dart';

abstract class AuthRequired {
  final String secret;

  AuthRequired({required this.secret});

  Middleware getMiddleware();
}
