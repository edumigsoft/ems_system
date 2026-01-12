import 'package:flutter/material.dart';
import 'package:zard/zard.dart';

import 'types.dart';

Resolver<T> zardResolver<T>(ZMap schema) {
  return (Map<String, dynamic> values) async {
    final result = await schema.safeParseAsync(values);
    if (result.data != null) {
      return ZardResult<T>(
        success: result.success,
        data: result.data is T ? result.data as T : null,
        error: result.error,
      );
    }
    return ZardResult<T>(
      success: result.success,
      data: null,
      error: result.error,
    );
  };
}

ZForm<T> useForm<T>({
  Resolver<T>? resolver,
  ValidationMode mode = ValidationMode.onSubmit,
  Map<String, dynamic>? defaultValues,
  Duration? validationDelay,
  bool shouldUnregister = true,
  bool delayError = true,
}) {
  return ZForm<T>(
    props: UseFormProps(
      resolver: resolver,
      mode: mode,
      defaultValues: defaultValues,
      validationDelay: validationDelay,
      shouldUnregister: shouldUnregister,
      delayError: delayError,
    ),
  );
}

class ZForm<T> extends ChangeNotifier {
  final UseFormProps<T> _props;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _errors = {};
  final Map<String, dynamic> _values = {};
  final Map<String, bool> _dirtyFields = {};
  final Map<String, bool> _touchedFields = {};

  bool _isSubmitting = false;
  //
  bool _isValidating = false;
  bool _isValid = false;
  bool _isDirty = false;
  bool _mounted = true;
  T? _lastValidData;
  DateTime? _lastValidationTime;

  final Duration _validationCacheTimeout;

  ZForm({
    required UseFormProps<T> props,
  })  : _props = props,
        _validationCacheTimeout =
            props.validationDelay ?? const Duration(milliseconds: 500) {
    _initializeForm();
  }

  void _initializeForm() {
    _props.defaultValues?.forEach((key, value) {
      _values[key] = value;
      final controller = TextEditingController(text: value?.toString() ?? '');
      _setupController(key, controller);
      _controllers[key] = controller;
    });
  }

  void _setupController(String name, TextEditingController controller) {
    controller.addListener(() {
      _values[name] = controller.text;
      _dirtyFields[name] = true;
      _isDirty = true;

      if (_props.mode == ValidationMode.onChange) {
        //
        _validateField(name);

        handleValid();
      }

      notifyListenersIfMounted();
    });
  }

  TextEditingController register(String name, [FieldProps? options]) {
    if (!_controllers.containsKey(name)) {
      final controller = TextEditingController(
        text: _props.defaultValues?[name]?.toString() ?? '',
      );
      _setupController(name, controller);
      _controllers[name] = controller;
    }
    return _controllers[name]!;
  }

  //
  Future<void> _validateField(String name) async {
    if (_props.resolver == null) return;

    _isValidating = true;
    notifyListenersIfMounted();

    try {
      final result = await _props.resolver!(_values);
      if (!result.success) {
        // Verifica se existe algum erro associado ao campo 'name'
        if (result.error?.issues
                .any((issue) => issue.path.toString() == name) ??
            false) {
          final fieldError = result.error!.issues.firstWhere(
            (issue) => issue.path.toString() == name,
          );
          _errors[name] = fieldError.message;
        } else {
          // Se não houver erro, remove o erro do campo
          _errors.remove(name);
        }
      } else {
        // Se a validação retornar sucesso, remove o erro do campo
        _errors.remove(name);
      }
    } finally {
      _isValidating = false;
      notifyListenersIfMounted();
    }
  }

  ZFormState get formState => ZFormState(
        isValid: _isValid,
        isSubmitting: _isSubmitting,
        isDirty: _isDirty,
        isValidating: _isValidating,
        errors: _errors,
        dirtyFields: _dirtyFields,
        touchedFields: _touchedFields,
      );

  bool get isSubmitting => _isSubmitting;
  String? error(String name) => _errors[name];
  dynamic getValue(String name) => _values[name];
  Map<String, dynamic> get values => _values;

  void setValue(String name, dynamic value) {
    _controllers[name]?.text = value.toString();
    _values[name] = value;
    _dirtyFields[name] = true;
    _isDirty = true;
    notifyListenersIfMounted();
  }

  void setError(String name, String message) {
    _errors[name] = message;
    notifyListenersIfMounted();
  }

  void clearErrors([String? name]) {
    if (name != null) {
      _errors.remove(name);
    } else {
      _errors.clear();
    }
    notifyListenersIfMounted();
  }

  void reset([Map<String, dynamic>? initialValues]) {
    initialValues?.forEach((key, value) {
      setValue(key, value);
    });
    if (initialValues == null) {
      for (final key in _controllers.keys) {
        _controllers[key]?.clear();
      }
    }
  }

  Future<void> handleSubmit(SubmitHandler<T> onValid) async {
    if (_isSubmitting) return;

    _isSubmitting = true;
    notifyListenersIfMounted();

    try {
      if (_props.resolver == null) {
        throw Exception('No resolver provided');
      }

      if (_lastValidData != null &&
          _lastValidationTime != null &&
          DateTime.now().difference(_lastValidationTime!) <
              _validationCacheTimeout) {
        await onValid(_lastValidData as T);
        return;
      }

      final result = await _props.resolver!(_values);
      _errors.clear();

      if (result.success && result.data != null) {
        _lastValidData = result.data as T;
        _lastValidationTime = DateTime.now();
        await onValid(_lastValidData as T);
      } else {
        final errors = result.error?.issues ?? [];
        for (final error in errors) {
          _errors.addAll({'${error.path}': error.message});
        }
      }
    } on ZardError catch (e) {
      for (final error in e.issues) {
        _errors.addAll({'${error.path}': error.message});
      }
    } catch (e) {
      _errors.addAll({'form': 'An error occurred: $e'});
    } finally {
      _isSubmitting = false;
      notifyListenersIfMounted();
    }
  }

  Future<bool> handleValid() async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _isValid = false;
    notifyListenersIfMounted();

    try {
      if (_props.resolver == null) {
        throw Exception('No resolver provided');
      }

      if (_lastValidData != null &&
          _lastValidationTime != null &&
          DateTime.now().difference(_lastValidationTime!) <
              _validationCacheTimeout) {
        _isValid = true;

        return true;
      }

      final result = await _props.resolver!(_values);
      _errors.clear();

      if (result.success && result.data != null) {
        _lastValidData = result.data as T;
        _lastValidationTime = DateTime.now();
        _isValid = true;

        return true;
      } else {
        final errors = result.error?.issues ?? [];
        for (final error in errors) {
          _errors.addAll({'${error.path}': error.message});
        }

        return false;
      }
    } on ZardError catch (e) {
      for (final error in e.issues) {
        _errors.addAll({'${error.path}': error.message});
      }

      return false;
    } catch (e) {
      _errors.addAll({'form': 'An error occurred: $e'});

      return false;
    } finally {
      _isSubmitting = false;
      notifyListenersIfMounted();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _errors.clear();
    _values.clear();
    _controllers.clear();
    super.dispose();
  }

  void notifyListenersIfMounted() {
    if (_mounted) {
      notifyListeners();
    }
  }
}
