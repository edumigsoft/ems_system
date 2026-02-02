import 'package:core_shared/core_shared.dart' show BaseDetails;
import '../enums/school_enum.dart';
import 'school.dart';

class SchoolDetails implements BaseDetails {
  @override
  final String id;
  @override
  final bool isDeleted;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final School data;

  SchoolDetails({
    required this.id,
    this.isDeleted = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required String name,
    required String address,
    required String phone,
    required String email,
    required String code,
    required String locationCity,
    required String locationDistrict,
    required String director,
    required SchoolStatus status,
  }) : data = School(
         name: name,
         address: address,
         phone: phone,
         email: email,
         code: code,
         locationCity: locationCity,
         locationDistrict: locationDistrict,
         director: director,
         status: status,
       );

  // Factory constructor para criar a partir de dados brutos
  factory SchoolDetails.fromData({
    required String id,
    bool isDeleted = false,
    bool isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    required School data,
  }) {
    final now = DateTime.now();
    return SchoolDetails(
      id: id,
      isDeleted: isDeleted,
      isActive: isActive,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      name: data.name,
      address: data.address,
      phone: data.phone,
      email: data.email,
      code: data.code,
      locationCity: data.locationCity,
      locationDistrict: data.locationDistrict,
      director: data.director,
      status: data.status,
    );
  }

  // Factory constructor para criar instância vazia
  factory SchoolDetails.empty() {
    final now = DateTime.now();
    return SchoolDetails(
      id: '',
      isDeleted: false,
      isActive: true,
      createdAt: now,
      updatedAt: now,
      name: '',
      address: '',
      phone: '',
      email: '',
      code: '',
      locationCity: '',
      locationDistrict: '',
      director: '',
      status: SchoolStatus.active,
    );
  }

  // Método copyWith
  SchoolDetails copyWith({
    String? id,
    bool? isDeleted,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? code,
    String? locationCity,
    String? locationDistrict,
    String? director,
    SchoolStatus? status,
  }) {
    return SchoolDetails(
      id: id ?? this.id,
      isDeleted: isDeleted ?? this.isDeleted,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      code: code ?? this.code,
      locationCity: locationCity ?? this.locationCity,
      locationDistrict: locationDistrict ?? this.locationDistrict,
      director: director ?? this.director,
      status: status ?? this.status,
    );
  }

  // Getters de conveniência
  String get name => data.name;
  String get address => data.address;
  String get phone => data.phone;
  String get email => data.email;
  String get code => data.code;
  String get locationCity => data.locationCity;
  String get locationDistrict => data.locationDistrict;
  String get director => data.director;
  SchoolStatus get status => data.status;

  // Factory constructor para Drift (ORM)
  factory SchoolDetails.create({
    required String id,
    required bool isDeleted,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String name,
    required String address,
    required String phone,
    required String email,
    required String code,
    required String locationCity,
    required String locationDistrict,
    required String director,
    required SchoolStatus status,
  }) {
    return SchoolDetails(
      id: id,
      isDeleted: isDeleted,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      name: name,
      address: address,
      phone: phone,
      email: email,
      code: code,
      locationCity: locationCity,
      locationDistrict: locationDistrict,
      director: director,
      status: status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchoolDetails &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
