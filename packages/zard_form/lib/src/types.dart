import 'package:zard/zard.dart';

typedef FieldValues = Map<String, dynamic>;
typedef Resolver<T> = Future<ZardResult<T>> Function(
    Map<String, dynamic> values);
typedef SubmitHandler<T> = Future<void> Function(T data);

enum ValidationMode {
  onSubmit,
  onChange,
  onBlur,
}

class ZFormState {
  final bool isValid;
  final bool isSubmitting;
  final bool isDirty;
  final bool isValidating;
  final Map<String, String?> errors;
  final Map<String, bool> dirtyFields;
  final Map<String, bool> touchedFields;

  ZFormState({
    required this.isValid,
    required this.isSubmitting,
    required this.isDirty,
    required this.isValidating,
    required this.errors,
    required this.dirtyFields,
    required this.touchedFields,
  });
}

class UseFormProps<T> {
  final Resolver<T>? resolver;
  final ValidationMode mode;
  final Map<String, dynamic>? defaultValues;
  final Duration? validationDelay;
  final bool shouldUnregister;
  final bool delayError;

  const UseFormProps({
    this.resolver,
    this.mode = ValidationMode.onSubmit,
    this.defaultValues,
    this.validationDelay,
    this.shouldUnregister = true,
    this.delayError = true,
  });
}

class FieldProps {
  final String name;
  final bool shouldValidate;
  final bool shouldTouch;
  final bool shouldDirty;

  const FieldProps({
    required this.name,
    this.shouldValidate = true,
    this.shouldTouch = true,
    this.shouldDirty = true,
  });
}
