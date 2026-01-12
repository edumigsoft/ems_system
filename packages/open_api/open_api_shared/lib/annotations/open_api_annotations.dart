import 'package:reflectable/reflectable.dart';

class Api extends Reflectable {
  const Api()
    : super(
        typeCapability,
        declarationsCapability,
        metadataCapability,
        invokingCapability,
        reflectedTypeCapability,
      );
}

const api = Api();

class ApiModel extends Reflectable {
  const ApiModel()
    : super(
        typeCapability,
        declarationsCapability,
        metadataCapability,
        invokingCapability,
        reflectedTypeCapability,
      );
}

const apiModel = ApiModel();
