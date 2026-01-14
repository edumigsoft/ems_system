import 'package:core_ui/core_ui.dart'
    show AppNavigationItem, AppNavigationSection;
import 'package:design_system_shared/design_system_shared.dart'
    show DSSpacing, DSPaddings, DSRadius;
import 'package:flutter/material.dart';
import 'package:localizations_ui/localizations_ui.dart' show AppLocalizations;

import '../design_system_ui.dart' show DSIcons;
import 'ds_card.dart';

/// Widget de navegação lateral para o sistema School Pilot.
///
/// A [DSSideNavigation] fornece uma barra lateral responsiva com:
/// - Header com logo e nome do aplicativo
/// - Lista de itens de navegação organizados por seções
/// - Footer com informações do usuário
/// - Suporte a temas via [DSThemeColors]
///
/// ## Estrutura
///
/// A navegação é dividida em seções semânticas ([AppNavigationSection]):
/// - Academic Management (Gestão Acadêmica)
/// - Environment Management (Gestão de Ambientes)
/// - System (Sistema)
///
/// ## Exemplo de Uso
///
/// ```dart
/// DSSideNavigation(
///   selectedRoute: '/dashboard',
///   onDestinationSelected: (route) => Navigator.pushNamed(context, route),
///   items: [
///     AppNavigationItem(
///       route: '/dashboard',
///       icon: DSIcons.dashboard,
///       labelBuilder: (context) => 'Dashboard',
///       section: AppNavigationSection.dashboard,
///     ),
///     AppNavigationItem(
///       route: '/users',
///       icon: DSIcons.person,
///       labelBuilder: (context) => 'Usuários',
///       section: AppNavigationSection.academic,
///     ),
///   ],
///   userName: 'João Silva',
///   userRole: 'Administrador',
///   logo: Image.asset('assets/logo.png'),
/// )
/// ```
///
/// ## Comportamento
///
/// - Items sem seção ou da seção 'dashboard' não exibem header de seção
/// - A rota ativa ([selectedRoute]) é destacada visualmente
/// - Callbacks de navegação são acionados via [onDestinationSelected]
///
/// ## Acessibilidade
///
/// - Suporta navegação por teclado via [InkWell]
/// - Texto com contraste adequado via Design System
/// - Feedback visual claro para item ativo
class DSSideNavigation extends StatelessWidget {
  /// Rota atualmente selecionada/ativa.
  ///
  /// Usado para destacar visualmente o item de navegação correspondente.
  final String selectedRoute;

  /// Callback chamado quando um item de navegação é selecionado.
  ///
  /// Recebe a rota do item como parâmetro.
  final ValueChanged<String> onDestinationSelected;

  /// Lista de items de navegação a serem exibidos.
  ///
  /// Cada item deve ter uma rota única e um labelBuilder para i18n.
  final List<AppNavigationItem> items;

  /// Nome do usuário exibido no footer (opcional).
  ///
  /// Se null, exibe texto padrão 'Usuário'.
  final String? userName;

  /// Cargo/função do usuário exibido no footer (opcional).
  ///
  /// Se null, exibe texto padrão 'Cargo'.
  final String? userRole;

  /// Widget de logo exibido no header (opcional).
  ///
  /// Se null, usa espaço de 52x52 em branco.
  final Widget? logo;

  /// URL do avatar do usuário (opcional).
  ///
  /// Se fornecido, substitui o ícone padrão por uma imagem.
  final String? userAvatarUrl;

  /// Callback chamado quando o usuário clica no botão de logout.
  ///
  /// Se null, o botão de logout não é exibido.
  final VoidCallback? onLogout;

