import 'package:core_shared/core_shared.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tag_shared/tag_shared.dart';
import 'package:test/test.dart';

class MockTagRepository extends Mock implements TagRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(TagUpdate(id: 'fallback'));
  });

  group('UpdateTagUseCase', () {
    late TagRepository repository;
    late UpdateTagUseCase useCase;

    setUp(() {
      repository = MockTagRepository();
      useCase = UpdateTagUseCase(repository);
    });

    group('call', () {
      test('should call repository.update when hasChanges is true', () async {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Updated Work',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        final updatedTag = TagDetails(
          id: 'tag-123',
          name: 'Updated Work',
          description: 'Old description',
          color: '#FF5733',
          isActive: true,
          isDeleted: false,
          usageCount: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => repository.update(tagUpdate),
        ).thenAnswer((_) async => Success(updatedTag));

        // Act
        await useCase.call(tagUpdate);

        // Assert
        verify(() => repository.update(tagUpdate)).called(1);
      });

      test('should return Success with updated TagDetails', () async {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Updated Name',
          description: 'Updated description',
          color: '#00FF00',
          isActive: null,
          isDeleted: null,
        );

        final expectedTag = TagDetails(
          id: 'tag-123',
          name: 'Updated Name',
          description: 'Updated description',
          color: '#00FF00',
          isActive: true,
          isDeleted: false,
          usageCount: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => repository.update(tagUpdate),
        ).thenAnswer((_) async => Success(expectedTag));

        // Act
        final result = await useCase.call(tagUpdate);

        // Assert
        expect(result, isA<Success<TagDetails>>());
        final successResult = result as Success<TagDetails>;
        expect(successResult.value, expectedTag);
        expect(successResult.value.name, 'Updated Name');
        expect(successResult.value.description, 'Updated description');
        expect(successResult.value.color, '#00FF00');
      });

      test('should return Failure when hasChanges is false', () async {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final result = await useCase.call(tagUpdate);

        // Assert
        expect(result, isA<Failure<Object>>());
        expect(
          (result as Failure<Object>).error.toString(),
          contains('No changes to apply'),
        );
        verifyNever(() => repository.update(any()));
      });

      test('should not call repository when no changes', () async {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        await useCase.call(tagUpdate);

        // Assert
        verifyNever(() => repository.update(tagUpdate));
      });

      test('should return Failure when repository fails', () async {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Updated',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        final exception = Exception('Database error');
        when(
          () => repository.update(tagUpdate),
        ).thenAnswer((_) async => Failure(exception));

        // Act
        final result = await useCase.call(tagUpdate);

        // Assert
        expect(result, isA<Failure<Object>>());
        expect((result as Failure<Object>).error, exception);
      });

      test('should handle repository exceptions', () async {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: 'Updated',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        when(
          () => repository.update(tagUpdate),
        ).thenAnswer((_) => throw Exception('Unexpected error'));

        // Act & Assert
        expect(
          () => useCase.call(tagUpdate),
          throwsException,
        );
      });

      test('should allow updating only isActive flag', () async {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: false,
          isDeleted: null,
        );

        final updatedTag = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          isActive: false,
          isDeleted: false,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => repository.update(tagUpdate),
        ).thenAnswer((_) async => Success(updatedTag));

        // Act
        final result = await useCase.call(tagUpdate);

        // Assert
        expect(result, isA<Success<TagDetails>>());
        expect((result as Success<TagDetails>).value.isActive, false);
        verify(() => repository.update(tagUpdate)).called(1);
      });

      test('should allow updating only isDeleted flag', () async {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: true,
        );

        final updatedTag = TagDetails(
          id: 'tag-123',
          name: 'Work',
          description: null,
          color: null,
          isActive: true,
          isDeleted: true,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => repository.update(tagUpdate),
        ).thenAnswer((_) async => Success(updatedTag));

        // Act
        final result = await useCase.call(tagUpdate);

        // Assert
        expect(result, isA<Success<TagDetails>>());
        expect((result as Success<TagDetails>).value.isDeleted, true);
        verify(() => repository.update(tagUpdate)).called(1);
      });

      test('should pass exact TagUpdate to repository', () async {
        // Arrange
        final tagUpdate = TagUpdate(
          id: 'tag-456',
          name: 'Personal',
          description: 'Personal tasks',
          color: '#0000FF',
          isActive: true,
          isDeleted: false,
        );

        final updatedTag = TagDetails(
          id: 'tag-456',
          name: 'Personal',
          description: 'Personal tasks',
          color: '#0000FF',
          isActive: true,
          isDeleted: false,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => repository.update(tagUpdate),
        ).thenAnswer((_) async => Success(updatedTag));

        // Act
        await useCase.call(tagUpdate);

        // Assert
        final captured = verify(() => repository.update(captureAny())).captured;
        expect(captured.length, 1);
        expect(captured.first, tagUpdate);
      });

      test('should validate hasChanges before calling repository', () async {
        // Arrange - create update with changes
        final tagUpdateWithChanges = TagUpdate(
          id: 'tag-123',
          name: 'New Name',
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        final updatedTag = TagDetails(
          id: 'tag-123',
          name: 'New Name',
          description: null,
          color: null,
          isActive: true,
          isDeleted: false,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => repository.update(tagUpdateWithChanges),
        ).thenAnswer((_) async => Success(updatedTag));

        // Act
        final resultWithChanges = await useCase.call(tagUpdateWithChanges);

        // Assert - should succeed with changes
        expect(resultWithChanges, isA<Success<TagDetails>>());
        verify(() => repository.update(tagUpdateWithChanges)).called(1);

        // Arrange - create update without changes
        reset(repository);
        final tagUpdateNoChanges = TagUpdate(
          id: 'tag-123',
          name: null,
          description: null,
          color: null,
          isActive: null,
          isDeleted: null,
        );

        // Act
        final resultNoChanges = await useCase.call(tagUpdateNoChanges);

        // Assert - should fail without changes
        expect(resultNoChanges, isA<Failure<Object>>());
        verifyNever(() => repository.update(any()));
      });
    });
  });
}
