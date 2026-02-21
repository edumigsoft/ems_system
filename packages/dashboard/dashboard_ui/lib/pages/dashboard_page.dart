import 'package:core_ui/core_ui.dart' show ResponsiveLayout;
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';

import '../view_models/dashboard_view_model.dart';
import '../widgets/dashboard_widget_card.dart';

/// Página de Dashboard — agrega widgets de todos os módulos registrados.
///
/// Mobile (< 600 px): 1 coluna.
/// Tablet (600-899 px): 2 colunas.
/// Desktop (≥ 900 px): 3 colunas.
///
/// Usa LayoutBuilder + Wrap ao invés de GridView com childAspectRatio fixo,
/// permitindo que os cards cresçam para o tamanho do seu conteúdo.
class DashboardPage extends StatelessWidget {
  final DashboardViewModel viewModel;

  const DashboardPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DSCardHeader(
          title: 'Dashboard',
          subtitle: 'Visão geral do sistema',
          showSearch: false,
        ),
        Expanded(
          child: DSCard(
            child: ResponsiveLayout(
              mobile: _DashboardLayout(viewModel: viewModel, columns: 1),
              tablet: _DashboardLayout(viewModel: viewModel, columns: 2),
              desktop: _DashboardLayout(viewModel: viewModel, columns: 3),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardLayout extends StatelessWidget {
  final DashboardViewModel viewModel;
  final int columns;

  const _DashboardLayout({required this.viewModel, required this.columns});

  @override
  Widget build(BuildContext context) {
    final entries = viewModel.entries;

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(48),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum widget registrado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
              ),
            ),
          ],
        ),
      );
    }

    const padding = 16.0;
    const spacing = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Largura disponível descontando padding horizontal e espaços entre colunas
        final totalSpacing = spacing * (columns - 1);
        final itemWidth =
            (constraints.maxWidth - padding * 2 - totalSpacing) / columns;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(padding),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: entries
                .map(
                  (entry) => SizedBox(
                    width: itemWidth,
                    child: DashboardWidgetCard(entry: entry),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
