import 'package:app_v1/app_layout.dart';

import 'config/di/injector.dart';
import 'package:core_shared/core_shared.dart' show GetItInjector;
import 'package:flutter/material.dart';

/// Ponto de entrada principal do aplicativo School Manager System.
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
  // Inicializa injeção de dependências
  await Injector().injector();

  // Inicia o aplicativo
  runApp(GetItInjector().get<AppLayout>());
}
