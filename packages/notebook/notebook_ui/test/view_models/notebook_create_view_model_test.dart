import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:notebook_ui/notebook_ui.dart';
import 'package:notebook_client/notebook_client.dart';
import 'package:notebook_shared/notebook_shared.dart';

import 'notebook_create_view_model_test.mocks.dart';

// Generate mocks: flutter pub run build_runner build
@GenerateMocks([NotebookApiService])
void main() {
  group('NotebookCreateViewModel', () {
    late MockNotebookApiService mockApiService;
    late NotebookCreateViewModel viewModel;

    setUp(() {
      mockApiService = MockNotebookApiService();
      viewModel = NotebookCreateViewModel(notebookService: mockApiService);
    });

    tearDown(() {
      viewModel.dispose();
    });

    group('Initial State', () {
      test('should not be creating initially', () {
        expect(viewModel.isCreating, isFalse);
      });

      test('should have no error initially', () {
        expect(viewModel.error, isNull);
      });

      test('should have no created notebook initially', () {
        expect(viewModel.createdNotebook, isNull);
      });
    });

    group('createNotebook', () {
      test('should set isCreating to true while creating', () async {
        when(mockApiService.create(any)).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return NotebookDetailsModel.fromJson({
            'id': 'new-notebook',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'title': 'New Notebook',
            'content': 'Content',
          });
        });

        final createFuture = viewModel.createNotebook(
          NotebookCreate(title: 'New Notebook', content: 'Content'),
        );

        expect(viewModel.isCreating, isTrue);

        await createFuture;
      });

      test('should set createdNotebook on success', () async {
        final mockModel = NotebookDetailsModel.fromJson({
          'id': 'created-notebook',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'title': 'Created Notebook',
          'content': 'Test Content',
          'type': 'quick',
        });

        when(mockApiService.create(any)).thenAnswer((_) async => mockModel);

        final data = NotebookCreate(
          title: 'Created Notebook',
          content: 'Test Content',
          type: NotebookType.quick,
        );

        final result = await viewModel.createNotebook(data);

        expect(result, isTrue);
        expect(viewModel.createdNotebook, isNotNull);
        expect(viewModel.createdNotebook!.title, 'Created Notebook');
        expect(viewModel.createdNotebook!.type, NotebookType.quick);
        expect(viewModel.isCreating, isFalse);
        expect(viewModel.error, isNull);
      });

      test('should set error on failure', () async {
        when(mockApiService.create(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notebooks'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/notebooks'),
              statusCode: 400,
            ),
          ),
        );

        final data = NotebookCreate(
          title: 'Invalid Notebook',
          content: 'Content',
        );

        final result = await viewModel.createNotebook(data);

        expect(result, isFalse);
        expect(viewModel.error, isNotNull);
        expect(viewModel.createdNotebook, isNull);
        expect(viewModel.isCreating, isFalse);
      });

      test('should return false on creation failure', () async {
        when(mockApiService.create(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notebooks'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        final result = await viewModel.createNotebook(
          NotebookCreate(title: 'Test', content: 'Content'),
        );

        expect(result, isFalse);
      });

      test('should notify listeners during creation', () async {
        int notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        when(mockApiService.create(any)).thenAnswer(
          (_) async => NotebookDetailsModel.fromJson({
            'id': '1',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'title': 'Test',
            'content': 'Content',
          }),
        );

        await viewModel.createNotebook(
          NotebookCreate(title: 'Test', content: 'Content'),
        );

        expect(notificationCount, greaterThanOrEqualTo(2));
      });
    });

    group('createQuickNote', () {
      test('should create notebook with quick type', () async {
        when(mockApiService.create(any)).thenAnswer(
          (_) async => NotebookDetailsModel.fromJson({
            'id': 'quick-note',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'title': 'Quick Note',
            'content': 'Quick Content',
            'type': 'quick',
          }),
        );

        final result = await viewModel.createQuickNote(
          title: 'Quick Note',
          content: 'Quick Content',
        );

        expect(result, isTrue);
        expect(viewModel.createdNotebook, isNotNull);
        expect(viewModel.createdNotebook!.type, NotebookType.quick);
        verify(mockApiService.create(any)).called(1);
      });

      test('should pass correct parameters to createNotebook', () async {
        when(mockApiService.create(any)).thenAnswer(
          (_) async => NotebookDetailsModel.fromJson({
            'id': '1',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'title': 'Title',
            'content': 'Content',
            'type': 'quick',
          }),
        );

        await viewModel.createQuickNote(
          title: 'Title',
          content: 'Content',
        );

        // Verify the API was called with correct data
        final captured = verify(mockApiService.create(captureAny)).captured;
        expect(captured.length, 1);

        final jsonData = captured[0] as Map<String, dynamic>;
        expect(jsonData['title'], 'Title');
        expect(jsonData['content'], 'Content');
        expect(jsonData['type'], 'quick');
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        when(mockApiService.create(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notebooks'),
            type: DioExceptionType.connectionError,
          ),
        );

        await viewModel.createNotebook(
          NotebookCreate(title: 'Test', content: 'Content'),
        );
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

    group('reset', () {
      test('should reset all state to initial values', () async {
        when(mockApiService.create(any)).thenAnswer(
          (_) async => NotebookDetailsModel.fromJson({
            'id': '1',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'title': 'Test',
            'content': 'Content',
          }),
        );

        await viewModel.createNotebook(
          NotebookCreate(title: 'Test', content: 'Content'),
        );

        expect(viewModel.createdNotebook, isNotNull);

        viewModel.reset();

        expect(viewModel.createdNotebook, isNull);
        expect(viewModel.error, isNull);
        expect(viewModel.isCreating, isFalse);
      });

      test('should notify listeners when resetting', () {
        int notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        viewModel.reset();

        expect(notificationCount, 1);
      });
    });
  });
}
