#!/bin/bash

# ============================================================================
# 16_generate_ui_widgets.sh - Gera Widgets reutilizáveis
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/utils.sh"
source "$SCRIPT_DIR/common/validators.sh"

echo "=============================================="
echo "  Gerador de UI Widgets"
echo "=============================================="
echo ""

ask "Nome da feature (snake_case)" FEATURE_NAME
validate_name "$FEATURE_NAME" || exit 1

ask "Nome da entidade (PascalCase)" ENTITY_NAME
validate_class_name "$ENTITY_NAME" || exit 1

FEATURE_SNAKE=$(to_snake_case "$FEATURE_NAME")
ENTITY_SNAKE=$(to_snake_case "$ENTITY_NAME")
ROOT=$(get_project_root)
UI_PATH=$(get_ui_package_path "$FEATURE_SNAKE")
WIDGETS_DIR="$UI_PATH/lib/ui/widgets"

validate_package_exists "$FEATURE_SNAKE" "ui" || exit 1
ensure_dir "$WIDGETS_DIR"

progress "Gerando ${ENTITY_NAME}Card widget..."

# Card Widget
cat > "$WIDGETS_DIR/${ENTITY_SNAKE}_card.dart" <<EOF
import 'package:flutter/material.dart';
import 'package:${FEATURE_SNAKE}_core/${FEATURE_SNAKE}_core.dart';

/// Card para exibir $ENTITY_NAME.
class ${ENTITY_NAME}Card extends StatelessWidget {
  final ${ENTITY_NAME}Details item;
  final VoidCallback? onTap;

  const ${ENTITY_NAME}Card({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(item.id), // Trocar por campo apropriado
        subtitle: Text('Criado em: \${item.createdAt}'),
        trailing: item.isActive
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.cancel, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
EOF

success "Widget Card gerada!"

# Form Widget
cat > "$WIDGETS_DIR/${ENTITY_SNAKE}_form.dart" <<EOF
import 'package:flutter/material.dart';

/// Form para criar/editar $ENTITY_NAME.
class ${ENTITY_NAME}Form extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final void Function(Map<String, dynamic> data) onSubmit;

  const ${ENTITY_NAME}Form({
    super.key,
    this.initialData,
    required this.onSubmit,
  });

  @override
  State<${ENTITY_NAME}Form> createState() => _${ENTITY_NAME}FormState();
}

class _${ENTITY_NAME}FormState extends State<${ENTITY_NAME}Form> {
  final _formKey = GlobalKey<FormState>();
  
  // Adicionar TextEditingControllers para os campos

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Adicionar TextFormFields
          
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Coletar dados do formulário
                final data = <String, dynamic>{};
                widget.onSubmit(data);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
EOF

success "Widget Form gerada!"
echo ""
info "Widgets criados em: $WIDGETS_DIR"
