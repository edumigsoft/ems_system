import 'package:drift/drift.dart';

class DateTimeConverterNonNull implements TypeConverter<DateTime, String> {
  const DateTimeConverterNonNull();

  @override
  DateTime fromSql(dynamic json) {
    if (json == null || (json is String && json.isEmpty)) {
      throw ArgumentError('DateTime cannot be null');
    }

    try {
      if (json is String) {
        // Tenta fazer parse direto da string ISO 8601 (com ou sem 'T')
        var parsed = DateTime.tryParse(json);
        if (parsed != null) return parsed;

        // Se não for um formato ISO, tenta converter de milissegundos
        final milliseconds = int.tryParse(json);
        if (milliseconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(milliseconds);
        }

        // Tenta converter o formato com espaço (ex: "2025-07-19 14:46:52.062663+00")
        // Substitui o espaço por 'T' para tentar parse ISO
        final dateTimeStr = json.replaceAll(' ', 'T');
        parsed = DateTime.tryParse(dateTimeStr);
        if (parsed != null) return parsed;

        // Se ainda não der certo, tenta parse com timezone manual
        // Ex: "2025-07-19 14:46:52.062663+00" -> "2025-07-19T14:46:52.062663+00:00"
        if (json.contains(' ')) {
          final isoLike = json.replaceAll(' ', 'T').replaceAll('+00', '+00:00');
          parsed = DateTime.tryParse(isoLike);
          if (parsed != null) return parsed;
        }
      } else if (json is int) {
        return DateTime.fromMillisecondsSinceEpoch(json);
      } else if (json is DateTime) {
        return json;
      }

      // Se chegou aqui, o formato não é reconhecido
      throw FormatException('Formato de data inválido: $json');
    } catch (e, stackTrace) {
      // ignore: avoid_print
      print('Erro ao converter data: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  String toSql(DateTime object) {
    return object.toIso8601String();
  }
}
