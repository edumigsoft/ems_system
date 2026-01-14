// import 'dart:convert';

// import 'package:core_shared/core_shared.dart'
//     show
//         Result,
//         Unit,
//         StorageException,
//         Failure,
//         successOfUnit,
//         Success,
//         Loggable;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class AuthStorageServiceLocal with Loggable implements AuthStorageService {
//   final FlutterSecureStorage _flutterSecureStorage;

//   AuthStorageServiceLocal({required FlutterSecureStorage flutterSecureStorage})
//     : _flutterSecureStorage = flutterSecureStorage;

//   @override
//   Future<Result<Unit>> saveSession(AuthEntity auth) async {
//     try {
//       logger.info('saveSession()');

//       await _flutterSecureStorage.write(
//         key: sessionKey,
//         // Convert Entity to Model for serialization
//         value: json.encode(
//           AuthModel(
//             token: auth.token,
//             userId: auth.userId,
//             name: auth.name,
//             roles: auth.roles,
//             refreshToken: auth.refreshToken,
//             expiresAt: auth.expiresAt,
//             mustChangePassword: auth.mustChangePassword,
//           ).toJson(),
//         ),
//       );

//       return successOfUnit();
//     } on Exception catch (e, s) {
//       return Failure(StorageException(e.toString(), stackTrace: s));
//     }
//   }

//   @override
//   Future<Result<AuthEntity>> getSession() async {
//     try {
//       logger.info('getSession()');

//       final result = await _flutterSecureStorage.read(key: sessionKey);

//       if (result == null) {
//         return Failure(StorageException('Session not found'));
//       }

//       // Deserialize using Model
//       final session = AuthModel.fromString(result);

//       return Success(session);
//     } on Exception catch (e, s) {
//       return Failure(StorageException(e.toString(), stackTrace: s));
//     }
//   }

//   @override
//   Future<Result<Unit>> removeSession() async {
//     try {
//       logger.info('removeSession()');

//       await _flutterSecureStorage.delete(key: sessionKey);

//       return successOfUnit();
//     } on Exception catch (e, s) {
//       return Failure(StorageException(e.toString(), stackTrace: s));
//     }
//   }
// }
