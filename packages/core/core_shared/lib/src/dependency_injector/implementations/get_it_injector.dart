import '../dependency_injector.dart';
import 'package:get_it/get_it.dart';

/// Implementação concreta do [DependencyInjector] que utiliza o GetIt.
class GetItInjector implements DependencyInjector {
  final GetIt _getIt = GetIt.instance;

  /// Recupera uma instância registrada do tipo [T].
  ///
  /// [instanceName] - Nome opcional da instância, se houver múltiplas do mesmo tipo.
  @override
  T get<T extends Object>({String? instanceName}) {
    return _getIt.get<T>(instanceName: instanceName);
  }

  /// Registra uma instância única (Singleton).
  ///
  /// [instance] - A instância a ser registrada.
  /// [instanceName] - Nome opcional para registro.
  @override
  void registerSingleton<T extends Object>(T instance, {String? instanceName}) {
    _getIt.registerSingleton<T>(instance, instanceName: instanceName);
  }

  /// Registra uma fábrica (Factory) que cria uma nova instância a cada solicitação.
  ///
  /// [factoryFunc] - Função que cria a instância.
  /// [instanceName] - Nome opcional para registro.
  @override
  void registerFactory<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    _getIt.registerFactory<T>(factoryFunc, instanceName: instanceName);
  }

  /// Registra um Singleton preguiçoso (Lazy Singleton).
  ///
  /// A instância só é criada na primeira vez que for solicitada.
  ///
  /// [factoryFunc] - Função que cria a instância.
  /// [instanceName] - Nome opcional para registro.
  @override
  void registerLazySingleton<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    _getIt.registerLazySingleton<T>(factoryFunc, instanceName: instanceName);
  }

  /// Verifica se um tipo [T] está registrado.
  ///
  /// [instanceName] - Nome opcional da instância.
  @override
  bool isRegistered<T extends Object>({String? instanceName}) {
    return _getIt.isRegistered<T>(instanceName: instanceName);
  }

  /// Reseta todos os registros e limpa as instâncias.
  @override
  Future<void> reset() async {
    await _getIt.reset();
  }
}
