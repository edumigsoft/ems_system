import 'package:core_shared/core_shared.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

class MockTagRepository extends Mock implements TagRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(TagCreate(name: 'fallback'));
  });

  group('CreateTagUseCase', () {
    late TagRepository repository;
    late CreateTagUseCase useCase;

    setUp(() {
      repository = MockTagRepository();
      useCase = CreateTagUseCase(repository);
    });

    group('call', () {
      test('should delegate to repository.create and return Success', () async {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );

        final expectedTagDetails = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
          isActive: true,
          isDeleted: false,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => repository.create(tagCreate),
        ).thenAnswer((_) async => Success(expectedTagDetails));

        // Act
        final result = await useCase.call(tagCreate);

        // Assert
        expect(result, isA<Success<TagDetails>>());
        expect((result as Success).value, expectedTagDetails);
        verify(() => repository.create(tagCreate)).called(1);
      });

      test('should delegate to repository.create and return Failure', () async {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: 'Work tasks',
          color: '#FF5733',
        );

        final exception = Exception('Database error');
        when(
          () => repository.create(tagCreate),
        ).thenAnswer((_) async => Failure(exception));

        // Act
        final result = await useCase.call(tagCreate);

        // Assert
        expect(result, isA<Failure<TagDetails>>());
        expect((result as Failure).error, exception);
        verify(() => repository.create(tagCreate)).called(1);
      });

      test('should pass exact TagCreate to repository', () async {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Personal',
          description: null,
          color: null,
        );

        final tagDetails = TagDetails(
          id: 'tag-456',
          name: 'Personal',
          description: null,
          color: null,
          isActive: true,
          isDeleted: false,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => repository.create(tagCreate),
        ).thenAnswer((_) async => Success(tagDetails));

        // Act
        await useCase.call(tagCreate);

        // Assert
        final captured = verify(() => repository.create(captureAny())).captured;
        expect(captured.length, 1);
        expect(captured.first, tagCreate);
      });

      test('should handle repository exceptions', () async {
        // Arrange
        final tagCreate = TagCreate(
          name: 'Work',
          description: null,
          color: null,
        );

        when(
          () => repository.create(tagCreate),
        ).thenAnswer((_) => throw Exception('Unexpected error'));

        // Act & Assert
        expect(
          () => useCase.call(tagCreate),
          throwsException,
        );
      });
    });
  });
}
