import 'package:zard/zard.dart';

void main() {
  final schema = z.map({
    'name': z.string().min(2),
  });

  final result = schema.safeParse({'name': 'a'});
  print('Result type: ${result.runtimeType}');

  if (!result.success) {
    // Vamos tentar acessar propriedades comuns de erro via dynamic para descobrir o nome correto
    try {
      print('Issues: ${(result as dynamic).issues}');
    } catch (e) {
      print('No issues property: $e');
    }

    try {
      print('Errors: ${(result as dynamic).errors}');
    } catch (e) {
      print('No errors property: $e');
    }

    try {
      print('Error: ${(result as dynamic).error}');
    } catch (e) {
      print('No error property: $e');
    }
  }
}
