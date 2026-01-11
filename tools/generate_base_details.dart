import 'dart:io';

void main() {
  print('🔧 Gerando BaseDetails a partir de DriftTableMixinPostgres...\n');

  // Caminho da fonte da verdade
  final mixinPath =
      'packages/core/core_server/lib/src/database/drift/drift_table_mixin.dart';
  final outputPath =
      'packages/core/core_shared/lib/src/commons/base_details.dart';

  // Validar se arquivo fonte existe
  final mixinFile = File(mixinPath);
  if (!mixinFile.existsSync()) {
    print('❌ ERRO: Arquivo fonte não encontrado: $mixinPath');
    exit(1);
  }

  // Mapeamento de campos (baseado no mixin atual)
  // Fase 2: Parse automático do arquivo Dart
  final fields = <String, String>{
    'id': 'String',
    'created_at': 'DateTime',
    'updated_at': 'DateTime',
    'is_deleted': 'bool',
    'is_active': 'bool',
  };

  // Gerar código
  final buffer = StringBuffer();

  // Header
  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buffer.writeln('// Generated from: DriftTableMixinPostgres');
  buffer.writeln('// Source: $mixinPath');
  buffer.writeln('// Generated at: ${DateTime.now().toIso8601String()}');
  buffer.writeln();

  // Documentação da interface
  buffer.writeln(
    '/// Contrato base para todas as entidades que possuem campos de persistência.',
  );
  buffer.writeln('///');
  buffer.writeln(
    '/// Esta interface define os campos padrão fornecidos pelo [DriftTableMixinPostgres]',
  );
  buffer.writeln(
    '/// em [core_server]. Qualquer mudança no mixin DEVE ser refletida aqui via',
  );
  buffer.writeln('/// regeneração deste arquivo.');
  buffer.writeln('///');
  buffer.writeln('/// **IMPORTANTE:** Este arquivo é gerado automaticamente.');
  buffer.writeln(
    '/// Para modificar, edite [DriftTableMixinPostgres] e execute:',
  );
  buffer.writeln('/// ```bash');
  buffer.writeln('/// dart run tools/generate_base_details.dart');
  buffer.writeln('/// ```');
  buffer.writeln('///');
  buffer.writeln(
    '/// Consulte: ADR-0006 (Sincronização BaseDetails ↔ DriftTableMixin)',
  );
  buffer.writeln('abstract class BaseDetails {');

  // Campos
  for (final entry in fields.entries) {
    final fieldName = entry.key;
    final fieldType = entry.value;

    // Documentação individual por campo
    switch (fieldName) {
      case 'id':
        buffer.writeln('  /// Identificador único (UUID gerado pelo banco)');
        break;
      case 'createdAt':
        buffer.writeln('  /// Data de criação (auto-gerada pelo banco)');
        buffer.writeln('  /// NOT NULL - possui default CURRENT_TIMESTAMP');
        break;
      case 'updatedAt':
        buffer.writeln(
          '  /// Data de última atualização (auto-atualizada pelo banco)',
        );
        buffer.writeln('  /// NOT NULL - possui default CURRENT_TIMESTAMP');
        break;
      case 'isDeleted':
        buffer.writeln('  /// Flag de soft delete');
        break;
      case 'isActive':
        buffer.writeln('  /// Status de ativação');
        break;
    }

    buffer.writeln('  $fieldType get $fieldName;');
    buffer.writeln();
  }

  buffer.writeln('}');

  // Escrever arquivo
  final outputFile = File(outputPath);
  outputFile.writeAsStringSync(buffer.toString());

  // Confirmação
  print('✅ BaseDetails gerado com sucesso!');
  print('📄 Arquivo: $outputPath');
  print('📊 Campos: ${fields.length}');
  print('   - ${fields.keys.join(', ')}');
  print('');
  print('💡 Próximo passo: Execute `dart analyze` em core_shared para validar');
}
