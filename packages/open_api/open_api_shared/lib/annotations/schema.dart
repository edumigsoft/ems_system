class Model {
  final String name;
  final String description;

  const Model({required this.name, this.description = ''});
}

class Property {
  final String description;
  final String? ref;
  final bool required;

  const Property({required this.description, this.ref, this.required = false});
}
