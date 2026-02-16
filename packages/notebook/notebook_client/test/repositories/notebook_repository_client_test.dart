import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:notebook_client/notebook_client.dart';
import 'package:notebook_shared/notebook_shared.dart';
import 'package:core_shared/core_shared.dart';

import 'notebook_repository_client_test.mocks.dart';

// Generate mocks: dart run build_runner build
@GenerateMocks([NotebookApiService])
void main() {
  group('NotebookRepositoryClient', () {
    late MockNotebookApiService mockApiService;
    late NotebookRepositoryClient repository;

    setUp(() {
      mockApiService = MockNotebookApiService();
      repository = NotebookRepositoryClient(mockApiService);
    });

    group('create', () {
      test('should return Success when API call succeeds', () async {
        // Arrange
        final createDto = NotebookCreate(
          title: 'New Notebook',
          content: 'Content',
        );
        final responseModel = NotebookDetailsModel.fromJson({
          'id': 'notebook-123',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'title': 'New Notebook',
          'content': 'Content',
        });

        when(mockApiService.create(any)).thenAnswer((_) async => responseModel);

        // Act
        final result = await repository.create(createDto);

        // Assert
        expect(result, isA<Success<NotebookDetails>>());
        final success = result as Success<NotebookDetails>;
        expect(success.value.title, 'New Notebook');
        verify(mockApiService.create(any)).called(1);
      });

      test(
        'should return Failure when API throws DioException with 400',
        () async {
          // Arrange
          final createDto = NotebookCreate(
            title: 'Invalid',
            content: 'Content',
          );

          when(mockApiService.create(any)).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/notebooks'),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: '/notebooks'),
                statusCode: 400,
                data: {'message': 'Invalid data'},
              ),
            ),
          );

          // Act
          final result = await repository.create(createDto);

          // Assert
          expect(result, isA<Failure<NotebookDetails>>());
          final failure = result as Failure<NotebookDetails>;
          expect(failure.error.toString(), contains('Requisição inválida'));
        },
      );

      test(
        'should return Failure when API throws DioException with 500',
        () async {
          // Arrange
          final createDto = NotebookCreate(
            title: 'Test',
            content: 'Content',
          );

          when(mockApiService.create(any)).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/notebooks'),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: '/notebooks'),
                statusCode: 500,
              ),
            ),
          );

          // Act
          final result = await repository.create(createDto);

          // Assert
          expect(result, isA<Failure<NotebookDetails>>());
          final failure = result as Failure<NotebookDetails>;
          expect(failure.error.toString(), contains('Erro interno do servidor'));
        },
      );

      test(
        'should return Failure when API throws connection timeout',
        () async {
          // Arrange
          final createDto = NotebookCreate(
            title: 'Test',
            content: 'Content',
          );

          when(mockApiService.create(any)).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/notebooks'),
              type: DioExceptionType.connectionTimeout,
            ),
          );

          // Act
          final result = await repository.create(createDto);

          // Assert
          expect(result, isA<Failure<NotebookDetails>>());
          final failure = result as Failure<NotebookDetails>;
          expect(
            failure.error.toString(),
            contains('Tempo de conexão esgotado'),
          );
        },
      );
    });

    group('getById', () {
      test('should return Success when notebook is found', () async {
        // Arrange
        const notebookId = 'notebook-456';
        final responseModel = NotebookDetailsModel.fromJson({
          'id': notebookId,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'title': 'Found Notebook',
          'content': 'Content',
        });

        when(
          mockApiService.getById(notebookId),
        ).thenAnswer((_) async => responseModel);

        // Act
        final result = await repository.getById(notebookId);

        // Assert
        expect(result, isA<Success<NotebookDetails>>());
        final success = result as Success<NotebookDetails>;
        expect(success.value.id, notebookId);
      });

      test('should return Failure when notebook not found (404)', () async {
        // Arrange
        const notebookId = 'not-found';

        when(mockApiService.getById(notebookId)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notebooks/$notebookId'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/notebooks/$notebookId'),
              statusCode: 404,
            ),
          ),
        );

        // Act
        final result = await repository.getById(notebookId);

        // Assert
        expect(result, isA<Failure<NotebookDetails>>());
        final failure = result as Failure<NotebookDetails>;
        expect(failure.error.toString(), contains('não encontrado'));
      });
    });

    group('getAll', () {
      test('should return Success with list of notebooks', () async {
        // Arrange
        final responseModels = [
          NotebookDetailsModel.fromJson({
            'id': '1',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'title': 'Notebook 1',
            'content': 'Content 1',
          }),
          NotebookDetailsModel.fromJson({
            'id': '2',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'title': 'Notebook 2',
            'content': 'Content 2',
          }),
        ];

        when(
          mockApiService.getAll(
            activeOnly: anyNamed('activeOnly'),
            search: anyNamed('search'),
            projectId: anyNamed('projectId'),
            parentId: anyNamed('parentId'),
            type: anyNamed('type'),
            tags: anyNamed('tags'),
            overdueOnly: anyNamed('overdueOnly'),
          ),
        ).thenAnswer((_) async => responseModels);

        // Act
        final result = await repository.getAll();

        // Assert
        expect(result, isA<Success<List<NotebookDetails>>>());
        final success = result as Success<List<NotebookDetails>>;
        expect(success.value.length, 2);
        expect(success.value[0].title, 'Notebook 1');
      });

      test('should correctly pass filters to API service', () async {
        // Arrange
        when(
          mockApiService.getAll(
            activeOnly: anyNamed('activeOnly'),
            search: anyNamed('search'),
            projectId: anyNamed('projectId'),
            parentId: anyNamed('parentId'),
            type: anyNamed('type'),
            tags: anyNamed('tags'),
            overdueOnly: anyNamed('overdueOnly'),
          ),
        ).thenAnswer((_) async => []);

        // Act
        await repository.getAll(
          activeOnly: false,
          search: 'test',
          projectId: 'proj-1',
          type: NotebookType.quick,
          tags: ['tag1', 'tag2'],
          overdueOnly: true,
        );

        // Assert
        verify(
          mockApiService.getAll(
            activeOnly: false,
            search: 'test',
            projectId: 'proj-1',
            type: 'quick',
            tags: 'tag1,tag2',
            overdueOnly: true,
          ),
        ).called(1);
      });

      test('should return Failure when API call fails', () async {
        // Arrange
        when(
          mockApiService.getAll(
            activeOnly: anyNamed('activeOnly'),
            search: anyNamed('search'),
            projectId: anyNamed('projectId'),
            parentId: anyNamed('parentId'),
            type: anyNamed('type'),
            tags: anyNamed('tags'),
            overdueOnly: anyNamed('overdueOnly'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notebooks'),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act
        final result = await repository.getAll();

        // Assert
        expect(result, isA<Failure<List<NotebookDetails>>>());
        final failure = result as Failure<List<NotebookDetails>>;
        expect(failure.error.toString(), contains('Sem conexão com a internet'));
      });
    });

    group('update', () {
      test('should return Success when update succeeds', () async {
        // Arrange
        final updateDto = NotebookUpdate(
          id: 'notebook-789',
          title: 'Updated Title',
        );
        final responseModel = NotebookDetailsModel.fromJson({
          'id': 'notebook-789',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'title': 'Updated Title',
          'content': 'Original Content',
        });

        when(
          mockApiService.update(any, any),
        ).thenAnswer((_) async => responseModel);

        // Act
        final result = await repository.update(updateDto);

        // Assert
        expect(result, isA<Success<NotebookDetails>>());
        final success = result as Success<NotebookDetails>;
        expect(success.value.title, 'Updated Title');
        verify(mockApiService.update('notebook-789', any)).called(1);
      });

      test('should return Failure on conflict (409)', () async {
        // Arrange
        final updateDto = NotebookUpdate(
          id: 'notebook-conflict',
          title: 'New Title',
        );

        when(mockApiService.update(any, any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '/notebooks/notebook-conflict',
            ),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(
                path: '/notebooks/notebook-conflict',
              ),
              statusCode: 409,
              data: {'message': 'Conflict detected'},
            ),
          ),
        );

        // Act
        final result = await repository.update(updateDto);

        // Assert
        expect(result, isA<Failure<NotebookDetails>>());
        final failure = result as Failure<NotebookDetails>;
        expect(failure.error.toString(), contains('Conflito'));
      });
    });

    group('delete', () {
      test('should return Success when delete succeeds', () async {
        // Arrange
        const notebookId = 'notebook-del';

        when(mockApiService.delete(notebookId)).thenAnswer(
          (_) async => Response<void>(
            requestOptions: RequestOptions(path: '/notebooks/$notebookId'),
            statusCode: 204,
          ),
        );

        // Act
        final result = await repository.delete(notebookId);

        // Assert
        expect(result, isA<Success<void>>());
        verify(mockApiService.delete(notebookId)).called(1);
      });

      test('should return Failure when delete fails', () async {
        // Arrange
        const notebookId = 'notebook-del-fail';

        when(mockApiService.delete(notebookId)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notebooks/$notebookId'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/notebooks/$notebookId'),
              statusCode: 404,
            ),
          ),
        );

        // Act
        final result = await repository.delete(notebookId);

        // Assert
        expect(result, isA<Failure<void>>());
      });
    });

    group('restore', () {
      test('should return Success when restore succeeds', () async {
        // Arrange
        const notebookId = 'notebook-restore';

        when(mockApiService.restore(notebookId)).thenAnswer(
          (_) async => Response<void>(
            requestOptions: RequestOptions(
              path: '/notebooks/$notebookId/restore',
            ),
            statusCode: 200,
          ),
        );

        // Act
        final result = await repository.restore(notebookId);

        // Assert
        expect(result, isA<Success<void>>());
        verify(mockApiService.restore(notebookId)).called(1);
      });
    });

    group('error handling', () {
      test('should handle all DioExceptionType variants correctly', () async {
        // Test timeout variants
        when(mockApiService.create(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notebooks'),
            type: DioExceptionType.sendTimeout,
          ),
        );

        var result = await repository.create(
          NotebookCreate(title: 'Test', content: 'Content'),
        );
        expect(
          (result as Failure).error.toString(),
          contains('Tempo de envio esgotado'),
        );

        // Test cancel
        when(mockApiService.create(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notebooks'),
            type: DioExceptionType.cancel,
          ),
        );

        result = await repository.create(
          NotebookCreate(title: 'Test', content: 'Content'),
        );
        expect((result as Failure).error.toString(), contains('cancelada'));

        // Test badCertificate
        when(mockApiService.create(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notebooks'),
            type: DioExceptionType.badCertificate,
          ),
        );

        result = await repository.create(
          NotebookCreate(title: 'Test', content: 'Content'),
        );
        expect(
          (result as Failure).error.toString(),
          contains('Certificado de segurança inválido'),
        );

        // Test unknown
        when(mockApiService.create(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notebooks'),
            type: DioExceptionType.unknown,
            message: 'Unknown error occurred',
          ),
        );

        result = await repository.create(
          NotebookCreate(title: 'Test', content: 'Content'),
        );
        expect(
          (result as Failure).error.toString(),
          contains('Erro desconhecido na comunicação com o servidor'),
        );
      });
    });
  });
}
