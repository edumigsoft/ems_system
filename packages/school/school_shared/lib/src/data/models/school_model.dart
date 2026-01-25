import 'package:open_api_shared/open_api_shared.dart'
    show apiModel, Model, Property;
import '../../domain/entities/school_data.dart';

@apiModel
@Model(name: 'SchoolModel', description: 'Dados de uma Escola.')
class SchoolModel {
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

  SchoolModel({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.cie,
  });

  factory SchoolModel.fromDomain(SchoolData entity) {
    return SchoolModel(
      name: entity.name,
      address: entity.address,
      phone: entity.phone,
      email: entity.email,
      cie: entity.cie,
    );
  }

  SchoolData toDomain() {
    return SchoolData(
      name: name,
      address: address,
      phone: phone,
      email: email,
      cie: cie,
    );
  }

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
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
