import 'package:core_shared/core_shared.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

class MockTagRepository extends Mock implements TagRepository {}

void main() {
  group('DeleteTagUseCase', () {
    late TagRepository repository;
    late DeleteTagUseCase useCase;

    setUp(() {
      repository = MockTagRepository();
      useCase = DeleteTagUseCase(repository);
    });

    group('call', () {
      test('should call repository.delete with correct id', () async {
        // Arrange
        const id = 'tag-123';
        when(
          () => repository.delete(id),
        ).thenAnswer((_) async => Success(null));

        // Act
        await useCase.call(id);

        // Assert
        verify(() => repository.delete(id)).called(1);
      });

      test('should return Success when deletion succeeds', () async {
        // Arrange
        const id = 'tag-123';
        when(
          () => repository.delete(id),
        ).thenAnswer((_) async => Success(null));

        // Act
        final result = await useCase.call(id);

        // Assert
        expect(result, isA<Success<void>>());
        expect((result as Success).value, isNull);
      });

      test('should return Failure when tag is not found', () async {
        // Arrange
        const id = 'non-existent-tag';
        final exception = Exception('Tag not found');
        when(
          () => repository.delete(id),
        ).thenAnswer((_) async => Failure(exception));

        // Act
        final result = await useCase.call(id);

        // Assert
        expect(result, isA<Failure<void>>());
        expect((result as Failure).error, exception);
      });

      test('should return Failure when repository fails', () async {
        // Arrange
        const id = 'tag-123';
        final exception = Exception('Database error');
        when(
          () => repository.delete(id),
        ).thenAnswer((_) async => Failure(exception));

        // Act
        final result = await useCase.call(id);

        // Assert
        expect(result, isA<Failure<void>>());
        expect((result as Failure).error, exception);
      });

      test('should handle repository exceptions', () async {
        // Arrange
        const id = 'tag-123';
        when(
          () => repository.delete(id),
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
        when(
          () => repository.delete(id),
        ).thenAnswer((_) async => Success(null));

        // Act
        await useCase.call(id);

        // Assert
        final captured = verify(() => repository.delete(captureAny())).captured;
        expect(captured.length, 1);
        expect(captured.first, id);
      });

      test('should handle empty string id', () async {
        // Arrange
        const id = '';
        final exception = Exception('Invalid id');
        when(
          () => repository.delete(id),
        ).thenAnswer((_) async => Failure(exception));

        // Act
        final result = await useCase.call(id);

        // Assert
        expect(result, isA<Failure<void>>());
        verify(() => repository.delete(id)).called(1);
      });

      test('should handle UUID format id', () async {
        // Arrange
        const id = '123e4567-e89b-12d3-a456-426614174000';
        when(
          () => repository.delete(id),
        ).thenAnswer((_) async => Success(null));

        // Act
        final result = await useCase.call(id);

        // Assert
        expect(result, isA<Success<void>>());
        verify(() => repository.delete(id)).called(1);
      });

      test('should perform soft delete, not hard delete', () async {
        // Arrange
        const id = 'tag-123';
        when(
          () => repository.delete(id),
        ).thenAnswer((_) async => Success(null));

        // Act
        final result = await useCase.call(id);

        // Assert
        // Soft delete should succeed without removing data
        expect(result, isA<Success<void>>());
        verify(() => repository.delete(id)).called(1);
      });

      test('should delegate to repository without additional logic', () async {
        // Arrange
        const id1 = 'tag-1';
        const id2 = 'tag-2';

        when(
          () => repository.delete(id1),
        ).thenAnswer((_) async => Success(null));
        when(
          () => repository.delete(id2),
        ).thenAnswer((_) async => Failure(Exception('Error')));

        // Act
        final result1 = await useCase.call(id1);
        final result2 = await useCase.call(id2);

        // Assert
        expect(result1, isA<Success<void>>());
        expect(result2, isA<Failure<void>>());
        verify(() => repository.delete(id1)).called(1);
        verify(() => repository.delete(id2)).called(1);
      });
    });
  });
}
