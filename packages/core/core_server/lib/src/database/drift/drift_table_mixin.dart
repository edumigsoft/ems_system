import 'package:drift/drift.dart';

import 'boolean_converter.dart';
import 'date_time_converter_non_null.dart';

mixin DriftTableMixinPostgres on Table {
  late final id = text().withDefault(
    const CustomExpression('gen_random_uuid()'),
  )();

  @JsonKey('created_at')
  TextColumn get createdAt => text()
      .map(const DateTimeConverterNonNull())
      .withDefault(const CustomExpression('CURRENT_TIMESTAMP'))();

  @JsonKey('updated_at')
  TextColumn get updatedAt => text()
      .map(const DateTimeConverterNonNull())
      .withDefault(const CustomExpression('CURRENT_TIMESTAMP'))();

  @JsonKey('is_deleted')
  IntColumn get isDeleted =>
      integer().map(const BooleanConverter()).withDefault(const Constant(0))();

  @JsonKey('is_active')
  IntColumn get isActive =>
      integer().map(const BooleanConverter()).withDefault(const Constant(1))();

  /// Define a chave primária da tabela como o campo id.
  @override
  Set<Column> get primaryKey => {id};
}
