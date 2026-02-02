import 'package:flutter/material.dart';
import 'package:school_shared/school_shared.dart';

/// Barra de filtros reutilizável para escolas.
///
/// Permite filtrar por status (ativa, manutenção, inativa) e
/// alternar entre escolas ativas e deletadas.
class SchoolFiltersBar extends StatelessWidget {
  final SchoolStatus? selectedStatus;
  final ValueChanged<SchoolStatus?> onStatusChanged;
  final bool showDeleted;
  final VoidCallback onToggleShowDeleted;

  const SchoolFiltersBar({
    super.key,
    this.selectedStatus,
    required this.onStatusChanged,
    required this.showDeleted,
    required this.onToggleShowDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Filtro de status
          if (!showDeleted) ...[
            FilterChip(
              label: const Text('Todas'),
              selected: selectedStatus == null,
              onSelected: (_) => onStatusChanged(null),
              avatar: selectedStatus == null
                  ? const Icon(Icons.check, size: 16)
                  : null,
            ),
            FilterChip(
              label: const Text('Ativas'),
              selected: selectedStatus == SchoolStatus.active,
              onSelected: (_) => onStatusChanged(
                selectedStatus == SchoolStatus.active
                    ? null
                    : SchoolStatus.active,
              ),
              avatar: selectedStatus == SchoolStatus.active
                  ? const Icon(Icons.check, size: 16)
                  : null,
              backgroundColor: selectedStatus == SchoolStatus.active
                  ? Colors.green.shade100
                  : null,
            ),
            FilterChip(
              label: const Text('Manutenção'),
              selected: selectedStatus == SchoolStatus.maintenance,
              onSelected: (_) => onStatusChanged(
                selectedStatus == SchoolStatus.maintenance
                    ? null
                    : SchoolStatus.maintenance,
              ),
              avatar: selectedStatus == SchoolStatus.maintenance
                  ? const Icon(Icons.check, size: 16)
                  : null,
              backgroundColor: selectedStatus == SchoolStatus.maintenance
                  ? Colors.orange.shade100
                  : null,
            ),
            FilterChip(
              label: const Text('Inativas'),
              selected: selectedStatus == SchoolStatus.inactive,
              onSelected: (_) => onStatusChanged(
                selectedStatus == SchoolStatus.inactive
                    ? null
                    : SchoolStatus.inactive,
              ),
              avatar: selectedStatus == SchoolStatus.inactive
                  ? const Icon(Icons.check, size: 16)
                  : null,
              backgroundColor: selectedStatus == SchoolStatus.inactive
                  ? Colors.red.shade100
                  : null,
            ),
            const SizedBox(width: 8),
            const VerticalDivider(),
          ],
          // Toggle mostrar deletadas
          FilterChip(
            label: Text(showDeleted ? 'Deletadas' : 'Ativas'),
            selected: showDeleted,
            onSelected: (_) => onToggleShowDeleted(),
            avatar: Icon(
              showDeleted ? Icons.delete_outline : Icons.check_circle_outline,
              size: 16,
            ),
            backgroundColor: showDeleted ? Colors.grey.shade200 : null,
          ),
        ],
      ),
    );
  }
}
