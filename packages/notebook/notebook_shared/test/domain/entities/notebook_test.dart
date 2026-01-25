import 'package:test/test.dart';
import 'package:notebook_shared/notebook_shared.dart';

void main() {
  group('Notebook', () {
    group('Constructor', () {
      test('should create instance with required fields only', () {
        final notebook = Notebook(
          title: 'Test Title',
          content: 'Test Content',
        );

        expect(notebook.title, 'Test Title');
        expect(notebook.content, 'Test Content');
        expect(notebook.projectId, isNull);
        expect(notebook.parentId, isNull);
        expect(notebook.tags, isNull);
        expect(notebook.type, isNull);
        expect(notebook.reminderDate, isNull);
        expect(notebook.notifyOnReminder, isNull);
      });

      test('should create instance with all fields', () {
        final reminderDate = DateTime(2026, 2, 1);
        final notebook = Notebook(
          title: 'Complete Notebook',
          content: 'Full Content',
          projectId: 'project-123',
          parentId: 'parent-456',
          tags: ['tag1', 'tag2'],
          type: NotebookType.organized,
          reminderDate: reminderDate,
          notifyOnReminder: true,
        );

        expect(notebook.title, 'Complete Notebook');
        expect(notebook.content, 'Full Content');
        expect(notebook.projectId, 'project-123');
        expect(notebook.parentId, 'parent-456');
        expect(notebook.tags, ['tag1', 'tag2']);
        expect(notebook.type, NotebookType.organized);
        expect(notebook.reminderDate, reminderDate);
        expect(notebook.notifyOnReminder, true);
      });
    });

    group('Type Getters', () {
      test('isQuickNote should return true for quick type', () {
        final notebook = Notebook(
          title: 'Quick',
          content: 'Content',
          type: NotebookType.quick,
        );

        expect(notebook.isQuickNote, isTrue);
        expect(notebook.isReminder, isFalse);
        expect(notebook.isOrganized, isFalse);
      });

      test('isReminder should return true for reminder type', () {
        final notebook = Notebook(
          title: 'Reminder',
          content: 'Content',
          type: NotebookType.reminder,
        );

        expect(notebook.isReminder, isTrue);
        expect(notebook.isQuickNote, isFalse);
        expect(notebook.isOrganized, isFalse);
      });

      test('isOrganized should return true for organized type', () {
        final notebook = Notebook(
          title: 'Organized',
          content: 'Content',
          type: NotebookType.organized,
        );

        expect(notebook.isOrganized, isTrue);
        expect(notebook.isQuickNote, isFalse);
        expect(notebook.isReminder, isFalse);
      });

      test('all type getters should return false when type is null', () {
        final notebook = Notebook(
          title: 'No Type',
          content: 'Content',
        );

        expect(notebook.isQuickNote, isFalse);
        expect(notebook.isReminder, isFalse);
        expect(notebook.isOrganized, isFalse);
      });
    });

    group('Relationship Getters', () {
      test('hasChildren should return true when parentId is null', () {
        final notebook = Notebook(
          title: 'Parent',
          content: 'Content',
        );

        expect(notebook.hasChildren, isTrue);
      });

      test('hasChildren should return false when parentId is set', () {
        final notebook = Notebook(
          title: 'Child',
          content: 'Content',
          parentId: 'parent-123',
        );

        expect(notebook.hasChildren, isFalse);
      });

      test('hasProject should return true when projectId is set', () {
        final notebook = Notebook(
          title: 'Project Note',
          content: 'Content',
          projectId: 'project-123',
        );

        expect(notebook.hasProject, isTrue);
      });

      test('hasProject should return false when projectId is null', () {
        final notebook = Notebook(
          title: 'No Project',
          content: 'Content',
        );

        expect(notebook.hasProject, isFalse);
      });
    });

    group('Tags Getters', () {
      test('hasTags should return true when tags list is not empty', () {
        final notebook = Notebook(
          title: 'Tagged',
          content: 'Content',
          tags: ['tag1', 'tag2'],
        );

        expect(notebook.hasTags, isTrue);
      });

      test('hasTags should return false when tags is null', () {
        final notebook = Notebook(
          title: 'No Tags',
          content: 'Content',
        );

        expect(notebook.hasTags, isFalse);
      });

      test('hasTags should return false when tags list is empty', () {
        final notebook = Notebook(
          title: 'Empty Tags',
          content: 'Content',
          tags: [],
        );

        expect(notebook.hasTags, isFalse);
      });
    });

    group('Reminder Getters', () {
      test('hasReminder should return true when reminderDate is set', () {
        final notebook = Notebook(
          title: 'With Reminder',
          content: 'Content',
          reminderDate: DateTime(2026, 2, 1),
        );

        expect(notebook.hasReminder, isTrue);
      });

      test('hasReminder should return false when reminderDate is null', () {
        final notebook = Notebook(
          title: 'No Reminder',
          content: 'Content',
        );

        expect(notebook.hasReminder, isFalse);
      });

      test('isReminderOverdue should return true for past date', () {
        final pastDate = DateTime.now().subtract(Duration(days: 1));
        final notebook = Notebook(
          title: 'Overdue',
          content: 'Content',
          reminderDate: pastDate,
        );

        expect(notebook.isReminderOverdue, isTrue);
      });

      test('isReminderOverdue should return false for future date', () {
        final futureDate = DateTime.now().add(Duration(days: 1));
        final notebook = Notebook(
          title: 'Future',
          content: 'Content',
          reminderDate: futureDate,
        );

        expect(notebook.isReminderOverdue, isFalse);
      });

      test(
        'isReminderOverdue should return false when reminderDate is null',
        () {
          final notebook = Notebook(
            title: 'No Reminder',
            content: 'Content',
          );

          expect(notebook.isReminderOverdue, isFalse);
        },
      );
    });

    group('Validation Getters', () {
      test('hasValidTitle should return true for non-empty title', () {
        final notebook = Notebook(
          title: 'Valid Title',
          content: 'Content',
        );

        expect(notebook.hasValidTitle, isTrue);
      });

      test('hasValidTitle should return false for empty title', () {
        final notebook = Notebook(
          title: '',
          content: 'Content',
        );

        expect(notebook.hasValidTitle, isFalse);
      });

      test('hasValidTitle should return false for whitespace-only title', () {
        final notebook = Notebook(
          title: '   ',
          content: 'Content',
        );

        expect(notebook.hasValidTitle, isFalse);
      });

      test('displayName should return trimmed title', () {
        final notebook = Notebook(
          title: '  Trimmed Title  ',
          content: 'Content',
        );

        expect(notebook.displayName, 'Trimmed Title');
      });
    });

    group('Equality and HashCode', () {
      test('should be equal when all fields match', () {
        final notebook1 = Notebook(
          title: 'Title',
          content: 'Content',
          projectId: 'project-1',
          tags: ['tag1', 'tag2'],
        );

        final notebook2 = Notebook(
          title: 'Title',
          content: 'Content',
          projectId: 'project-1',
          tags: ['tag1', 'tag2'],
        );

        expect(notebook1, equals(notebook2));
        expect(notebook1.hashCode, equals(notebook2.hashCode));
      });

      test('should not be equal when title differs', () {
        final notebook1 = Notebook(
          title: 'Title 1',
          content: 'Content',
        );

        final notebook2 = Notebook(
          title: 'Title 2',
          content: 'Content',
        );

        expect(notebook1, isNot(equals(notebook2)));
      });

      test('should not be equal when content differs', () {
        final notebook1 = Notebook(
          title: 'Title',
          content: 'Content 1',
        );

        final notebook2 = Notebook(
          title: 'Title',
          content: 'Content 2',
        );

        expect(notebook1, isNot(equals(notebook2)));
      });

      test('should not be equal when tags differ', () {
        final notebook1 = Notebook(
          title: 'Title',
          content: 'Content',
          tags: ['tag1', 'tag2'],
        );

        final notebook2 = Notebook(
          title: 'Title',
          content: 'Content',
          tags: ['tag1', 'tag3'],
        );

        expect(notebook1, isNot(equals(notebook2)));
      });

      test('should be equal with null tags vs null tags', () {
        final notebook1 = Notebook(
          title: 'Title',
          content: 'Content',
        );

        final notebook2 = Notebook(
          title: 'Title',
          content: 'Content',
          tags: null,
        );

        expect(notebook1, equals(notebook2));
      });

      test('should not be equal with null tags vs empty list', () {
        final notebook1 = Notebook(
          title: 'Title',
          content: 'Content',
          tags: null,
        );

        final notebook2 = Notebook(
          title: 'Title',
          content: 'Content',
          tags: [],
        );

        expect(notebook1, isNot(equals(notebook2)));
      });

      test('should not be equal when type differs', () {
        final notebook1 = Notebook(
          title: 'Title',
          content: 'Content',
          type: NotebookType.quick,
        );

        final notebook2 = Notebook(
          title: 'Title',
          content: 'Content',
          type: NotebookType.organized,
        );

        expect(notebook1, isNot(equals(notebook2)));
      });

      test('should not be equal when reminderDate differs', () {
        final notebook1 = Notebook(
          title: 'Title',
          content: 'Content',
          reminderDate: DateTime(2026, 1, 1),
        );

        final notebook2 = Notebook(
          title: 'Title',
          content: 'Content',
          reminderDate: DateTime(2026, 1, 2),
        );

        expect(notebook1, isNot(equals(notebook2)));
      });
    });

    group('toString', () {
      test('should include title and type', () {
        final notebook = Notebook(
          title: 'Test Notebook',
          content: 'Content',
          type: NotebookType.quick,
        );

        expect(
          notebook.toString(),
          equals('Notebook(title: Test Notebook, type: NotebookType.quick)'),
        );
      });

      test('should show null type when not set', () {
        final notebook = Notebook(
          title: 'Test Notebook',
          content: 'Content',
        );

        expect(
          notebook.toString(),
          equals('Notebook(title: Test Notebook, type: null)'),
        );
      });
    });

    group('_listEquals Helper', () {
      test('should return true for two null lists', () {
        final notebook1 = Notebook(title: 'A', content: 'B');
        final notebook2 = Notebook(title: 'A', content: 'B');

        expect(notebook1, equals(notebook2));
      });

      test('should return false when one list is null', () {
        final notebook1 = Notebook(
          title: 'A',
          content: 'B',
          tags: ['tag'],
        );
        final notebook2 = Notebook(title: 'A', content: 'B');

        expect(notebook1, isNot(equals(notebook2)));
      });

      test('should return false for lists of different lengths', () {
        final notebook1 = Notebook(
          title: 'A',
          content: 'B',
          tags: ['tag1', 'tag2'],
        );
        final notebook2 = Notebook(
          title: 'A',
          content: 'B',
          tags: ['tag1'],
        );

        expect(notebook1, isNot(equals(notebook2)));
      });

      test('should return false for different element order', () {
        final notebook1 = Notebook(
          title: 'A',
          content: 'B',
          tags: ['tag1', 'tag2'],
        );
        final notebook2 = Notebook(
          title: 'A',
          content: 'B',
          tags: ['tag2', 'tag1'],
        );

        expect(notebook1, isNot(equals(notebook2)));
      });

      test('should return true for identical lists', () {
        final notebook1 = Notebook(
          title: 'A',
          content: 'B',
          tags: ['tag1', 'tag2'],
        );
        final notebook2 = Notebook(
          title: 'A',
          content: 'B',
          tags: ['tag1', 'tag2'],
        );

        expect(notebook1, equals(notebook2));
      });
    });
  });
}
