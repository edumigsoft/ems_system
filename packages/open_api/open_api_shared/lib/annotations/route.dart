class ApiInfo {
  final String title;
  final String? version;
  final String? description;

  const ApiInfo({required this.title, this.version, this.description});
}

class Tags {
  final String name;
  final String description;

  const Tags({required this.name, required this.description});
}

class Route {
  final String path;
  // final String method;
  // final String summary;
  final String description;
  // final List<String>? tags;
  final String tag;

  const Route({
    required this.path,
    // required this.method,
    // required this.summary,
    required this.description,
    required this.tag,
  });
}

class Get {
  final String path;
  final String summary;
  final String? description;
  // final List<String>? tags;

  const Get({
    required this.path,
    required this.summary,
    this.description,
    // this.tags,
  });
}

class Post {
  final String path;
  final String summary;
  final String? description;
  final List<String>? tags;

  const Post({
    required this.path,
    required this.summary,
    this.description,
    this.tags,
  });
}

class Put {
  final String path;
  final String summary;
  final String? description;
  final List<String>? tags;

  const Put({
    required this.path,
    required this.summary,
    this.description,
    this.tags,
  });
}

class Delete {
  final String path;
  final String summary;
  final String? description;
  final List<String>? tags;

  const Delete({
    required this.path,
    required this.summary,
    this.description,
    this.tags,
  });
}
