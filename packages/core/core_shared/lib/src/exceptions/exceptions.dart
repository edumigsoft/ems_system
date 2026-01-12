abstract class BaseException implements Exception {
  final String message;
  final StackTrace? stackTrace;
  final int? statusCode;

  BaseException(this.message, {this.stackTrace, this.statusCode});

  @override
  String toString() {
    final text = '$runtimeType: $message';
    String extra = '';

    if (stackTrace != null) {
      extra = '\nStack Trace: $stackTrace';
    }

    if (statusCode != null) {
      extra = '\nStatus Code: $statusCode';
    }

    return '$text$extra';
  }
}

class DataException extends BaseException {
  DataException(super.message, {super.stackTrace, super.statusCode});
}

class StorageException extends DataException {
  StorageException(super.message, {super.stackTrace, super.statusCode});
}

class LoginException extends DataException {
  LoginException(super.message, {super.stackTrace, super.statusCode});
}
