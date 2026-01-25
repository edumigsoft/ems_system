class SchoolCreate {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String cie;

  const SchoolCreate({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.cie,
  });

  // Validação de negócio
  bool get isValid => name.isNotEmpty && email.contains('@');

  String? validate() {
    if (name.isEmpty) return 'Nome da escola é obrigatório';
    if (!email.contains('@')) {
      return 'Email inválido';
    }
    return null;
  }
}
