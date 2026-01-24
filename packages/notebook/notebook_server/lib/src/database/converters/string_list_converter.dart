import 'dart:convert';
import 'package:drift/drift.dart';

/// Converter para mapear entre String (JSON) e `List<String>` no banco de dados.
///
/// PostgreSQL armazena arrays JSON como TEXT, então precisamos converter
/// entre a string JSON e a lista de strings do Dart.
class StringListConverter extends TypeConverter<List<String>?, String?> {
  const StringListConverter();

  @override
  List<String>? fromSql(String? fromDb) {
    if (fromDb == null || fromDb.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(fromDb);
      if (decoded is List) {
        return decoded.cast<String>();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  String? toSql(List<String>? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return jsonEncode(value);
  }
}
