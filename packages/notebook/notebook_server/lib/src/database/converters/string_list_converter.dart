import 'dart:convert';
import 'package:drift/drift.dart';

/// Converter para mapear entre String (JSON) e `List<String>` no banco de dados.
///
/// PostgreSQL armazena arrays JSON como TEXT, então precisamos converter
/// entre a string JSON e a lista de strings do Dart.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String? fromDb) {
    if (fromDb == null || fromDb.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(fromDb);
      if (decoded is List) {
        // Filtra valores não-nulos e não-vazios
        return decoded.whereType<String>().where((s) => s.isNotEmpty).toList();
      }
      return [];
    } catch (_) {
      // Se falhar ao decodificar JSON, retorna lista vazia
      return [];
    }
  }

  @override
  String toSql(List<String> value) {
    // Sempre retorna JSON válido, mesmo para lista vazia
    return jsonEncode(value);
  }
}