  const DSSideNavigation({
    super.key,
    required this.selectedRoute,
    required this.onDestinationSelected,
    required this.items,
    this.userName,
    this.userRole,
    this.logo,
    this.userAvatarUrl,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return DSCard(
      child: SizedBox(
        width: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NavHeader(logo: logo),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.xs,
                ),
                children: _buildNavItems(context),
              ),
            ),
            _NavFooter(
              userName: userName,
              userRole: userRole,
              avatarUrl: userAvatarUrl,
              onLogout: onLogout,
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói a lista de widgets de navegação.
  ///
  /// Itera sobre [items] e cria:
  /// - [_SectionHeader] quando uma nova seção é detectada
  /// - [NavItem] para cada item de navegação
  ///
  /// Regras:
  /// - Seções 'dashboard' não exibem header
  /// - Headers só aparecem na primeira ocorrência de cada seção
  List<Widget> _buildNavItems(BuildContext context) {
    final List<Widget> children = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final prevItem = i > 0 ? items[i - 1] : null;

      if (item.section != null &&
          // Check if section name contains dashboard to skip header
          !item.section.toString().toLowerCase().contains('dashboard')) {
        if (prevItem == null || prevItem.section != item.section) {
          children.add(
            _SectionHeader(title: _getSectionTitle(context, item.section!)),
          );
        }
      }

      if (item.isParent) {
        children.add(
          _ExpandableNavItem(
            item: item,
            selectedRoute: selectedRoute,
            onDestinationSelected: onDestinationSelected,
          ),
        );
      } else {
        children.add(
          NavItem(
            icon: item.icon,
            label: item.labelBuilder(context),
            isActive: selectedRoute == item.route,
            onTap: () => onDestinationSelected(item.route!),
          ),
        );
      }
    }
    return children;
  }

  /// Retorna o título localizado para uma seção.
  ///
  /// Usa [AppLocalizations] para i18n. Fallback para valores em português
  /// se a localização não estiver disponível.
  ///
  /// Seções suportadas:
  /// - `academic` → Gestão Acadêmica
  /// - `environment` → Gestão de Ambientes
  /// - `system` → Sistema
  String _getSectionTitle(BuildContext context, AppNavigationSection section) {
    // final l10n = AppLocalizations.of(context);
    final name = section.toString().split('.').last;
    switch (name) {
      // case 'academic':
      //   return l10n?.academicManagement ?? 'GESTÃO ACADÊMICA';
      // case 'environment':
      //   return l10n?.environmentManagement ?? 'GESTÃO DE AMBIENTES';
      // case 'system':
      //   return l10n?.systemManagement ?? 'SISTEMA';
      default:
        return '';
    }
  }
}

/// Header da navegação lateral.
///
/// Exibe o logo (se fornecido) junto com o nome da aplicação
/// "School Pilot" e o texto "ADMIN PANEL".
///
/// O logo é envolvido em um Container com sombra e bordas arredondadas
/// utilizando cores do Design System.
class _NavHeader extends StatelessWidget {
  final Widget? logo;
  const _NavHeader({this.logo});

  @override
  Widget build(BuildContext context) {
    final dsColors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(DSPaddings.extraSmall),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: dsColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: dsColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: logo ?? const SizedBox(width: 52, height: 52),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   AppLocalizations.of(context)?.schoolPilot ?? 'School Pilot',
                //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                //     color: dsColors.onSurface,
                //   ),
                //   overflow: TextOverflow.ellipsis,
                // ),
                // Text(
                //   AppLocalizations.of(context)?.adminPanel ?? 'ADMIN PANEL',
                //   style: Theme.of(context).textTheme.labelSmall?.copyWith(
                //     color: dsColors.onSurfaceVariant,
                //     fontWeight: FontWeight.bold,
                //     letterSpacing: 1.2,
                //   ),
                //   overflow: TextOverflow.ellipsis,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header de seção na navegação.
///
/// Exibe um título em letras maiúsculas com espaçamento maior,
/// usado para agrupar visualmente items relacionados.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final dsColors = Theme.of(
      context,
    ).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: dsColors.onSurface.withValues(alpha: 0.5),
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

/// Widget para renderizar um item de navegação hierárquico (com children).
///
/// Características:
/// - Expande/colapsa ao clicar no header
/// - Auto-expande se algum child estiver ativo
/// - Destaca visualmente quando child está ativo
/// - Suporta hierarquia recursiva (children podem ter children)
/// - Mantém conformidade com Design System (tokens de spacing e radius)
class _ExpandableNavItem extends StatefulWidget {
  final AppNavigationItem item;
  final String selectedRoute;
  final ValueChanged<String> onDestinationSelected;

  const _ExpandableNavItem({
    required this.item,
    required this.selectedRoute,
    required this.onDestinationSelected,
  });

  @override
  State<_ExpandableNavItem> createState() => _ExpandableNavItemState();
}

class _ExpandableNavItemState extends State<_ExpandableNavItem> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    // Expande por padrão OU se algum child está ativo
    _isExpanded =
        widget.item.defaultExpanded ||
        widget.item.hasActiveChild(widget.selectedRoute);
  }

