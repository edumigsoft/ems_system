import 'package:core_shared/core_shared.dart' show BaseDetails;
import 'school_data.dart';

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
  final SchoolData data;

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
    required String cie,
  }) : data = SchoolData(
         name: name,
         address: address,
         phone: phone,
         email: email,
         cie: cie,
       );

  // Factory constructor para criar a partir de dados brutos
  factory SchoolDetails.fromData({
    required String id,
    bool isDeleted = false,
    bool isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    required SchoolData data,
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
      cie: data.cie,
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
      cie: '',
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
    String? cie,
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
      cie: cie ?? this.cie,
    );
  }

  // Getters de conveniência
  String get name => data.name;
  String get address => data.address;
  String get phone => data.phone;
  String get email => data.email;
  String get cie => data.cie;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchoolDetails &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
