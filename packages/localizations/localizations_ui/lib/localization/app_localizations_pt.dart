// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Minha Aplicação';

  @override
  String get welcomeMessage => 'Bem-vindo!';

  @override
  String get errorGeneric => 'Ocorreu um erro. Por favor, tente novamente.';

  @override
  String get users => 'Usuários';

  @override
  String get user => 'Usuário';

  @override
  String get appMake => 'EduMigSoft';

  @override
  String get home => 'Home';

  @override
  String get confirmDeletion => 'Confirmar exclusão?';

  @override
  String get confirmsRestoration => 'Confirma Restauração?';

  @override
  String get areYouSureYouWantToDeleteThisItem =>
      'Tem certeza de que deseja excluir este item?';

  @override
  String get areYouSureYouWantToRestoreThisItem =>
      'Tem certeza de que deseja restaurar este item?';

  @override
  String get delete => 'Excluir';

  @override
  String get deleted => 'Excluído';

  @override
  String get restore => 'Restaurar';

  @override
  String get restored => 'Restaurado';

  @override
  String get cancel => 'Cancelar';

  @override
  String get itemDeleted => 'Item excluído!';

  @override
  String get edit => 'Editar';

  @override
  String get registeredPleaseLoginAgain =>
      'Registrado! Faça o Login novamente.';

  @override
  String get serverCommunicationError => 'Erro de Comunicação com o Servidor';

  @override
  String get register => 'Registrar-se';

  @override
  String get name => 'Nome';

  @override
  String get enterAName => 'Entre com um Nome';

  @override
  String get email => 'Email';

  @override
  String get emailToPoint => 'Email:';

  @override
  String get enterAnEmail => 'Entre com um Email';

  @override
  String get password => 'Senha';

  @override
  String get enterAPassword => 'Entre com uma Senha';

  @override
  String get confirmPassword => 'Confirme a Senha';

  @override
  String get login => 'Conecte-se';

  @override
  String get checkYourEmailToLogin =>
      'Verifique seu email, para fazer o login.';

  @override
  String get createUser => 'Criar Usuário';

  @override
  String get active => 'Ativo';

  @override
  String get inactive => 'Inativo';

  @override
  String get rule => 'Acesso';

  @override
  String get signIn => 'Entrar';

  @override
  String get signUp => 'Inscrever-se';

  @override
  String get errorWhileLogin => 'Erro durante o login';

  @override
  String get checkDataWithErrors => 'Verifique os dados com erros';

  @override
  String get createProfile => 'Criar perfil';

  @override
  String get profile => 'Perfil';

  @override
  String get saveProfile => 'Salvar Perfil';

  @override
  String get changePassword => 'Altere a Senha';

  @override
  String get youNeedToChangeYourPassword => 'É necessário alterar a senha.';

  @override
  String get enterYourNewPassword => 'Entre com nova senha.';

  @override
  String get repeatTheNewPassword => 'Repita a nova senha.';

  @override
  String get recordSaved => 'Registro salvo!';

  @override
  String get forgetPassword => 'Esqueci a senha';

  @override
  String get donTHaveAnAccount => 'Não tem uma conta?';

  @override
  String get alreadyHaveAnAccount => 'Já tem uma conta?';

  @override
  String get welcome => 'Bem-vindo';

  @override
  String get noCoinciden => 'Não coincidem';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get passwordConfirmationIsMandatory =>
      'A confirmação de senha é obrigatória';

  @override
  String get close => 'Fechar';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get save => 'Salvar';

  @override
  String get userRoles => 'Funções de usuário';

  @override
  String get roles => 'Funções';

  @override
  String get selectAtLeastOneRoles => 'Selecione pelo menos uma função.';

  @override
  String get logInToYourAccount => 'Entre na sua conta';

  @override
  String get enterYourEmail => 'Entre com seu email';

  @override
  String get enterYourPassword => 'Digite sua senha';

  @override
  String get rememberMe => 'Lembre de mim';

  @override
  String get recoveryPassword => 'Recuperar a senha';

  @override
  String get registerNow => 'Cadastre-se agora!';

  @override
  String copyright(Object year) {
    return '© $year EduMigSoft. All Rights Reserved. Designed, Anderson S. Andrade*';
  }

  @override
  String get settings => 'Configurações';

  @override
  String get dashboard => 'Painel';

  @override
  String loginError(Object reason) {
    return 'Falha no login: $reason';
  }

  @override
  String serverErrorLog(Object error) {
    return 'ERRO DO SERVIDOR: $error';
  }

  @override
  String emailSubjectWelcome(Object userName) {
    return 'Bem-vindo ao sistema, $userName!';
  }

  @override
  String itemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
      zero: 'Nenhum item',
    );
    return '$_temp0';
  }

  @override
  String lastUpdated(Object date) {
    return 'Última atualização: $date';
  }

  @override
  String get buttonSave => 'Salvar';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonConfirm => 'Confirmar';

  @override
  String get buttonDelete => 'Excluir';

  @override
  String get validationEmailInvalid =>
      'Por favor, insira um endereço de e-mail válido';

  @override
  String get validationPasswordTooShort =>
      'A senha deve ter pelo menos 8 caracteres';

  @override
  String get validationRequired => 'Este campo é obrigatório';

  @override
  String get auth => 'Autenticação';

  @override
  String get authRememberMeLabel => 'Lembrar-me neste dispositivo';

  @override
  String get authRememberMeSessionActive => 'Sessão ativa por 7 dias';

  @override
  String get authRememberMeSessionExpires => 'Sessão expira em 15 minutos';

  @override
  String get authSessionExpiringTitle => 'Sua sessão está expirando';

  @override
  String get authSessionExpiringMessage =>
      'Sua sessão irá expirar em breve. Deseja renovar agora ou fazer logout?';

  @override
  String get authRenewSession => 'Renovar Agora';

  @override
  String get authLogout => 'Fazer Logout';

  @override
  String get authSessionRenewed => 'Sessão renovada com sucesso';

  @override
  String get authSessionRenewalError =>
      'Erro ao renovar sessão. Faça login novamente.';

  @override
  String get myProfile => 'Meu Perfil';

  @override
  String get manageUsers => 'Gerenciar Usuários';

  @override
  String get systemManagement => 'Gestão do Sistema';

  @override
  String get savedSuccessfully => 'Salvo com sucesso';

  @override
  String get theNameCannotBeEmpty => 'O nome não pode ser vazio!';

  @override
  String get cannotBeEmpty => 'Não pode ser vazio!';

  @override
  String get address => 'Endereço';

  @override
  String get phone => 'Telefone';

  @override
  String get status => 'Status';
}
