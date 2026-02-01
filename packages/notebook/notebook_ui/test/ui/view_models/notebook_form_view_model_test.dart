import 'package:flutter_test/flutter_test.dart';
import 'package:notebook_ui/ui/view_models/notebook_form_view_model.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:core_shared/core_shared.dart';

void main() {
  group('NotebookFormViewModel', () {
    group('Inicialização', () {
      test('deve inicializar em modo criação quando initialData é null', () {
        final viewModel = NotebookFormViewModel();

        expect(viewModel.isEditing, isFalse);
        expect(viewModel.getFieldValue(notebookTitleField), isEmpty);
        expect(viewModel.selectedType, equals(NotebookType.organized));

        viewModel.dispose();
      });

      test(
        'deve inicializar em modo edição quando initialData é fornecido',
        () {
          final initialNotebook = NotebookDetails.create(
            id: 'notebook-123',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            title: 'Notebook Test',
            content: 'Test content',
            type: NotebookType.quick,
            tags: ['tag1', 'tag2'],
          );

          final viewModel = NotebookFormViewModel(
            initialData: initialNotebook,
          );

          expect(viewModel.isEditing, isTrue);
          expect(
            viewModel.getFieldValue(notebookTitleField),
            equals('Notebook Test'),
          );
          expect(
            viewModel.getFieldValue(notebookContentField),
            equals('Test content'),
          );
          expect(
            viewModel.getFieldValue(notebookTagsField),
            equals('tag1, tag2'),
          );
          expect(viewModel.selectedType, equals(NotebookType.quick));

          viewModel.dispose();
        },
      );

      test('deve registrar todos os campos necessários', () {
        final viewModel = NotebookFormViewModel();

        // Verificar que os controllers existem
        final titleController = viewModel.registerField(notebookTitleField);
        final contentController = viewModel.registerField(notebookContentField);
        final tagsController = viewModel.registerField(notebookTagsField);

        expect(titleController, isNotNull);
        expect(contentController, isNotNull);
        expect(tagsController, isNotNull);

        viewModel.dispose();
      });
    });

    group('Validação', () {
      test('deve validar com sucesso dados válidos', () async {
        final viewModel = NotebookFormViewModel();

        // Preencher formulário com dados válidos
        viewModel.setFieldValue(notebookTitleField, 'Novo Notebook');
        viewModel.setFieldValue(notebookContentField, 'Conteúdo do notebook');
        viewModel.setFieldValue(notebookTagsField, 'tag1, tag2');

        // Validar
        final result = await viewModel.validateAndGetData();

        // Verificações
        expect(result, isA<Success<Map<String, dynamic>>>());
        expect(viewModel.hasErrors, isFalse);

        viewModel.dispose();
      });

      test('deve falhar validação com dados inválidos', () async {
        final viewModel = NotebookFormViewModel();

        // Preencher formulário com título vazio (inválido)
        viewModel.setFieldValue(notebookTitleField, '');
        viewModel.setFieldValue(notebookContentField, 'Conteúdo');
        viewModel.setFieldValue(notebookTagsField, 'tag1');

        // Validar
        final result = await viewModel.validateAndGetData();

        // Verificações
        expect(result, isA<Failure<Map<String, dynamic>>>());
        expect(viewModel.hasErrors, isTrue);

        viewModel.dispose();
      });

    });

    group('Criar NotebookCreate', () {
      test('deve criar NotebookCreate com dados válidos', () {
        final viewModel = NotebookFormViewModel();

        // Preencher formulário
        viewModel.setFieldValue(notebookTitleField, 'Novo Notebook');
        viewModel.setFieldValue(notebookContentField, 'Conteúdo');
        viewModel.setFieldValue(notebookTagsField, 'tag1, tag2, tag3');
        viewModel.selectedType = NotebookType.reminder;

        // Criar objeto
        final notebookCreate = viewModel.createNotebookCreate();

        // Verificações
        expect(notebookCreate.title, equals('Novo Notebook'));
        expect(notebookCreate.content, equals('Conteúdo'));
        expect(notebookCreate.type, equals(NotebookType.reminder));
        expect(notebookCreate.tags, equals(['tag1', 'tag2', 'tag3']));

        viewModel.dispose();
      });

      test('deve criar NotebookCreate sem tags quando campo está vazio', () {
        final viewModel = NotebookFormViewModel();

        viewModel.setFieldValue(notebookTitleField, 'Notebook');
        viewModel.setFieldValue(notebookContentField, 'Conteúdo');
        viewModel.setFieldValue(notebookTagsField, '');

        final notebookCreate = viewModel.createNotebookCreate();

        expect(notebookCreate.tags, isNull);

        viewModel.dispose();
      });

      test('deve fazer trim em espaços extras nas tags', () {
        final viewModel = NotebookFormViewModel();

        viewModel.setFieldValue(notebookTitleField, 'Notebook');
        viewModel.setFieldValue(notebookContentField, 'Conteúdo');
        viewModel.setFieldValue(notebookTagsField, '  tag1  ,  tag2  , tag3  ');

        final notebookCreate = viewModel.createNotebookCreate();

        expect(notebookCreate.tags, equals(['tag1', 'tag2', 'tag3']));

        viewModel.dispose();
      });
    });

    group('Criar NotebookUpdate', () {
      test('deve criar NotebookUpdate com dados válidos em modo edição', () {
        final initialNotebook = NotebookDetails.create(
          id: 'notebook-123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          title: 'Original',
          content: 'Original Content',
          type: NotebookType.organized,
        );

        final viewModel = NotebookFormViewModel(
          initialData: initialNotebook,
        );

        // Modificar campos
        viewModel.setFieldValue(notebookTitleField, 'Modificado');
        viewModel.setFieldValue(notebookContentField, 'Conteúdo Modificado');
        viewModel.selectedType = NotebookType.quick;

        // Criar objeto
        final notebookUpdate = viewModel.createNotebookUpdate();

        // Verificações
        expect(notebookUpdate.id, equals('notebook-123'));
        expect(notebookUpdate.title, equals('Modificado'));
        expect(notebookUpdate.content, equals('Conteúdo Modificado'));
        expect(notebookUpdate.type, equals(NotebookType.quick));

        viewModel.dispose();
      });

      test('deve lançar erro ao criar NotebookUpdate em modo criação', () {
        final viewModel = NotebookFormViewModel();

        // Tentar criar NotebookUpdate sem initialData
        expect(
          () => viewModel.createNotebookUpdate(),
          throwsA(isA<StateError>()),
        );

        viewModel.dispose();
      });
    });

    group('Reset', () {
      test('deve limpar campos em modo criação', () {
        final viewModel = NotebookFormViewModel();

        // Preencher formulário
        viewModel.setFieldValue(notebookTitleField, 'Notebook Test');
        viewModel.setFieldValue(notebookContentField, 'Conteúdo');
        viewModel.selectedType = NotebookType.reminder;

        expect(viewModel.getFieldValue(notebookTitleField), isNotEmpty);

        // Reset
        viewModel.reset();

        // Campos devem estar vazios
        expect(viewModel.getFieldValue(notebookTitleField), isEmpty);
        expect(viewModel.getFieldValue(notebookContentField), isEmpty);
        expect(viewModel.getFieldValue(notebookTagsField), isEmpty);
        expect(viewModel.selectedType, equals(NotebookType.organized));
        expect(viewModel.isFormDirty, isFalse);

        viewModel.dispose();
      });

      test('deve restaurar valores iniciais em modo edição', () {
        final initialNotebook = NotebookDetails.create(
          id: 'notebook-123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          title: 'Original',
          content: 'Original Content',
          type: NotebookType.quick,
          tags: ['tag1'],
        );

        final viewModel = NotebookFormViewModel(
          initialData: initialNotebook,
        );

        // Modificar campos
        viewModel.setFieldValue(notebookTitleField, 'Modificado');
        viewModel.setFieldValue(notebookContentField, 'Conteúdo Modificado');
        viewModel.selectedType = NotebookType.reminder;

        expect(viewModel.getFieldValue(notebookTitleField), equals('Modificado'));

        // Reset
        viewModel.reset();

        // Deve voltar aos valores originais
        expect(viewModel.getFieldValue(notebookTitleField), equals('Original'));
        expect(
          viewModel.getFieldValue(notebookContentField),
          equals('Original Content'),
        );
        expect(viewModel.getFieldValue(notebookTagsField), equals('tag1'));
        expect(viewModel.selectedType, equals(NotebookType.quick));
        expect(viewModel.isFormDirty, isFalse);

        viewModel.dispose();
      });
    });

    group('Dispose', () {
      test('deve liberar recursos ao fazer dispose', () {
        final viewModel = NotebookFormViewModel();

        final controller = viewModel.registerField(notebookTitleField);

        // Dispose
        viewModel.dispose();

        // Controllers não devem mais funcionar
        expect(() => controller.text = 'test', throwsFlutterError);
      });
    });

    group('Gerenciamento de Tipo', () {
      test('deve notificar listeners ao mudar tipo', () {
        final viewModel = NotebookFormViewModel();

        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        // Mudar tipo
        viewModel.selectedType = NotebookType.reminder;

        expect(notificationCount, equals(1));
        expect(viewModel.selectedType, equals(NotebookType.reminder));

        viewModel.dispose();
      });

      test('não deve notificar ao definir o mesmo tipo', () {
        final viewModel = NotebookFormViewModel();

        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        // Definir o mesmo tipo
        viewModel.selectedType = NotebookType.organized;

        expect(notificationCount, equals(0));

        viewModel.dispose();
      });
    });
  });
}
