class Project {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;

  // Campos OPCIONAIS - permitem evolução progressiva
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? client;
  final ProjectStatus? status;
  final List<String>? tags;
  final DateTime? updatedAt;

  const Project({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    this.description,
    this.startDate,
    this.endDate,
    this.client,
    this.status,
    this.tags,
    this.updatedAt,
  });

  /// Verifica se o projeto tem informações completas
  bool get isComplete =>
      description != null && startDate != null && client != null;

  /// Verifica se o projeto é "simples" (apenas campos básicos)
  bool get isSimple =>
      description == null && startDate == null && client == null;

  /// Cria uma cópia com novos valores (imutabilidade)
  Project copyWith({
    String? name,
    String? color,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? client,
    ProjectStatus? status,
    List<String>? tags,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      client: client ?? this.client,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      updatedAt: DateTime.now(),
    );
  }
}