  @override
  void didUpdateWidget(_ExpandableNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-expande se rota mudou e agora há child ativo
    if (oldWidget.selectedRoute != widget.selectedRoute) {
      if (widget.item.hasActiveChild(widget.selectedRoute)) {
        setState(() => _isExpanded = true);
      }
    }
  }

  void _toggleExpansion() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final dsColors = Theme.of(context).colorScheme;
    final hasActiveChild = widget.item.hasActiveChild(widget.selectedRoute);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header do item pai
        Padding(
          padding: const EdgeInsets.only(bottom: DSSpacing.xs),
          child: InkWell(
            onTap: () {
              // Se tem rota própria, navega E expande
              if (widget.item.hasRoute) {
                widget.onDestinationSelected(widget.item.route!);
              }
              // Sempre toggle expansão
              _toggleExpansion();
            },
            borderRadius: const BorderRadius.all(
              Radius.circular(DSRadius.large),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.md,
              ),
              decoration: BoxDecoration(
                color: hasActiveChild
                    ? dsColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: const BorderRadius.all(
                  Radius.circular(DSRadius.large),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.item.icon,
                    color: hasActiveChild
                        ? dsColors.primary
                        : dsColors.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(
                    child: Text(
                      widget.item.labelBuilder(context),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hasActiveChild
                            ? dsColors.onSurface
                            : dsColors.onSurface.withValues(alpha: 0.7),
                        fontWeight: hasActiveChild
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_more : Icons.chevron_right,
                    color: dsColors.onSurface.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Children (apenas se expandido)
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: DSSpacing.md), // Indentação
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.item.children.map((child) {
                // Renderiza recursivamente (suporta hierarquia infinita)
                if (child.isParent) {
                  return _ExpandableNavItem(
                    item: child,
                    selectedRoute: widget.selectedRoute,
                    onDestinationSelected: widget.onDestinationSelected,
                  );
                } else {
                  return NavItem(
                    icon: child.icon,
                    label: child.labelBuilder(context),
                    isActive: widget.selectedRoute == child.route,
                    onTap: () => widget.onDestinationSelected(child.route!),
                  );
                }
              }).toList(),
            ),
          ),
      ],
    );
  }
}

/// Item individual de navegação.
///
/// Exibe um ícone e label, com estado visual diferenciado
/// quando ativo ([isActive] = true).
///
/// ## Estados Visuais
///
/// - **Ativo:** Background com cor primária em 10% de opacidade,
///   ícone e texto em cor primária, texto em negrito
/// - **Inativo:** Background transparente, ícone e texto em
///   cor secundária, texto em peso normal
///
/// ## Interação
///
/// - Responde a cliques via [InkWell]
/// - Fornece feedback visual com ripple effect
/// - Bordas arredondadas (12px - [DSRadius.mediumLarge]) para melhor ergonomia
class NavItem extends StatelessWidget {
  /// Ícone exibido à esquerda do label.
  final IconData icon;

  /// Texto do item de navegação.
  final String label;

  /// Indica se este item está ativo/selecionado.
  final bool isActive;

  /// Callback executado ao clicar no item.
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dsColors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(
          Radius.circular(DSRadius.large),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? dsColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: const BorderRadius.all(
              Radius.circular(DSRadius.large),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? dsColors.primary : dsColors.secondary,
                size: 20,
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isActive
                        ? dsColors.onSurface
                        : dsColors.onSurface.withValues(alpha: 0.7),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Footer da navegação lateral.
///
/// Exibe informações do usuário logado:
/// - Avatar circular com ícone de pessoa ou imagem ([avatarUrl])
/// - Nome do usuário ([userName])
/// - Cargo/função ([userRole])
/// - Botão de logout ([onLogout])
///
/// Se [userName] ou [userRole] forem null, exibe textos padrão.
/// Se [onLogout] for null, o botão de logout não é exibido.
class _NavFooter extends StatelessWidget {
  final String? userName;
  final String? userRole;
  final String? avatarUrl;
  final VoidCallback? onLogout;

  const _NavFooter({
    this.userName,
    this.userRole,
    this.avatarUrl,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final dsColors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dsColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: dsColors.primary.withValues(alpha: 0.1),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(
                    DSIcons.person,
                    color: dsColors.primary,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName ?? 'Usuário',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: dsColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  userRole ?? 'Cargo',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: dsColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onLogout != null)
            IconButton(
              icon: Icon(
                Icons.logout,
                color: dsColors.error,
                size: 18,
              ),
              onPressed: onLogout,
              tooltip: 'Sair',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
