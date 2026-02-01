import 'package:core_shared/core_shared.dart';
import '../repositories/user_repository.dart';
import '../entities/user_details.dart';

class GetProfileUseCase {
  final UserRepository _repository;

  GetProfileUseCase({required UserRepository repository})
    : _repository = repository;

  /// Busca o perfil do usuário autenticado atual.
  ///
  /// Não requer passar ID pois usa o token JWT para identificar o usuário.
  Future<Result<UserDetails>> execute() {
    return _repository.getCurrentProfile();
  }
}
