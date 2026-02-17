// Conditional import para suportar múltiplas plataformas
// Usa dart:io em plataformas nativas (iOS, Android, Desktop)
// Usa implementação stub em web (sem acesso ao sistema de arquivos)

export 'log_service_stub.dart'
    if (dart.library.io) 'log_service_io.dart';
