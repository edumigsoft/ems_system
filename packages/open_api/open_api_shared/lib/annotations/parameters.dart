class Body {
  const Body();
}

class PathParam {
  final String name;
  final String type;
  final String description;
  final bool required;

  const PathParam({
    required this.name,
    this.type = 'string',
    this.description = '',
    this.required = true,
  });
}

class QueryParam {
  final String name;
  const QueryParam(this.name);
}
