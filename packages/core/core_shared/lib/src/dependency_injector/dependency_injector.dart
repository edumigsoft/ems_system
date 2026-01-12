/// Interface abstrata para injeção de dependências.
///
/// Define o contrato para registrar e recuperar dependências no sistema,
/// permitindo desacoplamento e facilitando testes.
abstract class DependencyInjector {
  /// Recupera uma instância registrada do tipo [T].
  ///
  /// [instanceName] - Nome opcional da instância, se houver múltiplas do mesmo tipo.
  T get<T extends Object>({String? instanceName});

  /// Reseta todos os registros e limpa as instâncias.
  Future<void> reset();

  /// Verifica se um tipo [T] está registrado.
  ///
  /// [instanceName] - Nome opcional da instância.
  bool isRegistered<T extends Object>({String? instanceName});

  /// Registra uma instância única (Singleton).
  ///
  /// [instance] - A instância a ser registrada.
  /// [instanceName] - Nome opcional para registro.
  void registerSingleton<T extends Object>(T instance, {String? instanceName});

  /// Registra uma fábrica (Factory) que cria uma nova instância a cada solicitação.
  ///
  /// [factoryFunc] - Função que cria a instância.
  /// [instanceName] - Nome opcional para registro.
  void registerFactory<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  });

  /// Registra um Singleton preguiçoso (Lazy Singleton).
  ///
  /// A instância só é criada na primeira vez que for solicitada.
  ///
  /// [factoryFunc] - Função que cria a instância.
  /// [instanceName] - Nome opcional para registro.
  void registerLazySingleton<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  });
}
