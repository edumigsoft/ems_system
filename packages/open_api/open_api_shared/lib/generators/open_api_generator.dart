import 'dart:convert';

import 'package:reflectable/reflectable.dart';

import '../annotations/open_api_annotations.dart' show api, apiModel;
import '../annotations/parameters.dart' show PathParam;
import '../annotations/response.dart' show Response;
import '../annotations/route.dart' show ApiInfo, Route, Get, Post, Put, Delete;
import '../annotations/schema.dart' show Model, Property;

class OpenApiGenerator {
  final String _backendBaseApi;

  OpenApiGenerator({required String backendBaseApi})
    : _backendBaseApi = backendBaseApi;

  String _tag = '';
  String _path = '';
  final List<Map<String, dynamic>> _tagsList = [];
  final Map<String, dynamic> _openApiDoc = {
    'openapi': '3.0.0',
    'info': {
      'title': 'API Documentation',
      'version': '1.0.0',
      'description': 'Generated Swagger Documentation',
    },
    'tags': <dynamic>[],
    'paths': <String, dynamic>{},
    'components': {'schemas': <String, dynamic>{}},
  };

  void generateDoc() {
    // Reset state to avoid duplication in singleton
    _tagsList.clear();
    _openApiDoc['paths'] = <String, dynamic>{};
    _openApiDoc['tags'] = <dynamic>[];
    _openApiDoc['components'] = {'schemas': <String, dynamic>{}};

    final classes = api.annotatedClasses;

    final classesTypes = classes.map((classInfo) {
      return (classInfo).reflectedType;
    }).toList();

    _generateFromControllers(classesTypes);
    _generateSchemasFromModels();
  }

  void _generateFromControllers(List<Type> controllers) {
    for (final controllerType in controllers) {
      _processController(controllerType);
    }
  }

  void _processController(Type controllerType) {
    final classMirror = api.reflectType(controllerType) as ClassMirror;

    final apiAnnotation = _getAnnotation<ApiInfo>(classMirror.metadata);
    if (apiAnnotation != null) {
      (_openApiDoc['info'] as Map<String, dynamic>)['title'] =
          apiAnnotation.title;
      (_openApiDoc['info'] as Map<String, dynamic>)['version'] =
          apiAnnotation.version;

      if (apiAnnotation.description != null) {
        (_openApiDoc['info'] as Map<String, dynamic>)['description'] =
            apiAnnotation.description;
      }
    }

    final routeAnnotation = _getAnnotation<Route>(classMirror.metadata);
    if (routeAnnotation != null) {
      final String newTagName = routeAnnotation.tag;
      final String newTagDescription = routeAnnotation.description;

      final bool tagExists = _tagsList.any((tag) => tag['name'] == newTagName);

      if (!tagExists) {
        final Map<String, dynamic> newTag = {
          'name': newTagName,
          'description': newTagDescription,
        };
        _tagsList.add(newTag);
      }

      _tag = routeAnnotation.tag;

      _path = _backendBaseApi + routeAnnotation.path;
    }

    for (final declaration in classMirror.declarations.values) {
      if (declaration is MethodMirror && declaration.isRegularMethod) {
        _processMethod(declaration);
      }
    }

    _openApiDoc['tags'] = _tagsList;
  }

  void _processMethod(MethodMirror methodMirror) {
    final annotations = methodMirror.metadata;

    final Get? getAnnotation = _getAnnotation<Get>(annotations);
    final Post? postAnnotation = _getAnnotation<Post>(annotations);
    final Put? putAnnotation = _getAnnotation<Put>(annotations);
    final Delete? deleteAnnotation = _getAnnotation<Delete>(
      annotations,
    );

    final Response? responseAnnotation = _getAnnotation<Response>(
      annotations,
    );

    final PathParam? parametersAnnotation = _getAnnotation<PathParam>(
      annotations,
    );

    if (getAnnotation != null) {
      _addPathToSwagger(
        getAnnotation.path,
        'get',
        getAnnotation.summary,
        getAnnotation.description,
        methodMirror.simpleName,
        _generateParameters(parametersAnnotation),
        _generateResponse(responseAnnotation),
      );
    }

    if (postAnnotation != null) {
      _addPathToSwagger(
        postAnnotation.path,
        'post',
        postAnnotation.summary,
        postAnnotation.description,
        methodMirror.simpleName,
        _generateParameters(parametersAnnotation),
        _generateResponse(responseAnnotation),
      );
    }

    if (putAnnotation != null) {
      _addPathToSwagger(
        putAnnotation.path,
        'put',
        putAnnotation.summary,
        putAnnotation.description,
        methodMirror.simpleName,
        _generateParameters(parametersAnnotation),
        _generateResponse(responseAnnotation),
      );
    }

    if (deleteAnnotation != null) {
      _addPathToSwagger(
        deleteAnnotation.path,
        'delete',
        deleteAnnotation.summary,
        deleteAnnotation.description,
        methodMirror.simpleName,
        _generateParameters(parametersAnnotation),
        _generateResponse(responseAnnotation),
      );
    }
  }

