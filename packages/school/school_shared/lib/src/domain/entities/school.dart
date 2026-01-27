import '../../../school_shared.dart';

class School {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String code; // cie
  final String locationCity;
  final String locationDistrict;
  final String director;
  final SchoolStatus status;

  School({
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
}
