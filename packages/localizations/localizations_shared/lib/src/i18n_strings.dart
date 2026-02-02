/// Interface abstrata para todas as strings traduzíveis do sistema.
///
/// Esta interface deve ser implementada por:
/// - Classes manuais em `localizations_server` (PtBrStrings, EnUsStrings, etc)
/// - Classe gerada AppLocalizations em `localizations_ui`
/// - Qualquer outro provider customizado
abstract class I18nStrings {
  // ========== Mensagens Gerais ==========

  String get appName;
  String get welcomeMessage;
  String get errorGeneric;

  // ========== Mensagens com Parâmetros ==========

  String loginError(String reason);
  String serverErrorLog(String error);
  String emailSubjectWelcome(String userName);

  // ========== Pluralização ==========

  String itemCount(int count);

  // ========== Formatação de Data ==========

  String lastUpdated(DateTime date);

  // ========== Botões ==========

  String get buttonSave;
  String get buttonCancel;
  String get buttonConfirm;
  String get buttonDelete;

  // ========== Validações ==========

  String get validationEmailInvalid;
  String get validationPasswordTooShort;
  String get validationRequired;

  // ========== School Management ==========

  String get school;
  String get schools;
  String get editSchool;
  String get createSchool;
  String get cie;

  // ========== Adicione novos métodos aqui ==========
  //
  // IMPORTANTE: Sempre que adicionar um novo método aqui:
  // 1. Atualize TODOS os arquivos .arb em localizations_ui/l10n/
  // 2. Atualize TODAS as implementações em localizations_server/strings/
  // 3. Execute `flutter gen-l10n` para regenerar AppLocalizations
}
