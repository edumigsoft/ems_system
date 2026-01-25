import 'package:core_shared/core_shared.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

class MockTagRepository extends Mock implements TagRepository {}

void main() {
  group('GetAllTagsUseCase', () {
    late TagRepository repository;
    late GetAllTagsUseCase useCase;

    setUp(() {
      repository = MockTagRepository();
      useCase = GetAllTagsUseCase(repository);
    });

    group('call', () {
      test('should call repository.getAll with default parameters', () async {
        // Arrange
        final tags = <TagDetails>[];
        when(
          () => repository.getAll(activeOnly: true, search: null),
        ).thenAnswer((_) async => Success(tags));

        // Act
        await useCase.call();

        // Assert
        verify(
          () => repository.getAll(activeOnly: true, search: null),
        ).called(1);
      });

      test('should call repository.getAll with activeOnly=true', () async {
        // Arrange
        final tags = <TagDetails>[];
        when(
          () => repository.getAll(activeOnly: true, search: null),
        ).thenAnswer((_) async => Success(tags));

        // Act
        await useCase.call(activeOnly: true);

        // Assert
        verify(
          () => repository.getAll(activeOnly: true, search: null),
        ).called(1);
      });

      test('should call repository.getAll with activeOnly=false', () async {
        // Arrange
        final tags = <TagDetails>[];
        when(
          () => repository.getAll(activeOnly: false, search: null),
        ).thenAnswer((_) async => Success(tags));

        // Act
        await useCase.call(activeOnly: false);

        // Assert
        verify(
          () => repository.getAll(activeOnly: false, search: null),
        ).called(1);
      });

      test('should call repository.getAll with search term', () async {
        // Arrange
        final tags = <TagDetails>[];
        when(
          () => repository.getAll(activeOnly: true, search: 'work'),
        ).thenAnswer((_) async => Success(tags));

        // Act
        await useCase.call(search: 'work');

        // Assert
        verify(
          () => repository.getAll(activeOnly: true, search: 'work'),
        ).called(1);
      });

      test('should call repository.getAll with both parameters', () async {
        // Arrange
        final tags = <TagDetails>[];
        when(
          () => repository.getAll(activeOnly: false, search: 'personal'),
        ).thenAnswer((_) async => Success(tags));

        // Act
        await useCase.call(activeOnly: false, search: 'personal');

        // Assert
        verify(
          () => repository.getAll(activeOnly: false, search: 'personal'),
        ).called(1);
      });

      test('should return Success with list of tags', () async {
        // Arrange
        final tag1 = TagDetails(
          id: 'tag-1',
          name: 'Work',
          description: null,
          color: null,
          isActive: true,
          isDeleted: false,
          usageCount: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final tag2 = TagDetails(
          id: 'tag-2',
          name: 'Personal',
          description: null,
          color: null,
          isActive: true,
          isDeleted: false,
          usageCount: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final tags = [tag1, tag2];
        when(
          () => repository.getAll(activeOnly: true, search: null),
        ).thenAnswer((_) async => Success(tags));

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<Success<List<TagDetails>>>());
        expect((result as Success).value, tags);
        expect((result as Success<List<TagDetails>>).value.length, 2);
      });

      test('should return Success with empty list', () async {
        // Arrange
        when(
          () => repository.getAll(activeOnly: true, search: null),
        ).thenAnswer((_) async => Success([]));

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<Success<List<TagDetails>>>());
        expect((result as Success).value, isEmpty);
      });

      test('should return Failure when repository fails', () async {
        // Arrange
        final exception = Exception('Database error');
        when(
          () => repository.getAll(activeOnly: true, search: null),
        ).thenAnswer((_) async => Failure(exception));

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<Failure<List<TagDetails>>>());
        expect((result as Failure).error, exception);
      });

      test('should handle repository exceptions', () async {
        // Arrange
        when(
          () => repository.getAll(activeOnly: true, search: null),
        ).thenAnswer((_) => throw Exception('Unexpected error'));

        // Act & Assert
        expect(
          () => useCase.call(),
          throwsException,
        );
      });

      test('should pass null search when not provided', () async {
        // Arrange
        when(
          () => repository.getAll(activeOnly: false, search: null),
        ).thenAnswer((_) async => Success([]));

        // Act
        await useCase.call(activeOnly: false);

        // Assert
        final captured = verify(
          () => repository.getAll(
            activeOnly: captureAny(named: 'activeOnly'),
            search: captureAny(named: 'search'),
          ),
        ).captured;

        expect(captured.length, 2);
        expect(captured[0], false);
        expect(captured[1], isNull);
      });

      test('should pass search term exactly as provided', () async {
        // Arrange
        const searchTerm = 'Test Tag Name';
        when(
          () => repository.getAll(activeOnly: true, search: searchTerm),
        ).thenAnswer((_) async => Success([]));

        // Act
        await useCase.call(search: searchTerm);

        // Assert
        final captured = verify(
          () => repository.getAll(
            activeOnly: captureAny(named: 'activeOnly'),
            search: captureAny(named: 'search'),
          ),
        ).captured;

        expect(captured[1], searchTerm);
      });
    });
  });
}
