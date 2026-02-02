import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core_ui/core_ui.dart';
import 'package:zard/zard.dart';

/// ViewModel de teste que usa FormValidationMixin
class TestFormViewModel extends ChangeNotifier with FormValidationMixin {
  TestFormViewModel() {
    registerField('email');
    registerField('password');
    registerField('name', initialValue: 'John Doe');
  }

  Future<Result<Map<String, dynamic>>> submit(ZMap schema) {
    final data = {
      'email': getFieldValue('email'),
      'password': getFieldValue('password'),
      'name': getFieldValue('name'),
    };

    return submitForm<Map<String, dynamic>>(
      data: data,
      schema: schema,
      onValid: (validatedData) async {
        // Simula operação assíncrona bem-sucedida
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return Success(validatedData);
      },
    );
  }

  @override
  void dispose() {
    disposeFormResources();
    super.dispose();
  }
}

void main() {
  group('FormValidationMixin', () {
    late TestFormViewModel viewModel;

    setUp(() {
      viewModel = TestFormViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    group('Registro de Campos', () {
      test('deve registrar campos e retornar controllers', () {
        final emailController = viewModel.registerField('email');
        final passwordController = viewModel.registerField('password');

        expect(emailController, isA<TextEditingController>());
        expect(passwordController, isA<TextEditingController>());
      });

      test('deve retornar o mesmo controller se campo já foi registrado', () {
        final controller1 = viewModel.registerField('email');
        final controller2 = viewModel.registerField('email');

        expect(controller1, same(controller2));
      });

      test('deve aceitar valor inicial ao registrar campo', () {
        final nameController = viewModel.registerField('name');
        expect(nameController.text, equals('John Doe'));
      });

      test(
        'deve retornar controller existente ao registrar novamente campo com valor inicial',
        () {
          final controller1 = viewModel.registerField(
            'name',
            initialValue: 'Jane',
          );
          final controller2 = viewModel.registerField('name');

          expect(controller1, same(controller2));
          // Valor inicial não deve mudar ao registrar novamente
          expect(controller2.text, equals('John Doe'));
        },
      );
    });

    group('Getters e Setters de Valores', () {
      test('getFieldValue deve retornar valor do campo', () {
        viewModel.setFieldValue('email', 'test@example.com');
        expect(viewModel.getFieldValue('email'), equals('test@example.com'));
      });

      test('setFieldValue deve atualizar controller', () {
        viewModel.setFieldValue('password', 'secret123');
        final controller = viewModel.registerField('password');
        expect(controller.text, equals('secret123'));
      });

      test('setFieldValue deve marcar campo como dirty', () {
        expect(viewModel.isFormDirty, isFalse);
        viewModel.setFieldValue('email', 'new@example.com');
        expect(viewModel.isFormDirty, isTrue);
        expect(viewModel.isFieldDirty('email'), isTrue);
      });
    });

    group('Gerenciamento de Erros', () {
      test('getFieldError deve retornar null se campo não tem erro', () {
        expect(viewModel.getFieldError('email'), isNull);
      });

      test('setFieldError deve definir erro do campo', () {
        viewModel.setFieldError('email', 'Email inválido');
        expect(viewModel.getFieldError('email'), equals('Email inválido'));
      });

      test('hasErrors deve retornar true quando há erros', () {
        expect(viewModel.hasErrors, isFalse);
        viewModel.setFieldError('email', 'Erro');
        expect(viewModel.hasErrors, isTrue);
      });

      test('isFormValid deve retornar false quando há erros', () {
        expect(viewModel.isFormValid, isTrue);
        viewModel.setFieldError('password', 'Senha muito curta');
        expect(viewModel.isFormValid, isFalse);
      });

      test(
        'clearErrors deve limpar todos os erros se nenhum campo especificado',
        () {
          viewModel.setFieldError('email', 'Erro 1');
          viewModel.setFieldError('password', 'Erro 2');

          viewModel.clearErrors();

          expect(viewModel.getFieldError('email'), isNull);
          expect(viewModel.getFieldError('password'), isNull);
          expect(viewModel.hasErrors, isFalse);
        },
      );

      test('clearErrors deve limpar erro de campo específico', () {
        viewModel.setFieldError('email', 'Erro email');
        viewModel.setFieldError('password', 'Erro senha');

        viewModel.clearErrors('email');

        expect(viewModel.getFieldError('email'), isNull);
        expect(viewModel.getFieldError('password'), equals('Erro senha'));
      });

      test('formErrors deve retornar mapa imutável de erros', () {
        viewModel.setFieldError('email', 'Erro');
        final errors = viewModel.formErrors;

        expect(errors, isA<Map<String, String?>>());
        expect(errors['email'], equals('Erro'));
        expect(() => errors['password'] = 'Novo erro', throwsUnsupportedError);
      });
    });

    group('Estado Dirty e Touched', () {
      test('isFieldDirty deve retornar false para campo não modificado', () {
        expect(viewModel.isFieldDirty('email'), isFalse);
      });

      test('isFieldDirty deve retornar true após modificação', () {
        viewModel.setFieldValue('email', 'test@example.com');
        expect(viewModel.isFieldDirty('email'), isTrue);
      });

      test(
        'isFormDirty deve retornar false quando nenhum campo foi modificado',
        () {
          expect(viewModel.isFormDirty, isFalse);
        },
      );

      test(
        'isFormDirty deve retornar true quando algum campo foi modificado',
        () {
          viewModel.setFieldValue('name', 'Jane Doe');
          expect(viewModel.isFormDirty, isTrue);
        },
      );

      test('isFieldTouched deve retornar false para campo não tocado', () {
        expect(viewModel.isFieldTouched('email'), isFalse);
      });

      test('setFieldTouched deve marcar campo como tocado', () {
        viewModel.setFieldTouched('email');
        expect(viewModel.isFieldTouched('email'), isTrue);
      });
    });

    group('Validação de Formulários', () {
      final testSchema = z.map({
        'email': z.string().email(message: 'Email inválido'),
        'password': z.string().min(
          6,
          message: 'Senha deve ter no mínimo 6 caracteres',
        ),
        'name': z.string().min(
          3,
          message: 'Nome deve ter no mínimo 3 caracteres',
        ),
      });

      test('validateForm deve retornar Success quando dados são válidos', () {
        final result = viewModel.validateForm(
          data: {
            'email': 'test@example.com',
            'password': '123456',
            'name': 'John',
          },
          schema: testSchema,
        );

        expect(result, isA<Success<Map<String, dynamic>>>());
        if (result case Success(:final value)) {
          expect(value['email'], equals('test@example.com'));
        }
      });

      test('validateForm deve retornar Failure quando dados são inválidos', () {
        final result = viewModel.validateForm(
          data: {
            'email': 'invalid-email',
            'password': '123',
            'name': 'Jo',
          },
          schema: testSchema,
        );

        expect(result, isA<Failure<Map<String, dynamic>>>());
      });

      test(
        'validateForm deve definir erros nos campos quando validação falha',
        () {
          viewModel.validateForm(
            data: {
              'email': 'invalid',
              'password': '123',
              'name': 'John',
            },
            schema: testSchema,
          );

          expect(viewModel.getFieldError('email'), isNotNull);
          expect(viewModel.getFieldError('password'), isNotNull);
        },
      );

      test(
        'validateForm deve limpar erros quando validação é bem-sucedida',
        () {
          // Primeiro, criar erros
          viewModel.setFieldError('email', 'Erro antigo');
          viewModel.setFieldError('password', 'Erro antigo');

          // Validar com dados corretos
          viewModel.validateForm(
            data: {
              'email': 'test@example.com',
              'password': '123456',
              'name': 'John',
            },
            schema: testSchema,
          );

          expect(viewModel.hasErrors, isFalse);
        },
      );
    });

    group('Submit de Formulários', () {
      final testSchema = z.map({
        'email': z.string().email(message: 'Email inválido'),
        'password': z.string().min(6, message: 'Senha mínimo 6 caracteres'),
        'name': z.string().min(3, message: 'Nome mínimo 3 caracteres'),
      });

      test('submitForm deve validar antes de executar onValid', () async {
        viewModel.setFieldValue('email', 'invalid-email');
        viewModel.setFieldValue('password', '123');

        final result = await viewModel.submit(testSchema);

        expect(result, isA<Failure<void>>());
        expect(viewModel.hasErrors, isTrue);
      });

      test(
        'submitForm deve executar onValid quando dados são válidos',
        () async {
          viewModel.setFieldValue('email', 'test@example.com');
          viewModel.setFieldValue('password', '123456');
          viewModel.setFieldValue('name', 'John');

          final result = await viewModel.submit(testSchema);

          expect(result, isA<Success<void>>());
          if (result case Success(:final value)) {
            expect(value['email'], equals('test@example.com'));
          }
        },
      );

      test('submitForm deve gerenciar estado isSubmitting', () async {
        viewModel.setFieldValue('email', 'test@example.com');
        viewModel.setFieldValue('password', '123456');

        expect(viewModel.isSubmitting, isFalse);

        final future = viewModel.submit(testSchema);

        // Durante o submit (não podemos verificar async facilmente)
        await future;

        // Após submit
        expect(viewModel.isSubmitting, isFalse);
      });

      test('submitForm deve limpar dirty state em sucesso', () async {
        viewModel.setFieldValue('email', 'test@example.com');
        viewModel.setFieldValue('password', '123456');
        viewModel.setFieldValue('name', 'John');

        expect(viewModel.isFormDirty, isTrue);

        await viewModel.submit(testSchema);

        expect(viewModel.isFormDirty, isFalse);
      });

      test('submitForm deve manter dirty state em falha', () async {
        viewModel.setFieldValue('email', 'invalid');
        viewModel.setFieldValue('password', '123');

        expect(viewModel.isFormDirty, isTrue);

        await viewModel.submit(testSchema);

        expect(viewModel.isFormDirty, isTrue);
      });
    });

    group('Reset de Formulários', () {
      test(
        'resetForm deve limpar todos os campos quando sem valores iniciais',
        () {
          viewModel.setFieldValue('email', 'test@example.com');
          viewModel.setFieldValue('password', '123456');

          viewModel.resetForm();

          expect(viewModel.getFieldValue('email'), isEmpty);
          expect(viewModel.getFieldValue('password'), isEmpty);
        },
      );

      test('resetForm deve definir valores iniciais fornecidos', () {
        viewModel.resetForm({
          'email': 'new@example.com',
          'password': 'newpass',
        });

        expect(viewModel.getFieldValue('email'), equals('new@example.com'));
        expect(viewModel.getFieldValue('password'), equals('newpass'));
      });

      test('resetForm deve limpar erros', () {
        viewModel.setFieldError('email', 'Erro');
        viewModel.setFieldError('password', 'Erro');

        viewModel.resetForm();

        expect(viewModel.hasErrors, isFalse);
      });

      test('resetForm deve limpar dirty state', () {
        viewModel.setFieldValue('email', 'test@example.com');
        expect(viewModel.isFormDirty, isTrue);

        viewModel.resetForm();

        expect(viewModel.isFormDirty, isFalse);
      });

      test('resetForm deve limpar touched state', () {
        viewModel.setFieldTouched('email');
        expect(viewModel.isFieldTouched('email'), isTrue);

        viewModel.resetForm();

        expect(viewModel.isFieldTouched('email'), isFalse);
      });
    });

    group('Dispose de Recursos', () {
      test('disposeFormResources deve liberar controllers', () {
        final controller = viewModel.registerField('email');

        viewModel.disposeFormResources();

        // Após dispose, controllers não devem mais funcionar
        expect(() => controller.text = 'test', throwsFlutterError);
      });
    });

    group('Notificações de Mudanças', () {
      test('setFieldValue deve notificar listeners', () {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.setFieldValue('email', 'test@example.com');

        expect(notified, isTrue);
      });

      test('setFieldError deve notificar listeners', () {
        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.setFieldError('email', 'Erro');

        expect(notified, isTrue);
      });

      test('clearErrors deve notificar listeners', () {
        viewModel.setFieldError('email', 'Erro');

        var notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.clearErrors();

        expect(notified, isTrue);
      });
    });
  });
}
