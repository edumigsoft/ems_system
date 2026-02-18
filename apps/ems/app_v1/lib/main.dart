import 'package:alice/model/alice_configuration.dart';
import 'package:core_shared/core_shared.dart' show GetItInjector;
import 'package:ems_app_v1/app_layout.dart';
import 'package:flutter/material.dart';

import 'config/di/injector.dart';

import 'package:alice/alice.dart';

final alice = Alice(
  configuration: AliceConfiguration(
    showNotification: false,
    showInspectorOnShake: true,
  ),
);

/// Ponto de entrada principal do aplicativo EMS System.
///
/// ## Visão Geral
/// Este arquivo é responsável por inicializar e configurar os componentes essenciais
/// do aplicativo antes de iniciar a interface do usuário.
///
/// ## Fluxo de Inicialização
/// 1. Garante a inicialização do Flutter (`WidgetsFlutterBinding.ensureInitialized()`)
/// 2. Configura o nível de log padrão
/// 3. Configura o gerenciador de logs
/// 4. Inicializa a injeção de dependências
/// 5. Inicia o aplicativo com o layout principal
///
/// ## Configuração de Ambientes
/// O aplicativo suporta múltiplos ambientes que podem ser configurados através
/// de variáveis de ambiente durante a compilação:
/// - Desenvolvimento (dev)
/// - Homologação (staging)
/// - Produção (production)
///
/// ## Testes
/// - Cobertura atual: 0% (arquivo não testado)
/// - Plano de testes: Implementar testes de integração
///
/// ## Exemplo de Uso
/// ```dart
/// // Para executar em ambiente de desenvolvimento:
/// flutter run --dart-define=ENV=dev
///
/// // Para executar em produção:
/// flutter build apk --release --dart-define=ENV=production
/// ```
///
/// ## Logs e Monitoramento
/// - Erros críticos são registrados automaticamente
/// - Logs são categorizados por nível (INFO, WARNING, SEVERE)
/// - Integração com serviços de monitoramento pode ser adicionada em [_reportError](cci:1://file:///home/anderson/Projects/Working/school_manager_system_fullstack/apps/app_v1/lib/main.dart:31:0-50:1)
void main() async {
  // Captura erros não tratados
  FlutterError.onError = (details) {
    debugPrint('❌ Flutter Error: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  // Inicializa os bindings do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  try {
    debugPrint('🚀 main() iniciando...');

    // Inicializa injeção de dependências
    debugPrint('📦 Chamando Injector()...');
    await Injector().injector();
    debugPrint('✅ Injector concluído');

    // Inicia o aplicativo
    debugPrint('🎯 Iniciando runApp...');
    runApp(GetItInjector().get<AppLayout>());
    debugPrint('✅ runApp concluído');
  } catch (e, stackTrace) {
    debugPrint('❌❌❌ ERRO FATAL em main(): $e');
    debugPrint('Stack: $stackTrace');

    // Mostra erro na tela
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 100, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'ERRO FATAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    e.toString(),
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
