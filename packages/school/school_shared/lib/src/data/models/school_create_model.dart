import 'package:open_api_shared/open_api_shared.dart'
    show apiModel, Model, Property;

import '../../domain/dtos/school_create.dart';

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
  final String cie;

  SchoolCreateModel({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.cie,
  });

  factory SchoolCreateModel.fromDomain(SchoolCreate entity) {
    return SchoolCreateModel(
      name: entity.name,
      address: entity.address,
      phone: entity.phone,
      email: entity.email,
      cie: entity.cie,
    );
  }

  SchoolCreate toDomain() {
    return SchoolCreate(
      name: name,
      address: address,
      phone: phone,
      email: email,
      cie: cie,
    );
  }

  factory SchoolCreateModel.fromJson(Map<String, dynamic> json) {
    return SchoolCreateModel(
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      cie: json['cie'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'cie': cie,
    };
  }
}
