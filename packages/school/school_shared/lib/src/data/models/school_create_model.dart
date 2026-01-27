import 'package:open_api_shared/open_api_shared.dart'
    show apiModel, Model, Property;

import '../../domain/dtos/school_create.dart';
import '../../domain/enums/school_enum.dart';

@apiModel
@Model(name: 'SchoolCreate', description: 'Dados para criar uma Escola.')
class SchoolCreateModel {
  @Property(description: 'School Name', required: true)
  final String name;
  @Property(description: 'School Address', required: true)
  final String address;
  @Property(description: 'School Phone', required: true)
  final String phone;
  @Property(description: 'School Email', required: true)
  final String email;
  @Property(description: 'School CIE', required: true)
  final String code;
  @Property(description: 'School Location City', required: true)
  final String locationCity;
  @Property(description: 'School Location District', required: true)
  final String locationDistrict;
  @Property(description: 'School Director', required: true)
  final String director;
  @Property(description: 'School Status', required: true)
  final SchoolStatus status;

  SchoolCreateModel({
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

  factory SchoolCreateModel.fromDomain(SchoolCreate entity) {
    return SchoolCreateModel(
      name: entity.name,
      address: entity.address,
      phone: entity.phone,
      email: entity.email,
      code: entity.code,
      locationCity: entity.locationCity,
      locationDistrict: entity.locationDistrict,
      director: entity.director,
      status: entity.status,
    );
  }

  SchoolCreate toDomain() {
    return SchoolCreate(
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

  factory SchoolCreateModel.fromJson(Map<String, dynamic> json) {
    return SchoolCreateModel(
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      code: json['code'] as String,
      locationCity: json['location_city'] as String,
      locationDistrict: json['location_district'] as String,
      director: json['director'] as String,
      status: json['status'] as SchoolStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'code': code,
      'location_city': locationCity,
      'location_district': locationDistrict,
      'director': director,
      'status': status,
    };
  }
}
