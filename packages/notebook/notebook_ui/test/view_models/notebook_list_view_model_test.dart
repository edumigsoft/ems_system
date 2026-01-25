import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:notebook_ui/notebook_ui.dart';
import 'package:notebook_client/notebook_client.dart';
import 'package:notebook_shared/notebook_shared.dart';

import 'notebook_list_view_model_test.mocks.dart';

// Generate mocks: flutter pub run build_runner build
@GenerateMocks([NotebookApiService])
void main() {
  group('NotebookListViewModel', () {
    late MockNotebookApiService mockApiService;
    late NotebookListViewModel viewModel;

    setUp(() {
      mockApiService = MockNotebookApiService();
      viewModel = NotebookListViewModel(notebookService: mockApiService);
    });

    tearDown(() {
      viewModel.dispose();
    });

    group('Initial State', () {
      test('should have null notebooks initially', () {
        expect(viewModel.notebooks, isNull);
      });

      test('should not be loading initially', () {
        expect(viewModel.isLoading, isFalse);
      });

      test('should have no error initially', () {
        expect(viewModel.error, isNull);
      });
    });

    group('loadNotebooks', () {
      test('should set isLoading to true while loading', () async {
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
        ).thenAnswer((_) async {
          // Simulate delay
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return [];
        });

        final loadFuture = viewModel.loadNotebooks();

        // Should be loading immediately after calling
        expect(viewModel.isLoading, isTrue);

        await loadFuture;
      });

      test('should update notebooks list on success', () async {
        final mockModels = [
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
        ).thenAnswer((_) async => mockModels);

        await viewModel.loadNotebooks();

        expect(viewModel.notebooks, isNotNull);
        expect(viewModel.notebooks!.length, 2);
        expect(viewModel.notebooks![0].title, 'Notebook 1');
        expect(viewModel.notebooks![1].title, 'Notebook 2');
      });

      test('should set isLoading to false after success', () async {
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

        await viewModel.loadNotebooks();

        expect(viewModel.isLoading, isFalse);
      });

      test('should set error message on DioException', () async {
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
            type: DioExceptionType.connectionTimeout,
          ),
        );

        await viewModel.loadNotebooks();

        expect(viewModel.error, isNotNull);
        expect(viewModel.error, contains('Exception'));
        expect(viewModel.notebooks, isNull);
        expect(viewModel.isLoading, isFalse);
      });

      test('should notify listeners during loading process', () async {
        int notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

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

        await viewModel.loadNotebooks();

        // Should notify: start loading, finish loading
        expect(notificationCount, greaterThanOrEqualTo(2));
      });
    });

    group('deleteNotebook', () {
      test('should remove notebook from list on success', () async {
        final mockModels = [
          NotebookDetailsModel.fromJson({
            'id': 'notebook-1',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'title': 'Notebook 1',
            'content': 'Content',
          }),
          NotebookDetailsModel.fromJson({
            'id': 'notebook-2',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'title': 'Notebook 2',
            'content': 'Content',
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
        ).thenAnswer((_) async => mockModels);

        await viewModel.loadNotebooks();
        expect(viewModel.notebooks!.length, 2);

        when(mockApiService.delete('notebook-1')).thenAnswer(
          (_) async {
            // Just complete the future, no return value needed for void
          },
        );

        final result = await viewModel.deleteNotebook('notebook-1');

        expect(result, isTrue);
        expect(viewModel.notebooks!.length, 1);
        expect(viewModel.notebooks![0].id, 'notebook-2');
      });

      test('should return false on delete failure', () async {
        when(mockApiService.delete(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notebooks/notebook-1'),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await viewModel.deleteNotebook('notebook-1');

        expect(result, isFalse);
        expect(viewModel.error, isNotNull);
      });

      test('should set isLoading during delete operation', () async {
        when(mockApiService.delete(any)).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });

        final deleteFuture = viewModel.deleteNotebook('test');

        expect(viewModel.isLoading, isTrue);

        await deleteFuture;

        expect(viewModel.isLoading, isFalse);
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
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

        await viewModel.loadNotebooks();
        expect(viewModel.error, isNotNull);

        viewModel.clearError();

        expect(viewModel.error, isNull);
      });

      test('should notify listeners when clearing error', () {
        int notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        viewModel.clearError();

        expect(notificationCount, 1);
      });
    });
  });
}
