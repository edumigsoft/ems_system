import 'dart:core';

class Response {
  final int statusCode;
  final String description;
  final String contentType;
  final Type returns;

  const Response({
    required this.statusCode,
    this.description = '',
    this.contentType = 'application/json',
    required this.returns,
  });
}
