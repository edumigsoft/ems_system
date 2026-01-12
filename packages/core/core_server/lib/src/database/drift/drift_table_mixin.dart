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
  @BooleanConverter()
  late final isDeleted = boolean().withDefault(const Constant(false))();

  @JsonKey('is_active')
  @BooleanConverter()
  late final isActive = boolean().withDefault(const Constant(true))();

  /// Define a chave primária da tabela como o campo id.
  @override
  Set<Column> get primaryKey => {id};
}
