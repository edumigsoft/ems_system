import 'package:test/test.dart';
import 'package:notebook_shared/notebook_shared.dart';

void main() {
  group('NotebookUpdateModel', () {
    group('fromJson', () {
      test('should deserialize JSON with all fields', () {
        final json = {
          'id': 'notebook-update-123',
          'title': 'Updated Title',
          'content': 'Updated Content',
          'project_id': 'new-project-789',
          'parent_id': 'new-parent-012',
          'tags': ['updated', 'tags'],
          'type': 'organized',
          'reminder_date': '2026-06-01T15:00:00.000',
          'notify_on_reminder': false,
          'document_ids': ['doc-new-1', 'doc-new-2'],
          'is_active': false,
          'is_deleted': true,
        };

        final model = NotebookUpdateModel.fromJson(json);
        final dto = model.toDomain();

        expect(dto.id, 'notebook-update-123');
        expect(dto.title, 'Updated Title');
        expect(dto.content, 'Updated Content');
        expect(dto.projectId, 'new-project-789');
        expect(dto.parentId, 'new-parent-012');
        expect(dto.tags, ['updated', 'tags']);
        expect(dto.type, NotebookType.organized);
        expect(dto.reminderDate, DateTime.parse('2026-06-01T15:00:00.000'));
        expect(dto.notifyOnReminder, false);
        expect(dto.documentIds, ['doc-new-1', 'doc-new-2']);
        expect(dto.isActive, false);
        expect(dto.isDeleted, true);
      });

      test('should deserialize JSON with only id (no changes)', () {
        final json = {
          'id': 'notebook-minimal-update',
        };

        final model = NotebookUpdateModel.fromJson(json);
        final dto = model.toDomain();

        expect(dto.id, 'notebook-minimal-update');
        expect(dto.title, isNull);
        expect(dto.content, isNull);
        expect(dto.projectId, isNull);
        expect(dto.parentId, isNull);
        expect(dto.tags, isNull);
        expect(dto.type, isNull);
        expect(dto.reminderDate, isNull);
        expect(dto.notifyOnReminder, isNull);
        expect(dto.documentIds, isNull);
        expect(dto.isActive, isNull);
        expect(dto.isDeleted, isNull);
      });

      test('should deserialize partial update with specific fields', () {
        final json = {
          'id': 'partial-update',
          'title': 'New Title',
          'is_active': true,
        };

        final model = NotebookUpdateModel.fromJson(json);
        final dto = model.toDomain();

        expect(dto.id, 'partial-update');
        expect(dto.title, 'New Title');
        expect(dto.isActive, true);
        expect(dto.content, isNull);
        expect(dto.tags, isNull);
      });

      test('should deserialize all NotebookType enum values', () {
        final quickJson = {
          'id': '1',
          'type': 'quick',
        };

        final reminderJson = {
          'id': '2',
          'type': 'reminder',
        };

        final organizedJson = {
          'id': '3',
          'type': 'organized',
        };

        expect(
          NotebookUpdateModel.fromJson(quickJson).toDomain().type,
          NotebookType.quick,
        );
        expect(
          NotebookUpdateModel.fromJson(reminderJson).toDomain().type,
          NotebookType.reminder,
        );
        expect(
          NotebookUpdateModel.fromJson(organizedJson).toDomain().type,
          NotebookType.organized,
        );
      });
    });

    group('toJson', () {
      test('should serialize complete DTO to JSON with all fields', () {
        final dto = NotebookUpdate(
          id: 'update-full',
          title: 'Full Update',
          content: 'New Content',
          projectId: 'proj-123',
          parentId: 'parent-456',
          tags: ['tag-a', 'tag-b'],
          type: NotebookType.reminder,
          reminderDate: DateTime(2026, 7, 10, 12, 0),
          notifyOnReminder: true,
          documentIds: ['doc-x', 'doc-y'],
          isActive: true,
          isDeleted: false,
        );

        final model = NotebookUpdateModel.fromDomain(dto);
        final json = model.toJson();

        expect(json['id'], 'update-full');
        expect(json['title'], 'Full Update');
        expect(json['content'], 'New Content');
        expect(json['project_id'], 'proj-123');
        expect(json['parent_id'], 'parent-456');
        expect(json['tags'], ['tag-a', 'tag-b']);
        expect(json['type'], 'reminder');
        expect(
          json['reminder_date'],
          DateTime(2026, 7, 10, 12, 0).toIso8601String(),
        );
        expect(json['notify_on_reminder'], true);
        expect(json['document_ids'], ['doc-x', 'doc-y']);
        expect(json['is_active'], true);
        expect(json['is_deleted'], false);
      });

      test('should serialize DTO with only id (partial update)', () {
        final dto = NotebookUpdate(id: 'only-id');

        final model = NotebookUpdateModel.fromDomain(dto);
        final json = model.toJson();

        expect(json['id'], 'only-id');
        expect(json.containsKey('title'), isFalse);
        expect(json.containsKey('content'), isFalse);
        expect(json.containsKey('project_id'), isFalse);
        expect(json.containsKey('tags'), isFalse);
        expect(json.containsKey('type'), isFalse);
        expect(json.containsKey('is_active'), isFalse);
      });

      test('should only include non-null fields in JSON', () {
        final dto = NotebookUpdate(
          id: 'selective',
          title: 'New Title',
          isActive: false,
          // All other fields are null
        );

        final model = NotebookUpdateModel.fromDomain(dto);
        final json = model.toJson();

        expect(json.keys, containsAll(['id', 'title', 'is_active']));
        expect(json.keys.length, 3); // Only id, title, is_active
        expect(json['id'], 'selective');
        expect(json['title'], 'New Title');
        expect(json['is_active'], false);
      });

      test('should correctly serialize all NotebookType  enum values', () {
        final quickDto = NotebookUpdate(
          id: '1',
          type: NotebookType.quick,
        );

        final reminderDto = NotebookUpdate(
          id: '2',
          type: NotebookType.reminder,
        );

        final organizedDto = NotebookUpdate(
          id: '3',
          type: NotebookType.organized,
        );

        expect(
          NotebookUpdateModel.fromDomain(quickDto).toJson()['type'],
          'quick',
        );
        expect(
          NotebookUpdateModel.fromDomain(reminderDto).toJson()['type'],
          'reminder',
        );
        expect(
          NotebookUpdateModel.fromDomain(organizedDto).toJson()['type'],
          'organized',
        );
      });

      test(
        'should handle setting fields to null explicitly is not supported',
        () {
          // NotebookUpdate doesn't support explicit null setting,
          // it's designed for partial updates where absence = no change
          final dto = NotebookUpdate(
            id: 'test',
            title: null, // Will not be included in JSON
          );

          final json = NotebookUpdateModel.fromDomain(dto).toJson();
          expect(json.containsKey('title'), isFalse);
        },
      );
    });

    group('Round-trip Conversion', () {
      test(
        'should maintain data integrity in JSON -> Model -> JSON conversion',
        () {
          final originalJson = {
            'id': 'roundtrip',
            'title': 'Roundtrip Title',
            'content': 'Content',
            'tags': ['rt-tag'],
            'type': 'quick',
            'is_active': true,
          };

          final model = NotebookUpdateModel.fromJson(originalJson);
          final convertedJson = model.toJson();

          expect(convertedJson['id'], originalJson['id']);
          expect(convertedJson['title'], originalJson['title']);
          expect(convertedJson['content'], originalJson['content']);
          expect(convertedJson['tags'], originalJson['tags']);
          expect(convertedJson['type'], originalJson['type']);
          expect(convertedJson['is_active'], originalJson['is_active']);
        },
      );

      test('should handle partial update round-trip', () {
        final originalJson = {
          'id': 'partial-rt',
          'is_deleted': true,
        };

        final model = NotebookUpdateModel.fromJson(originalJson);
        final convertedJson = model.toJson();

        expect(convertedJson['id'], originalJson['id']);
        expect(convertedJson['is_deleted'], originalJson['is_deleted']);
        expect(convertedJson.keys.length, 2); // Only id and is_deleted
      });
    });

    group('fromDomain and toDomain', () {
      test('should convert from domain DTO correctly', () {
        final dto = NotebookUpdate(
          id: 'domain-test',
          title: 'Domain Title',
          type: NotebookType.organized,
        );

        final model = NotebookUpdateModel.fromDomain(dto);
        final convertedDto = model.toDomain();

        expect(convertedDto.id, dto.id);
        expect(convertedDto.title, dto.title);
        expect(convertedDto.type, dto.type);
      });

      test('toDomain should return wrapped DTO', () {
        final dto = NotebookUpdate(id: 'test');

        final model = NotebookUpdateModel(dto);
        expect(model.toDomain(), same(dto));
      });
    });

    group('Equality and HashCode', () {
      test('should be equal when wrapping same DTO', () {
        final dto = NotebookUpdate(id: 'test', title: 'Title');

        final model1 = NotebookUpdateModel(dto);
        final model2 = NotebookUpdateModel(dto);

        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when DTOs differ', () {
        final dto1 = NotebookUpdate(id: 'test1');
        final dto2 = NotebookUpdate(id: 'test2');

        final model1 = NotebookUpdateModel(dto1);
        final model2 = NotebookUpdateModel(dto2);

        expect(model1, isNot(equals(model2)));
      });
    });

    group('toString', () {
      test('should include DTO toString', () {
        final dto = NotebookUpdate(id: 'test-id', title: 'Test');

        final model = NotebookUpdateModel(dto);
        final str = model.toString();

        expect(str, contains('NotebookUpdateModel'));
        expect(str, contains('test-id'));
      });
    });
  });
}
