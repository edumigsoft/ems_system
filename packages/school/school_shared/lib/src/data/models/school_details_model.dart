import 'package:open_api_shared/open_api_shared.dart'
    show apiModel, Model, Property;
import '../../domain/entities/school_details.dart';
import 'school_model.dart';

@apiModel
@Model(
  name: 'SchoolDetailsModel',
  description: 'Detalhes de uma Escola.',
)
class SchoolDetailsModel {
  @Property(description: 'School Id', required: true)
  final String id;
  @Property(description: 'Is Active', required: true)
  final bool isActive;
  @Property(description: 'Created At', required: false)
  final DateTime? createdAt;
  @Property(description: 'Updated At', required: false)
  final DateTime? updatedAt;
  @Property(description: 'Deleted', required: true)
  final bool isDeleted;
  @Property(description: 'School Data', required: true, ref: 'SchoolModel')
  final SchoolModel data;

  SchoolDetailsModel({
    required this.id,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    required this.isDeleted,
    required this.data,
  });

  factory SchoolDetailsModel.fromDomain(SchoolDetails entity) {
    return SchoolDetailsModel(
      id: entity.id,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isDeleted: entity.isDeleted,
      data: SchoolModel.fromDomain(entity.data),
    );
  }

  SchoolDetails toDomain() {
    return SchoolDetails.fromData(
      id: id,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      data: data.toDomain(),
    );
  }

  factory SchoolDetailsModel.fromJson(Map<String, dynamic> json) {
    return SchoolDetailsModel(
      id: json['id'] as String,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isDeleted: json['is_deleted'] as bool,
      data: SchoolModel.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      ...data.toJson(),
    };
  }
}
