import 'package:drift/drift.dart';

class BooleanConverter implements TypeConverter<bool, int> {
  const BooleanConverter();

  @override
  bool fromSql(dynamic json) {
    try {
      return json is bool
          ? json
          : json is int
          ? json == 1
          : false;
    } catch (e) {
      return false;
    }
  }

  @override
  int toSql(bool object) => object ? 1 : 0;
}
