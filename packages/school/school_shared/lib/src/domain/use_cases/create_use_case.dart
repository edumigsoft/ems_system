import 'package:core_shared/core_shared.dart';
import '../repositories/school_repository.dart';
import '../entities/school_details.dart';
import '../dtos/school_create.dart';

class CreateUseCase {
  final SchoolRepository _repository;

  CreateUseCase({required SchoolRepository repository})
    : _repository = repository;

  Future<Result<SchoolDetails>> execute(SchoolDetails school) async {
    final create = SchoolCreate(
      name: school.name,
      address: school.address,
      phone: school.phone,
      email: school.email,
      cie: school.cie,
    );

    return await _repository.create(create);
  }
}
