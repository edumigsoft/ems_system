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
            phone: '(11) 12345-6789',
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
            equals('(11) 12345-6789'),
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
        viewModel.setFieldValue(schoolPhoneByField, '1234-5678');
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
          phone: '(11) 11111-1111',
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
            phone: '(11) 12345-6789',
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
          phone: '(11) 11111-1111',
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
  });
}
