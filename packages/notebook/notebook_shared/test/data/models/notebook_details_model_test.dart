import 'package:test/test.dart';
import 'package:notebook_shared/notebook_shared.dart';

void main() {
  group('NotebookDetailsModel', () {
    final testDate = DateTime(2026, 1, 25, 10, 30, 0);

    group('fromJson', () {
      test('should deserialize complete JSON with all fields', () {
        final json = {
          'id': 'notebook-123',
          'is_deleted': false,
          'is_active': true,
          'created_at': '2026-01-25T10:30:00.000',
          'updated_at': '2026-01-25T10:35:00.000',
          'title': 'Test Notebook',
          'content': 'Test Content',
          'project_id': 'project-456',
          'parent_id': 'parent-789',
          'tags': ['tag1', 'tag2', 'tag3'],
          'type': 'organized',
          'reminder_date': '2026-02-01T09:00:00.000',
          'notify_on_reminder': true,
          'document_ids': ['doc-1', 'doc-2'],
        };

        final model = NotebookDetailsModel.fromJson(json);
        final entity = model.toDomain();

        expect(entity.id, 'notebook-123');
        expect(entity.isDeleted, false);
        expect(entity.isActive, true);
        expect(entity.createdAt, DateTime.parse('2026-01-25T10:30:00.000'));
        expect(entity.updatedAt, DateTime.parse('2026-01-25T10:35:00.000'));
        expect(entity.title, 'Test Notebook');
        expect(entity.content, 'Test Content');
        expect(entity.projectId, 'project-456');
        expect(entity.parentId, 'parent-789');
        expect(entity.tags, ['tag1', 'tag2', 'tag3']);
        expect(entity.type, NotebookType.organized);
        expect(entity.reminderDate, DateTime.parse('2026-02-01T09:00:00.000'));
        expect(entity.notifyOnReminder, true);
        expect(entity.documentIds, ['doc-1', 'doc-2']);
      });

      test('should deserialize JSON with minimal required fields', () {
        final json = {
          'id': 'notebook-minimal',
          'created_at': testDate.toIso8601String(),
          'updated_at': testDate.toIso8601String(),
          'title': 'Minimal',
          'content': 'Content',
        };

        final model = NotebookDetailsModel.fromJson(json);
        final entity = model.toDomain();

        expect(entity.id, 'notebook-minimal');
        expect(entity.isDeleted, false); // default
        expect(entity.isActive, true); // default
        expect(entity.title, 'Minimal');
        expect(entity.content, 'Content');
        expect(entity.projectId, isNull);
        expect(entity.parentId, isNull);
        expect(entity.tags, isNull);
        expect(entity.type, isNull);
        expect(entity.reminderDate, isNull);
        expect(entity.notifyOnReminder, isNull);
        expect(entity.documentIds, isNull);
      });

      test('should deserialize with all NotebookType variations', () {
        final quickJson = {
          'id': 'quick',
          'created_at': testDate.toIso8601String(),
          'updated_at': testDate.toIso8601String(),
          'title': 'Quick',
          'content': 'Content',
          'type': 'quick',
        };

        final reminderJson = {
          'id': 'reminder',
          'created_at': testDate.toIso8601String(),
          'updated_at': testDate.toIso8601String(),
          'title': 'Reminder',
          'content': 'Content',
          'type': 'reminder',
        };

        final organizedJson = {
          'id': 'organized',
          'created_at': testDate.toIso8601String(),
          'updated_at': testDate.toIso8601String(),
          'title': 'Organized',
          'content': 'Content',
          'type': 'organized',
        };

        expect(
          NotebookDetailsModel.fromJson(quickJson).toDomain().type,
          NotebookType.quick,
        );
        expect(
          NotebookDetailsModel.fromJson(reminderJson).toDomain().type,
          NotebookType.reminder,
        );
        expect(
          NotebookDetailsModel.fromJson(organizedJson).toDomain().type,
          NotebookType.organized,
        );
      });

      test('should handle null type field', () {
        final json = {
          'id': 'no-type',
          'created_at': testDate.toIso8601String(),
          'updated_at': testDate.toIso8601String(),
          'title': 'No Type',
          'content': 'Content',
          'type': null,
        };

        final model = NotebookDetailsModel.fromJson(json);
        expect(model.toDomain().type, isNull);
      });

      test('should handle empty lists correctly', () {
        final json = {
          'id': 'empty-lists',
          'created_at': testDate.toIso8601String(),
          'updated_at': testDate.toIso8601String(),
          'title': 'Empty Lists',
          'content': 'Content',
          'tags': <String>[],
          'document_ids': <String>[],
        };

        final model = NotebookDetailsModel.fromJson(json);
        final entity = model.toDomain();

        expect(entity.tags, <String>[]);
        expect(entity.documentIds, <String>[]);
      });
    });

    group('toJson', () {
      test('should serialize complete entity to JSON', () {
        final entity = NotebookDetails.create(
          id: 'notebook-123',
          isDeleted: false,
          isActive: true,
          createdAt: testDate,
          updatedAt: testDate.add(Duration(minutes: 5)),
          title: 'Test Notebook',
          content: 'Test Content',
          projectId: 'project-456',
          parentId: 'parent-789',
          tags: ['tag1', 'tag2'],
          type: NotebookType.organized,
          reminderDate: DateTime(2026, 2, 1),
          notifyOnReminder: true,
          documentIds: ['doc-1', 'doc-2'],
        );

        final model = NotebookDetailsModel.fromDomain(entity);
        final json = model.toJson();

        expect(json['id'], 'notebook-123');
        expect(json['is_deleted'], false);
        expect(json['is_active'], true);
        expect(json['created_at'], testDate.toIso8601String());
        expect(
          json['updated_at'],
          testDate.add(Duration(minutes: 5)).toIso8601String(),
        );
        expect(json['title'], 'Test Notebook');
        expect(json['content'], 'Test Content');
        expect(json['project_id'], 'project-456');
        expect(json['parent_id'], 'parent-789');
        expect(json['tags'], ['tag1', 'tag2']);
        expect(json['type'], 'organized');
        expect(json['reminder_date'], DateTime(2026, 2, 1).toIso8601String());
        expect(json['notify_on_reminder'], true);
        expect(json['document_ids'], ['doc-1', 'doc-2']);
      });

      test('should serialize entity with null optional fields to JSON', () {
        final entity = NotebookDetails.create(
          id: 'minimal',
          isDeleted: false,
          isActive: true,
          createdAt: testDate,
          updatedAt: testDate,
          title: 'Minimal',
          content: 'Content',
        );

        final model = NotebookDetailsModel.fromDomain(entity);
        final json = model.toJson();

        expect(json['id'], 'minimal');
        expect(json['title'], 'Minimal');
        expect(json['content'], 'Content');
        expect(json['project_id'], isNull);
        expect(json['parent_id'], isNull);
        expect(json['tags'], isNull);
        expect(json['type'], isNull);
        expect(json['reminder_date'], isNull);
        expect(json['notify_on_reminder'], isNull);
        expect(json['document_ids'], isNull);
      });

      test('should correctly serialize all NotebookType enum values', () {
        final quickEntity = NotebookDetails.create(
          id: '1',
          createdAt: testDate,
          updatedAt: testDate,
          title: 'Quick',
          content: 'Content',
          type: NotebookType.quick,
        );

        final reminderEntity = NotebookDetails.create(
          id: '2',
          createdAt: testDate,
          updatedAt: testDate,
          title: 'Reminder',
          content: 'Content',
          type: NotebookType.reminder,
        );

        final organizedEntity = NotebookDetails.create(
          id: '3',
          createdAt: testDate,
          updatedAt: testDate,
          title: 'Organized',
          content: 'Content',
          type: NotebookType.organized,
        );

        expect(
          NotebookDetailsModel.fromDomain(quickEntity).toJson()['type'],
          'quick',
        );
        expect(
          NotebookDetailsModel.fromDomain(reminderEntity).toJson()['type'],
          'reminder',
        );
        expect(
          NotebookDetailsModel.fromDomain(organizedEntity).toJson()['type'],
          'organized',
        );
      });
    });

    group('Round-trip Conversion', () {
      test(
        'should maintain data integrity in JSON -> Model -> JSON conversion',
        () {
          final originalJson = {
            'id': 'roundtrip-test',
            'is_deleted': false,
            'is_active': true,
            'created_at': testDate.toIso8601String(),
            'updated_at': testDate.toIso8601String(),
            'title': 'Round Trip',
            'content': 'Content',
            'project_id': 'project-1',
            'tags': ['tag1', 'tag2'],
            'type': 'quick',
            'reminder_date': DateTime(2026, 2, 15).toIso8601String(),
            'notify_on_reminder': false,
            'document_ids': ['doc-x'],
          };

          final model = NotebookDetailsModel.fromJson(originalJson);
          final convertedJson = model.toJson();

          expect(convertedJson['id'], originalJson['id']);
          expect(convertedJson['title'], originalJson['title']);
          expect(convertedJson['content'], originalJson['content']);
          expect(convertedJson['project_id'], originalJson['project_id']);
          expect(convertedJson['tags'], originalJson['tags']);
          expect(convertedJson['type'], originalJson['type']);
          expect(convertedJson['reminder_date'], originalJson['reminder_date']);
          expect(
            convertedJson['notify_on_reminder'],
            originalJson['notify_on_reminder'],
          );
          expect(convertedJson['document_ids'], originalJson['document_ids']);
        },
      );
    });

    group('fromDomain and toDomain', () {
      test('should convert from domain entity correctly', () {
        final entity = NotebookDetails.create(
          id: 'domain-test',
          createdAt: testDate,
          updatedAt: testDate,
          title: 'Domain Test',
          content: 'Content',
          type: NotebookType.reminder,
        );

        final model = NotebookDetailsModel.fromDomain(entity);
        final convertedEntity = model.toDomain();

        expect(convertedEntity.id, entity.id);
        expect(convertedEntity.title, entity.title);
        expect(convertedEntity.content, entity.content);
        expect(convertedEntity.type, entity.type);
      });

      test('toDomain should return wrapped entity', () {
        final entity = NotebookDetails.create(
          id: 'test',
          createdAt: testDate,
          updatedAt: testDate,
          title: 'Test',
          content: 'Content',
        );

        final model = NotebookDetailsModel(entity);
        expect(model.toDomain(), same(entity));
      });
    });

    group('Equality and HashCode', () {
      test('should be equal when wrapping same entity', () {
        final entity = NotebookDetails.create(
          id: 'test',
          createdAt: testDate,
          updatedAt: testDate,
          title: 'Test',
          content: 'Content',
        );

        final model1 = NotebookDetailsModel(entity);
        final model2 = NotebookDetailsModel(entity);

        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should be equal when wrapping equivalent entities', () {
        final entity1 = NotebookDetails.create(
          id: 'test',
          createdAt: testDate,
          updatedAt: testDate,
          title: 'Test',
          content: 'Content',
        );

        final entity2 = NotebookDetails.create(
          id: 'test',
          createdAt: testDate,
          updatedAt: testDate,
          title: 'Test',
          content: 'Content',
        );

        final model1 = NotebookDetailsModel(entity1);
        final model2 = NotebookDetailsModel(entity2);

        expect(model1, equals(model2));
      });

      test('should not be equal when entities differ', () {
        final entity1 = NotebookDetails.create(
          id: 'test1',
          createdAt: testDate,
          updatedAt: testDate,
          title: 'Test 1',
          content: 'Content',
        );

        final entity2 = NotebookDetails.create(
          id: 'test2',
          createdAt: testDate,
          updatedAt: testDate,
          title: 'Test 2',
          content: 'Content',
        );

        final model1 = NotebookDetailsModel(entity1);
        final model2 = NotebookDetailsModel(entity2);

        expect(model1, isNot(equals(model2)));
      });
    });

    group('toString', () {
      test('should include entity toString', () {
        final entity = NotebookDetails.create(
          id: 'test',
          createdAt: testDate,
          updatedAt: testDate,
          title: 'Test Notebook',
          content: 'Content',
        );

        final model = NotebookDetailsModel(entity);
        final str = model.toString();

        expect(str, contains('NotebookDetailsModel'));
        expect(str, contains('Test Notebook'));
      });
    });
  });
}
