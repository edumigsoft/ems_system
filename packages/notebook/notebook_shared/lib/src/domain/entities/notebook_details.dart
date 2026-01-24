import 'package:core_shared/core_shared.dart';

import '../enums/notebook_type.dart';
import 'notebook.dart';

/// EntityDetails para Notebook - Agregação completa com metadados de persistência
///
/// Implementa [BaseDetails] contendo todos os campos de [DriftTableMixinPostgres]
/// e compõe a entidade de domínio [Notebook] através do campo [data].
class NotebookDetails implements BaseDetails {
  // Campos do BaseDetails (alinhados com DriftTableMixinPostgres)
  @override
  final String id;
  @override
  final bool isDeleted;
  @override
  final bool isActive;
  @override
  final DateTime createdAt; // NOT NULL - tem default no DB
  @override
  final DateTime updatedAt; // NOT NULL - tem default no DB

  // Composição da Entity de negócio
  final Notebook data;

  // Lista de IDs de documentos anexados (relacionamento)
  final List<String>? documentIds;

  NotebookDetails({
    required this.id,
    this.isDeleted = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required String title,
    required String content,
    String? projectId,
    String? parentId,
    List<String>? tags,
    NotebookType? type,
    DateTime? reminderDate,
    bool? notifyOnReminder,
    this.documentIds,
  }) : data = Notebook(
          title: title,
          content: content,
          projectId: projectId,
          parentId: parentId,
          tags: tags,
          type: type,
          reminderDate: reminderDate,
          notifyOnReminder: notifyOnReminder,
        );

  // Getters de conveniência para campos da Entity
  String get title => data.title;
  String get content => data.content;
  String? get projectId => data.projectId;
  String? get parentId => data.parentId;
  List<String>? get tags => data.tags;
  NotebookType? get type => data.type;
  DateTime? get reminderDate => data.reminderDate;
  bool? get notifyOnReminder => data.notifyOnReminder;

  // Acesso à lógica de negócio da Entity
  bool get isQuickNote => data.isQuickNote;
  bool get isReminder => data.isReminder;
  bool get isOrganized => data.isOrganized;
  bool get hasChildren => data.hasChildren;
  bool get hasProject => data.hasProject;
  bool get hasTags => data.hasTags;
  bool get hasReminder => data.hasReminder;
  bool get isReminderOverdue => data.isReminderOverdue;
  bool get hasValidTitle => data.hasValidTitle;
  String get displayName => data.displayName;

  // Verifica se tem documentos anexados
  bool get hasDocuments => documentIds != null && documentIds!.isNotEmpty;

  /// Quantidade de documentos anexados
  int get documentsCount => documentIds?.length ?? 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotebookDetails &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'NotebookDetails(id: $id, title: $title, type: $type)';
}
