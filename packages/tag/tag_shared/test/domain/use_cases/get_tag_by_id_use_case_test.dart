import 'package:core_shared/core_shared.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

class MockTagRepository extends Mock implements TagRepository {}

void main() {
  group('GetTagByIdUseCase', () {
    late TagRepository repository;
    late GetTagByIdUseCase useCase;

    setUp(() {
      repository = MockTagRepository();
      useCase = GetTagByIdUseCase(repository);
    });

    group('call', () {
      test('should call repository.getById with correct id', () async {
        // Arrange
        const id = 'tag-123';
        final tagDetails = TagDetails(
          id: id,
          name: 'Work',
          description: null,
          color: null,
          isActive: true,
          isDeleted: false,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => repository.getById(id),
        ).thenAnswer((_) async => Success(tagDetails));

        // Act
        await useCase.call(id);

        // Assert
        verify(() => repository.getById(id)).called(1);
      });

      test('should return Success with TagDetails when tag is found', () async {
        // Arrange
        const id = 'tag-123';
        final expectedTag = TagDetails(
          id: id,
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
          isActive: true,
          isDeleted: false,
          usageCount: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => repository.getById(id),
        ).thenAnswer((_) async => Success(expectedTag));

        // Act
        final result = await useCase.call(id);

        // Assert
        expect(result, isA<Success<TagDetails>>());
        final successResult = result as Success<TagDetails>;
        expect(successResult.value, expectedTag);
        expect(successResult.value.id, id);
        expect(successResult.value.name, 'Work');
      });

      test('should return Failure when tag is not found', () async {
        // Arrange
        const id = 'non-existent-tag';
        final exception = Exception('Tag not found');

        when(
          () => repository.getById(id),
        ).thenAnswer((_) async => Failure(exception));

        // Act
        final result = await useCase.call(id);

        // Assert
        expect(result, isA<Failure<Exception>>());
        expect((result as Failure<Exception>).error, exception);
      });

      test('should return Failure when repository fails', () async {
        // Arrange
        const id = 'tag-123';
        final exception = Exception('Database error');

        when(
          () => repository.getById(id),
        ).thenAnswer((_) async => Failure(exception));

        // Act
        final result = await useCase.call(id);

        // Assert
        expect(result, isA<Failure<Exception>>());
        expect((result as Failure<Exception>).error, exception);
      });

      test('should handle repository exceptions', () async {
        // Arrange
        const id = 'tag-123';
        when(
          () => repository.getById(id),
        ).thenAnswer((_) => throw Exception('Unexpected error'));

        // Act & Assert
        expect(
          () => useCase.call(id),
          throwsException,
        );
      });

      test('should pass exact id to repository', () async {
        // Arrange
        const id = 'specific-tag-id-12345';
        final tagDetails = TagDetails(
          id: id,
          name: 'Test',
          description: null,
          color: null,
          isActive: true,
          isDeleted: false,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => repository.getById(id),
        ).thenAnswer((_) async => Success(tagDetails));

        // Act
        await useCase.call(id);

        // Assert
        final captured = verify(
          () => repository.getById(captureAny()),
        ).captured;
        expect(captured.length, 1);
        expect(captured.first, id);
      });

      test('should handle empty string id', () async {
        // Arrange
        const id = '';
        final exception = Exception('Invalid id');

        when(
          () => repository.getById(id),
        ).thenAnswer((_) async => Failure(exception));

        // Act
        final result = await useCase.call(id);

        // Assert
        expect(result, isA<Failure<Exception>>());
        verify(() => repository.getById(id)).called(1);
      });

      test('should handle UUID format id', () async {
        // Arrange
        const id = '123e4567-e89b-12d3-a456-426614174000';
        final tagDetails = TagDetails(
          id: id,
          name: 'UUID Tag',
          description: null,
          color: null,
          isActive: true,
          isDeleted: false,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => repository.getById(id),
        ).thenAnswer((_) async => Success(tagDetails));

        // Act
        final result = await useCase.call(id);

        // Assert
        expect(result, isA<Success<TagDetails>>());
        final successResult = result as Success<TagDetails>;
        expect(successResult.value.id, id);
      });
    });
  });
}
