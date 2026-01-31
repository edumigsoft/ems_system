import 'package:flutter/material.dart';
import 'package:school_shared/school_shared.dart';
import 'school_status_badge.dart';

/// Card reutilizável para exibir uma escola em lista (Mobile).
///
/// Mostra informações principais da escola com indicadores visuais
/// para escolas deletadas e botão de ação condicional.
class SchoolCard extends StatelessWidget {
  final SchoolDetails school;
  final VoidCallback? onTap;
  final VoidCallback? onRestore;

  const SchoolCard({
    super.key,
    required this.school,
    this.onTap,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: school.isDeleted ? 1 : 2,
      color: school.isDeleted ? Colors.grey.shade100 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: school.isDeleted
              ? Colors.grey
              : Theme.of(context).colorScheme.primary,
          child: Text(
            school.name[0].toUpperCase(),
            style: TextStyle(
              color: school.isDeleted ? Colors.grey.shade700 : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                school.name,
                style: TextStyle(
                  decoration: school.isDeleted
                      ? TextDecoration.lineThrough
                      : null,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (school.isDeleted) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.delete_outline,
                size: 16,
                color: Colors.grey[600],
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              school.isDeleted
                  ? 'Código: ${school.code} (Deletada)'
                  : 'Código: ${school.code}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${school.locationCity} - ${school.locationDistrict}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: school.isDeleted
            ? (onRestore != null
                  ? IconButton(
                      icon: const Icon(Icons.restore_from_trash),
                      tooltip: 'Restaurar',
                      onPressed: onRestore,
                    )
                  : null)
            : SchoolStatusBadge(status: school.status),
        onTap: school.isDeleted ? null : onTap,
      ),
    );
  }
}