  void _addPathToSwagger(
    String path,
    String method,
    String summary,
    String? description,
    String operationId,
    Map<String, dynamic> parameters,
    Map<String, dynamic> response,
  ) {
    final pathApi = '$_path$path';

    if (_openApiDoc['paths'] is Map) {
      (_openApiDoc['paths'] as Map)[pathApi] ??= <String, dynamic>{};
      ((_openApiDoc['paths'] as Map)[pathApi]
          as Map)[method] = <String, dynamic>{
        'summary': summary,
        'description': description ?? summary,
        'tags': <String>[_tag],
        'operationId': operationId,
        'parameters': parameters['parameters'],
        'responses': response,
      };
    }
  }

  Map<String, dynamic> _generateResponse(Response? response) {
    if (response == null) {
      return {
        '200': {
          'description': 'Successful operation',
          'content': {
            'application/json': {
              'schema': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  // "$ref": "#/components/schemas/User"
                },
              },
            },
          },
        },
      };
    } else {
      return {
        response.statusCode.toString(): {
          'description': response.description,
          'content': {
            response.contentType.toString(): {
              'schema': {'\$ref': "#/components/schemas/${response.returns}"},
            },
          },
        },
      };
    }
  }

  Map<String, dynamic> _generateParameters(PathParam? pathParam) {
    if (pathParam == null) {
      return {'parameters': <Map<String, dynamic>>[]};
    } else {
      return {
        'parameters': <Map<String, dynamic>>[
          {
            "name": pathParam.name,
            "in": "path",
            "required": pathParam.required,
            "description": pathParam.description,
            "schema": {"type": "string"},
          },
        ],
      };
    }
  }

  T? _getAnnotation<T>(List<dynamic> metadata) {
    for (final annotation in metadata) {
      if (annotation is T) {
        return annotation;
      }
    }

    return null;
  }

  String generateJson() {
    return JsonEncoder.withIndent('  ').convert(_openApiDoc);
  }

  Map<String, dynamic> generateMap() {
    return _openApiDoc;
  }

  void _generateSchemasFromModels() {
    final schemas = <String, dynamic>{};

    final modelClasses = apiModel.annotatedClasses;

    for (final classMirror in modelClasses) {
      final modelAnnotation = classMirror.metadata
          .whereType<Model>()
          .firstOrNull;

      if (modelAnnotation != null) {
        final className = classMirror.simpleName;
        final description = modelAnnotation.description;
        final properties = <String, dynamic>{};
        final required = <String>[];

        for (final field in classMirror.declarations.values) {
          // if (field is VariableMirror && field.isFinal) {
          if (field is VariableMirror) {
            final propAnnotation = field.metadata
                .whereType<Property>()
                .firstOrNull;

            if (propAnnotation != null) {
              final propName = field.simpleName;

              properties[propName] = {
                'type': _getSwaggerType(field.reflectedType),
                'description': propAnnotation.description,
                'required': propAnnotation.required,
                if (propAnnotation.ref != null)
                  '\$ref': '#/components/schemas/${propAnnotation.ref}',
              };

              if (propAnnotation.required) {
                required.add(propName);
              }
            }
          }
        }

        schemas[className] = {
          'type': 'object',
          'description': description,
          'properties': properties,
          if (required.isNotEmpty) 'required': required,
        };
      }
    }

    _openApiDoc['components'] = {'schemas': schemas};
  }

  String _getSwaggerType(Type type) {
    if (type == int || type == double) return 'number';
    if (type == String) return 'string';
    if (type == bool) return 'boolean';
    if (type == List) return 'array';
    // if (type == DateTime) return 'datetime';
    // ... adicione outros tipos conforme necessário
    return 'object';
  }
}
