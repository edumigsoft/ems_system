import 'package:flutter/material.dart';
import 'package:school_shared/school_shared.dart';
import 'school_status_badge.dart';

/// Bottom sheet de detalhes da escola para Mobile.
///
/// Exibe informações completas da escola em um bottom sheet
/// modal com ações para editar, deletar ou restaurar.
class SchoolDetailsBottomSheet extends StatelessWidget {
  final SchoolDetails school;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRestore;

  const SchoolDetailsBottomSheet({
    super.key,
    required this.school,
    this.onEdit,
    this.onDelete,
    this.onRestore,
  });

  static Future<void> show({
    required BuildContext context,
    required SchoolDetails school,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onRestore,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SchoolDetailsBottomSheet(
        school: school,
        onEdit: onEdit,
        onDelete: onDelete,
        onRestore: onRestore,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          school.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: school.isDeleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Código: ${school.code}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (school.isDeleted)
                    Chip(
                      label: const Text('Deletada'),
                      avatar: const Icon(Icons.delete_outline, size: 16),
                      backgroundColor: Colors.grey.shade200,
                    )
                  else
                    SchoolStatusBadge(status: school.status),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSection(
                    context,
                    'Informações Básicas',
                    [
                      _buildInfoRow(
                        context,
                        Icons.school,
                        'Nome',
                        school.name,
                      ),
                      _buildInfoRow(
                        context,
                        Icons.qr_code,
                        'Código',
                        school.code,
                      ),
                      _buildInfoRow(
                        context,
                        Icons.info_outline,
                        'Status',
                        _getStatusText(school.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Localização',
                    [
                      _buildInfoRow(
                        context,
                        Icons.location_city,
                        'Cidade',
                        school.locationCity,
                      ),
                      _buildInfoRow(
                        context,
                        Icons.maps_home_work_outlined,
                        'Distrito',
                        school.locationDistrict,
                      ),
                      _buildInfoRow(
                        context,
                        Icons.home_outlined,
                        'Endereço',
                        school.address,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Contato',
                    [
                      _buildInfoRow(
                        context,
                        Icons.phone_outlined,
                        'Telefone',
                        school.phone,
                      ),
                      _buildInfoRow(
                        context,
                        Icons.email_outlined,
                        'Email',
                        school.email,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Administração',
                    [
                      _buildInfoRow(
                        context,
                        Icons.person_outline,
                        'Diretor(a)',
                        school.director,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    'Dados do Sistema',
                    [
                      _buildInfoRow(
                        context,
                        Icons.calendar_today,
                        'Criado em',
                        _formatDate(school.createdAt),
                      ),
                      _buildInfoRow(
                        context,
                        Icons.update,
                        'Atualizado em',
                        _formatDate(school.updatedAt),
                      ),
                      _buildInfoRow(
                        context,
                        Icons.toggle_on_outlined,
                        'Ativo',
                        school.isActive ? 'Sim' : 'Não',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (school.isDeleted)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onRestore?.call();
                          },
                          icon: const Icon(Icons.restore_from_trash),
                          label: const Text('Restaurar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      )
                    else ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onEdit?.call();
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete?.call();
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Excluir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(SchoolStatus status) {
    switch (status) {
      case SchoolStatus.active:
        return 'Ativa';
      case SchoolStatus.maintenance:
        return 'Em Manutenção';
      case SchoolStatus.inactive:
        return 'Inativa';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
