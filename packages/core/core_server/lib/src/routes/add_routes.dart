import '../middleware/auth_required.dart';
import 'routes.dart';
import 'package:core_shared/core_shared.dart'
    show DependencyInjector, LogService;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final _logger = LogService.getLogger('AddRoutes');

/// Gerenciador de registro de rotas no sistema.
///
/// Responsável por montar rotas públicas e protegidas,
/// aplicando middlewares de autenticação/autorização conforme necessário.
class AddRoutes {
  final String jwtSecret;
  final AuthRequired? authRequired;

  AddRoutes(this.jwtSecret, this.authRequired);

  final router = Router();

  /// Handler principal que processa todas as requisições do router.
  Handler get call => router.call;

  /// Monta uma rota sem autenticação/autorização.
  ///
  /// Use para endpoints públicos que não requerem segurança.
  Future<void> addRoutesMount(String path, Handler handler) async {
    router.mount(path, handler);
  }

  /// Monta uma rota protegida com autenticação/autorização.
  ///
  /// Aplica o middleware de autenticação configurado antes de processar
  /// as requisições. Use para endpoints que requerem usuário autenticado.
  Future<void> addGuardsRoutesMount(String path, Handler handler) async {
    if (authRequired != null) {
      router.mount(path, authRequired!.getMiddleware().call(handler));
    }
  }
}

/// Registra as rotas de um recurso no sistema.
///
/// Adiciona as rotas definidas em [routes] ao router principal,
/// aplicando segurança conforme especificado pelo parâmetro [security].
///
/// - [di]: Injeção de dependência para obter instâncias necessárias
/// - [routes]: Objeto Routes contendo path e endpoints
/// - [security]: Se true, aplica middleware de autenticação (padrão: true)
Future<void> addRoutes(
  DependencyInjector di,
  Routes routes, {
  bool security = true,
}) async {
  _logger.info('Add route path ${routes.path}');
  final addRouters = di.get<AddRoutes>();
  if (security) {
    await addRouters.addGuardsRoutesMount(routes.path, routes.router.call);
  } else {
    await addRouters.addRoutesMount(routes.path, routes.router.call);
  }
}
