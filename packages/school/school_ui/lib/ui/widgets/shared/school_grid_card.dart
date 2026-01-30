import 'package:flutter/material.dart';
import 'package:school_shared/school_shared.dart';
import 'school_status_badge.dart';

/// Card reutilizável para exibir uma escola em grid (Tablet).
///
/// Mostra informações principais da escola em formato de card
/// com layout otimizado para visualização em grid.
class SchoolGridCard extends StatelessWidget {
  final SchoolDetails school;
  final VoidCallback? onTap;
  final VoidCallback? onRestore;

  const SchoolGridCard({
    super.key,
    required this.school,
    this.onTap,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: school.isDeleted ? 1 : 2,
      color: school.isDeleted ? Colors.grey.shade100 : null,
      child: InkWell(
        onTap: school.isDeleted ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header com nome e status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Ícone da escola
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: school.isDeleted
                                    ? Colors.grey.shade300
                                    : Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.school,
                                size: 20,
                                color: school.isDeleted
                                    ? Colors.grey.shade600
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    school.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          decoration: school.isDeleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (school.isDeleted)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          size: 12,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Deletada',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!school.isDeleted)
                        SchoolStatusBadge(
                          status: school.status,
                          compact: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // Informações
                  _buildInfoRow(
                    Icons.qr_code,
                    'Código',
                    school.code,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Localização',
                    school.locationCity,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.person_outline,
                    'Diretor(a)',
                    school.director,
                  ),
                ],
              ),
            ),
            // Botão restaurar (se deletado)
            if (school.isDeleted && onRestore != null)
              Positioned(
                bottom: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.restore_from_trash),
                  tooltip: 'Restaurar',
                  onPressed: onRestore,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.green.shade900,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
