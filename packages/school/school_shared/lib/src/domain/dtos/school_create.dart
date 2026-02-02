import '../enums/school_enum.dart';

class SchoolCreate {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String code;
  final String locationCity;
  final String locationDistrict;
  final String director;
  final SchoolStatus status;

  const SchoolCreate({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.code,
    required this.locationCity,
    required this.locationDistrict,
    required this.director,
    required this.status,
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
