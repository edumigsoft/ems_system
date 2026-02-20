import 'package:core_ui/core_ui.dart' show ResponsiveLayout;
import 'package:design_system_ui/design_system_ui.dart';
import 'package:flutter/material.dart';

import '../view_models/dashboard_view_model.dart';
import '../widgets/dashboard_widget_card.dart';

/// Página de Dashboard — agrega widgets de todos os módulos registrados.
///
/// Mobile (< 600 px): ListView de cards (largura total, um por linha).
/// Tablet (600-899 px): GridView com 2 colunas.
/// Desktop (≥ 900 px): GridView com 3 colunas.
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
              mobile: _DashboardGrid(viewModel: viewModel, columns: 1),
              tablet: _DashboardGrid(viewModel: viewModel, columns: 2),
              desktop: _DashboardGrid(viewModel: viewModel, columns: 3),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  final DashboardViewModel viewModel;
  final int columns;

  const _DashboardGrid({required this.viewModel, required this.columns});

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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: columns == 1 ? 2.5 : 1.4,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) =>
          DashboardWidgetCard(entry: entries[index]),
    );
  }
}
