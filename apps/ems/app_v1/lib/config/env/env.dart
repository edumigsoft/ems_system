import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
abstract class Env {
  @EnviedField(varName: 'BACKEND_BASE_URL')
  static const String backendBaseUrl = _Env.backendBaseUrl;
  @EnviedField(varName: 'BACKEND_REMOTE_URL')
  static const String backendRemoteUrl = _Env.backendRemoteUrl;
  @EnviedField(varName: 'BACKEND_PATH_API')
  static const String backendPathApi = _Env.backendPathApi;
}
