import 'package:test/test.dart';
import 'package:notebook_shared/notebook_shared.dart';

void main() {
  group('NotebookCreateModel', () {
    group('fromJson', () {
      test('should deserialize complete JSON with all fields', () {
        final json = {
          'title': 'New Notebook',
          'content': 'Notebook Content',
          'project_id': 'project-123',
          'parent_id': 'parent-456',
          'tags': ['work', 'important'],
          'type': 'organized',
          'reminder_date': '2026-03-01T10:00:00.000',
          'notify_on_reminder': true,
          'document_ids': ['doc-1', 'doc-2'],
        };

        final model = NotebookCreateModel.fromJson(json);
        final dto = model.toDomain();

        expect(dto.title, 'New Notebook');
        expect(dto.content, 'Notebook Content');
        expect(dto.projectId, 'project-123');
        expect(dto.parentId, 'parent-456');
        expect(dto.tags, ['work', 'important']);
        expect(dto.type, NotebookType.organized);
        expect(dto.reminderDate, DateTime.parse('2026-03-01T10:00:00.000'));
        expect(dto.notifyOnReminder, true);
        expect(dto.documentIds, ['doc-1', 'doc-2']);
      });

      test('should deserialize JSON with only required fields', () {
        final json = {
          'title': 'Minimal Notebook',
          'content': 'Basic Content',
        };

        final model = NotebookCreateModel.fromJson(json);
        final dto = model.toDomain();

        expect(dto.title, 'Minimal Notebook');
        expect(dto.content, 'Basic Content');
        expect(dto.projectId, isNull);
        expect(dto.parentId, isNull);
        expect(dto.tags, isNull);
        expect(dto.type, isNull);
        expect(dto.reminderDate, isNull);
        expect(dto.notifyOnReminder, isNull);
        expect(dto.documentIds, isNull);
      });

      test('should deserialize all NotebookType enum values', () {
        final quickJson = {
          'title': 'Quick Note',
          'content': 'Content',
          'type': 'quick',
        };

        final reminderJson = {
          'title': 'Reminder',
          'content': 'Content',
          'type': 'reminder',
        };

        final organizedJson = {
          'title': 'Organized',
          'content': 'Content',
          'type': 'organized',
        };

        expect(
          NotebookCreateModel.fromJson(quickJson).toDomain().type,
          NotebookType.quick,
        );
        expect(
          NotebookCreateModel.fromJson(reminderJson).toDomain().type,
          NotebookType.reminder,
        );
        expect(
          NotebookCreateModel.fromJson(organizedJson).toDomain().type,
          NotebookType.organized,
        );
      });

      test('should handle null type field', () {
        final json = {
          'title': 'No Type',
          'content': 'Content',
          'type': null,
        };

        final model = NotebookCreateModel.fromJson(json);
        expect(model.toDomain().type, isNull);
      });

      test('should handle empty lists', () {
        final json = {
          'title': 'Empty Lists',
          'content': 'Content',
          'tags': <String>[],
          'document_ids': <String>[],
        };

        final model = NotebookCreateModel.fromJson(json);
        final dto = model.toDomain();

        expect(dto.tags, <String>[]);
        expect(dto.documentIds, <String>[]);
      });
    });

    group('toJson', () {
      test('should serialize complete DTO to JSON', () {
        final dto = NotebookCreate(
          title: 'Complete Notebook',
          content: 'Full Content',
          projectId: 'project-789',
          parentId: 'parent-012',
          tags: ['tag1', 'tag2', 'tag3'],
          type: NotebookType.reminder,
          reminderDate: DateTime(2026, 4, 15, 14, 30),
          notifyOnReminder: false,
          documentIds: ['doc-a', 'doc-b'],
        );

        final model = NotebookCreateModel.fromDomain(dto);
        final json = model.toJson();

        expect(json['title'], 'Complete Notebook');
        expect(json['content'], 'Full Content');
        expect(json['project_id'], 'project-789');
        expect(json['parent_id'], 'parent-012');
        expect(json['tags'], ['tag1', 'tag2', 'tag3']);
        expect(json['type'], 'reminder');
        expect(
          json['reminder_date'],
          DateTime(2026, 4, 15, 14, 30).toIso8601String(),
        );
        expect(json['notify_on_reminder'], false);
        expect(json['document_ids'], ['doc-a', 'doc-b']);
      });

      test('should serialize DTO with only required fields', () {
        final dto = NotebookCreate(
          title: 'Minimal',
          content: 'Content',
        );

        final model = NotebookCreateModel.fromDomain(dto);
        final json = model.toJson();

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
        final quickDto = NotebookCreate(
          title: 'Quick',
          content: 'Content',
          type: NotebookType.quick,
        );

        final reminderDto = NotebookCreate(
          title: 'Reminder',
          content: 'Content',
          type: NotebookType.reminder,
        );

        final organizedDto = NotebookCreate(
          title: 'Organized',
          content: 'Content',
          type: NotebookType.organized,
        );

        expect(
          NotebookCreateModel.fromDomain(quickDto).toJson()['type'],
          'quick',
        );
        expect(
          NotebookCreateModel.fromDomain(reminderDto).toJson()['type'],
          'reminder',
        );
        expect(
          NotebookCreateModel.fromDomain(organizedDto).toJson()['type'],
          'organized',
        );
      });

      test('should serialize null type as null', () {
        final dto = NotebookCreate(
          title: 'No Type',
          content: 'Content',
          type: null,
        );

        final json = NotebookCreateModel.fromDomain(dto).toJson();
        expect(json['type'], isNull);
      });
    });

    group('Round-trip Conversion', () {
      test(
        'should maintain data integrity in JSON -> Model -> JSON conversion',
        () {
          final originalJson = {
            'title': 'Round Trip Test',
            'content': 'Test Content',
            'project_id': 'project-rt',
            'parent_id': null,
            'tags': ['test', 'roundtrip'],
            'type': 'quick',
            'reminder_date': DateTime(2026, 5, 20).toIso8601String(),
            'notify_on_reminder': true,
            'document_ids': ['doc-rt'],
          };

          final model = NotebookCreateModel.fromJson(originalJson);
          final convertedJson = model.toJson();

          expect(convertedJson['title'], originalJson['title']);
          expect(convertedJson['content'], originalJson['content']);
          expect(convertedJson['project_id'], originalJson['project_id']);
          expect(convertedJson['parent_id'], originalJson['parent_id']);
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

      test('should handle minimal round-trip', () {
        final originalJson = {
          'title': 'Minimal',
          'content': 'Content',
        };

        final model = NotebookCreateModel.fromJson(originalJson);
        final convertedJson = model.toJson();

        expect(convertedJson['title'], originalJson['title']);
        expect(convertedJson['content'], originalJson['content']);
      });
    });

    group('fromDomain and toDomain', () {
      test('should convert from domain DTO correctly', () {
        final dto = NotebookCreate(
          title: 'Domain Test',
          content: 'Test Content',
          projectId: 'project-123',
          type: NotebookType.organized,
          tags: ['test'],
        );

        final model = NotebookCreateModel.fromDomain(dto);
        final convertedDto = model.toDomain();

        expect(convertedDto.title, dto.title);
        expect(convertedDto.content, dto.content);
        expect(convertedDto.projectId, dto.projectId);
        expect(convertedDto.type, dto.type);
        expect(convertedDto.tags, dto.tags);
      });

      test('toDomain should return wrapped DTO', () {
        final dto = NotebookCreate(
          title: 'Test',
          content: 'Content',
        );

        final model = NotebookCreateModel(dto);
        expect(model.toDomain(), same(dto));
      });
    });

    group('Equality and HashCode', () {
      test('should be equal when wrapping same DTO', () {
        final dto = NotebookCreate(
          title: 'Test',
          content: 'Content',
        );

        final model1 = NotebookCreateModel(dto);
        final model2 = NotebookCreateModel(dto);

        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should be equal when wrapping equivalent DTOs', () {
        final dto1 = NotebookCreate(
          title: 'Test',
          content: 'Content',
          type: NotebookType.quick,
        );

        final dto2 = NotebookCreate(
          title: 'Test',
          content: 'Content',
          type: NotebookType.quick,
        );

        final model1 = NotebookCreateModel(dto1);
        final model2 = NotebookCreateModel(dto2);

        expect(model1, equals(model2));
      });

      test('should not be equal when DTOs differ', () {
        final dto1 = NotebookCreate(
          title: 'Test 1',
          content: 'Content',
        );

        final dto2 = NotebookCreate(
          title: 'Test 2',
          content: 'Content',
        );

        final model1 = NotebookCreateModel(dto1);
        final model2 = NotebookCreateModel(dto2);

        expect(model1, isNot(equals(model2)));
      });
    });

    group('toString', () {
      test('should include DTO toString', () {
        final dto = NotebookCreate(
          title: 'Test Notebook',
          content: 'Content',
        );

        final model = NotebookCreateModel(dto);
        final str = model.toString();

        expect(str, contains('NotebookCreateModel'));
        expect(str, contains('Test Notebook'));
      });
    });
  });
}
