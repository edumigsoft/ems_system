import 'package:flutter_test/flutter_test.dart';
import 'package:school_ui/ui/view_models/school_form_view_model.dart';
import 'package:school_shared/school_shared.dart';
import 'package:core_shared/core_shared.dart';

/// Mock do CreateUseCase para testes
class MockCreateUseCase implements CreateUseCase {
  bool shouldFail = false;
  SchoolDetails? lastExecutedWith;

  @override
  Future<Result<SchoolDetails>> execute(SchoolDetails school) async {
    lastExecutedWith = school;
    await Future<void>.delayed(const Duration(milliseconds: 10));

    if (shouldFail) {
      return Failure(Exception('Erro ao criar escola'));
    }

    return Success(school.copyWith(id: 'generated-id-123'));
  }
}

/// Mock do UpdateUseCase para testes
class MockUpdateUseCase implements UpdateUseCase {
  bool shouldFail = false;
  SchoolDetails? lastExecutedWith;

  @override
  Future<Result<SchoolDetails>> execute(SchoolDetails school) async {
    lastExecutedWith = school;
    await Future<void>.delayed(const Duration(milliseconds: 10));

    if (shouldFail) {
      return Failure(Exception('Erro ao atualizar escola'));
    }

    return Success(school);
  }
}

void main() {
  group('SchoolFormViewModel', () {
    late MockCreateUseCase mockCreateUseCase;
    late MockUpdateUseCase mockUpdateUseCase;

    setUp(() {
      mockCreateUseCase = MockCreateUseCase();
      mockUpdateUseCase = MockUpdateUseCase();
    });

    group('Inicialização', () {
      test('deve inicializar em modo criação quando initialData é null', () {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        expect(viewModel.isEditMode, isFalse);
        expect(viewModel.getFieldValue(schoolNameByField), isEmpty);

        viewModel.dispose();
      });

      test(
        'deve inicializar em modo edição quando initialData é fornecido',
        () {
          final initialSchool = SchoolDetails(
            id: 'school-123',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            name: 'Escola Test',
            email: 'test@escola.com',
            address: 'Rua Test, 123',
            phone: '(11) 91234-5678',
            code: 'CIE123',
            locationCity: 'Test City',
            locationDistrict: 'Test District',
            director: 'Test Director',
            status: SchoolStatus.active,
          );

          final viewModel = SchoolFormViewModel(
            createUseCase: mockCreateUseCase,
            updateUseCase: mockUpdateUseCase,
            initialData: initialSchool,
          );

          expect(viewModel.isEditMode, isTrue);
          expect(
            viewModel.getFieldValue(schoolNameByField),
            equals('Escola Test'),
          );
          expect(
            viewModel.getFieldValue(schoolEmailByField),
            equals('test@escola.com'),
          );
          expect(
            viewModel.getFieldValue(schoolAddressByField),
            equals('Rua Test, 123'),
          );
          expect(
            viewModel.getFieldValue(schoolPhoneByField),
            equals('(11) 91234-5678'),
          );
          expect(viewModel.getFieldValue(schoolCieByField), equals('CIE123'));

          viewModel.dispose();
        },
      );

      test('deve registrar todos os campos necessários', () {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        // Verificar que os controllers existem
        final nameController = viewModel.registerField(schoolNameByField);
        final emailController = viewModel.registerField(schoolEmailByField);
        final addressController = viewModel.registerField(schoolAddressByField);
        final phoneController = viewModel.registerField(schoolPhoneByField);
        final cieController = viewModel.registerField(schoolCieByField);

        expect(nameController, isNotNull);
        expect(emailController, isNotNull);
        expect(addressController, isNotNull);
        expect(phoneController, isNotNull);
        expect(cieController, isNotNull);

        viewModel.dispose();
      });
    });

    group('Submit - Modo Criação', () {
      test('deve criar nova escola com dados válidos', () async {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        // Preencher formulário
        viewModel.setFieldValue(schoolNameByField, 'Nova Escola');
        viewModel.setFieldValue(schoolEmailByField, 'nova@escola.com');
        viewModel.setFieldValue(schoolAddressByField, 'Rua Nova, 456');
        viewModel.setFieldValue(schoolPhoneByField, '(11) 98765-4321');
        viewModel.setFieldValue(schoolCieByField, 'CIE456');

        // Submit
        final result = await viewModel.submit();

        // Verificações
        expect(result, isA<Success<SchoolDetails>>());
        expect(mockCreateUseCase.lastExecutedWith, isNotNull);
        expect(mockCreateUseCase.lastExecutedWith!.name, equals('Nova Escola'));
        expect(
          mockCreateUseCase.lastExecutedWith!.email,
          equals('nova@escola.com'),
        );

        viewModel.dispose();
      });

      test('deve falhar validação com dados inválidos', () async {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        // Preencher formulário com dados inválidos
        viewModel.setFieldValue(schoolNameByField, ''); // Nome vazio (inválido)
        viewModel.setFieldValue(
          schoolEmailByField,
          'email-invalido',
        ); // Email inválido
        viewModel.setFieldValue(schoolAddressByField, 'Rua Test');
        viewModel.setFieldValue(schoolPhoneByField, '1234');
        viewModel.setFieldValue(schoolCieByField, 'CIE');

        // Submit
        final result = await viewModel.submit();

        // Verificações
        expect(result, isA<Failure<SchoolDetails>>());
        expect(viewModel.hasErrors, isTrue);
        expect(
          mockCreateUseCase.lastExecutedWith,
          isNull,
        ); // Não deve chamar UseCase

        viewModel.dispose();
      });

      test('deve retornar erro quando CreateUseCase falha', () async {
        mockCreateUseCase.shouldFail = true;

        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        // Preencher formulário com dados válidos
        viewModel.setFieldValue(schoolNameByField, 'Escola Test');
        viewModel.setFieldValue(schoolEmailByField, 'test@escola.com');
        viewModel.setFieldValue(schoolAddressByField, 'Rua Test, 123');
        viewModel.setFieldValue(schoolPhoneByField, '(11) 12345-6789');
        viewModel.setFieldValue(schoolCieByField, 'CIE123');

        // Submit
        final result = await viewModel.submit();

        // Verificações
        expect(result, isA<Failure<SchoolDetails>>());

        viewModel.dispose();
      });

      test('deve limpar dirty state após criação bem-sucedida', () async {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        // Preencher formulário
        viewModel.setFieldValue(schoolNameByField, 'Escola Test');
        viewModel.setFieldValue(schoolEmailByField, 'test@escola.com');
        viewModel.setFieldValue(schoolAddressByField, 'Rua Test, 123');
        viewModel.setFieldValue(schoolPhoneByField, '(11) 91234-5678');
        viewModel.setFieldValue(schoolCieByField, 'CIE123');

        expect(viewModel.isFormDirty, isTrue);

        // Submit
        await viewModel.submit();

        // Dirty state deve ser limpo
        expect(viewModel.isFormDirty, isFalse);

        viewModel.dispose();
      });
    });

    group('Submit - Modo Edição', () {
      test('deve atualizar escola existente com dados válidos', () async {
        final initialSchool = SchoolDetails(
          id: 'school-123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          name: 'Escola Original',
          email: 'original@escola.com',
          address: 'Rua Original, 123',
          phone: '(11) 91111-1111',
          code: 'CIE111',
          locationCity: 'City',
          locationDistrict: 'District',
          director: 'Director',
          status: SchoolStatus.active,
        );

        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
          initialData: initialSchool,
        );

        // Modificar alguns campos
        viewModel.setFieldValue(schoolNameByField, 'Escola Modificada');
        viewModel.setFieldValue(schoolEmailByField, 'modificada@escola.com');

        // Submit
        final result = await viewModel.submit();

        // Verificações
        expect(result, isA<Success<SchoolDetails>>());
        expect(mockUpdateUseCase.lastExecutedWith, isNotNull);
        expect(mockUpdateUseCase.lastExecutedWith!.id, equals('school-123'));
        expect(
          mockUpdateUseCase.lastExecutedWith!.name,
          equals('Escola Modificada'),
        );
        expect(
          mockUpdateUseCase.lastExecutedWith!.email,
          equals('modificada@escola.com'),
        );

        // Deve preservar campos não editados
        expect(
          mockUpdateUseCase.lastExecutedWith!.locationCity,
          equals('City'),
        );

        viewModel.dispose();
      });

      test(
        'deve chamar UpdateUseCase ao invés de CreateUseCase em modo edição',
        () async {
          final initialSchool = SchoolDetails(
            id: 'school-123',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            name: 'Escola Test',
            email: 'test@escola.com',
            address: 'Rua Test, 123',
            phone: '(11) 91234-5678',
            code: 'CIE123',
            locationCity: 'City',
            locationDistrict: 'District',
            director: 'Director',
            status: SchoolStatus.active,
          );

          final viewModel = SchoolFormViewModel(
            createUseCase: mockCreateUseCase,
            updateUseCase: mockUpdateUseCase,
            initialData: initialSchool,
          );

          // Submit
          await viewModel.submit();

          // Verificações
          expect(mockUpdateUseCase.lastExecutedWith, isNotNull);
          expect(
            mockCreateUseCase.lastExecutedWith,
            isNull,
          ); // Não deve chamar CreateUseCase

          viewModel.dispose();
        },
      );
    });

    group('Reset', () {
      test('deve limpar campos em modo criação', () {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        // Preencher formulário
        viewModel.setFieldValue(schoolNameByField, 'Escola Test');
        viewModel.setFieldValue(schoolEmailByField, 'test@escola.com');

        expect(viewModel.getFieldValue(schoolNameByField), isNotEmpty);

        // Reset
        viewModel.reset();

        // Campos devem estar vazios
        expect(viewModel.getFieldValue(schoolNameByField), isEmpty);
        expect(viewModel.getFieldValue(schoolEmailByField), isEmpty);
        expect(viewModel.isFormDirty, isFalse);

        viewModel.dispose();
      });

      test('deve restaurar valores iniciais em modo edição', () {
        final initialSchool = SchoolDetails(
          id: 'school-123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          name: 'Escola Original',
          email: 'original@escola.com',
          address: 'Rua Original, 123',
          phone: '(11) 91111-1111',
          code: 'CIE111',
          locationCity: 'City',
          locationDistrict: 'District',
          director: 'Director',
          status: SchoolStatus.active,
        );

        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
          initialData: initialSchool,
        );

        // Modificar campos
        viewModel.setFieldValue(schoolNameByField, 'Nome Modificado');
        viewModel.setFieldValue(schoolEmailByField, 'modificado@escola.com');

        expect(
          viewModel.getFieldValue(schoolNameByField),
          equals('Nome Modificado'),
        );

        // Reset
        viewModel.reset();

        // Deve voltar aos valores originais
        expect(
          viewModel.getFieldValue(schoolNameByField),
          equals('Escola Original'),
        );
        expect(
          viewModel.getFieldValue(schoolEmailByField),
          equals('original@escola.com'),
        );
        expect(viewModel.isFormDirty, isFalse);

        viewModel.dispose();
      });
    });

    group('Dispose', () {
      test('deve liberar recursos ao fazer dispose', () {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        final controller = viewModel.registerField(schoolNameByField);

        // Dispose
        viewModel.dispose();

        // Controllers não devem mais funcionar
        expect(() => controller.text = 'test', throwsFlutterError);
      });
    });

    group('Edge Cases', () {
      test('deve aceitar telefone com todos os dígitos iguais', () async {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        // Preencher com telefone de dígitos repetidos (edge case válido)
        viewModel.setFieldValue(schoolNameByField, 'Escola Test');
        viewModel.setFieldValue(schoolEmailByField, 'test@escola.com');
        viewModel.setFieldValue(schoolAddressByField, 'Rua Test');
        viewModel.setFieldValue(schoolPhoneByField, '(11) 91111-1111');
        viewModel.setFieldValue(schoolCieByField, 'CIE123');

        final result = await viewModel.submit();

        expect(result, isA<Success<SchoolDetails>>());

        viewModel.dispose();
      });

      test('deve rejeitar telefone com DDD inválido (00)', () async {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        viewModel.setFieldValue(schoolNameByField, 'Escola Test');
        viewModel.setFieldValue(schoolEmailByField, 'test@escola.com');
        viewModel.setFieldValue(schoolAddressByField, 'Rua Test');
        viewModel.setFieldValue(schoolPhoneByField, '(00) 91234-5678');
        viewModel.setFieldValue(schoolCieByField, 'CIE123');

        final result = await viewModel.submit();

        // DDD 00 é inválido (regex exige [1-9])
        expect(result, isA<Failure<SchoolDetails>>());

        viewModel.dispose();
      });

      test('deve aceitar email com caracteres especiais válidos', () async {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        viewModel.setFieldValue(schoolNameByField, 'Escola Test');
        viewModel.setFieldValue(
          schoolEmailByField,
          'user+tag@sub.domain.com.br',
        );
        viewModel.setFieldValue(schoolAddressByField, 'Rua Test');
        viewModel.setFieldValue(schoolPhoneByField, '(11) 91234-5678');
        viewModel.setFieldValue(schoolCieByField, 'CIE123');

        final result = await viewModel.submit();

        expect(result, isA<Success<SchoolDetails>>());

        viewModel.dispose();
      });

      test('deve lidar com nome contendo caracteres unicode', () async {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        // Nome com acentos, cedilha e caracteres especiais
        viewModel.setFieldValue(
          schoolNameByField,
          'Escola São José - Educação & Cultura',
        );
        viewModel.setFieldValue(schoolEmailByField, 'contato@escola.com');
        viewModel.setFieldValue(schoolAddressByField, 'Rua Test');
        viewModel.setFieldValue(schoolPhoneByField, '(11) 91234-5678');
        viewModel.setFieldValue(schoolCieByField, 'CIE123');

        final result = await viewModel.submit();

        expect(result, isA<Success<SchoolDetails>>());
        final success = result as Success<SchoolDetails>;
        expect(
          success.value.name,
          equals('Escola São José - Educação & Cultura'),
        );

        viewModel.dispose();
      });

      test('deve lidar com múltiplos submits sequenciais', () async {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        // Preencher dados válidos
        viewModel.setFieldValue(schoolNameByField, 'Escola Test');
        viewModel.setFieldValue(schoolEmailByField, 'test@escola.com');
        viewModel.setFieldValue(schoolAddressByField, 'Rua Test');
        viewModel.setFieldValue(schoolPhoneByField, '(11) 91234-5678');
        viewModel.setFieldValue(schoolCieByField, 'CIE123');

        // Submeter múltiplas vezes
        final result1 = await viewModel.submit();
        final result2 = await viewModel.submit();
        final result3 = await viewModel.submit();

        // Todos devem ter sucesso
        expect(result1, isA<Success<SchoolDetails>>());
        expect(result2, isA<Success<SchoolDetails>>());
        expect(result3, isA<Success<SchoolDetails>>());

        viewModel.dispose();
      });

      test('deve falhar ao usar controller após dispose', () {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        final controller = viewModel.registerField(schoolNameByField);
        viewModel.dispose();

        // Controllers não devem funcionar após dispose
        expect(() => controller.text = 'test', throwsFlutterError);
      });

      test('deve lidar com telefone no limite mínimo de caracteres', () async {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        viewModel.setFieldValue(schoolNameByField, 'Escola Test');
        viewModel.setFieldValue(schoolEmailByField, 'test@escola.com');
        viewModel.setFieldValue(schoolAddressByField, 'Rua Test');
        // Telefone fixo com 8 dígitos (formato mínimo válido)
        viewModel.setFieldValue(schoolPhoneByField, '(11) 1234-5678');
        viewModel.setFieldValue(schoolCieByField, 'CIE123');

        final result = await viewModel.submit();

        expect(result, isA<Success<SchoolDetails>>());

        viewModel.dispose();
      });

      test('deve rejeitar telefone muito curto', () async {
        final viewModel = SchoolFormViewModel(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        );

        viewModel.setFieldValue(schoolNameByField, 'Escola Test');
        viewModel.setFieldValue(schoolEmailByField, 'test@escola.com');
        viewModel.setFieldValue(schoolAddressByField, 'Rua Test');
        viewModel.setFieldValue(schoolPhoneByField, '123');
        viewModel.setFieldValue(schoolCieByField, 'CIE123');

        final result = await viewModel.submit();

        expect(result, isA<Failure<SchoolDetails>>());

        viewModel.dispose();
      });
    });
  });
}
