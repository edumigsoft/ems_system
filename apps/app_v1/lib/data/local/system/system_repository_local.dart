// import 'package:core_shared/core_shared.dart'
//     show Result, Unit, Success, successOfUnit;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class SystemRepositoryLocal with Loggable implements SystemRepository {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   @override
//   Future<Result<System>> getSystem() async {
//     logger.info('getSystem()');

//     late System system;
//     final result = await _storage.read(key: 'system');

//     if (result == null) {
//       system = System.empty();

//       await saveSystem(system);

//       return Success(system);
//     }

//     final model = SystemModel.fromJson(result);

//     return Success(model.toEntity());
//   }

//   @override
//   Future<Result<Unit>> saveSystem(System system) async {
//     logger.info('saveSystem()');

//     final systemModel = SystemModel.fromEntity(system);

//     await _storage.write(key: 'system', value: systemModel.toJson());

//     return successOfUnit();
//   }
// }
