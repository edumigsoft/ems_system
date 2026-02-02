-- Migration: Migrar de coluna JSON para Junction Table normalizada
-- Description: Move dados da coluna tags (JSON) para notebook_tags (M2M)
-- Date: 2026-02-01
-- IMPORTANTE: Execute este script APÓS confirmar que notebook_tags table existe

-- ==============================================================================
-- PARTE 1: Garantir que a tabela notebook_tags existe
-- ==============================================================================

CREATE TABLE IF NOT EXISTS notebook_tags (
  notebook_id TEXT NOT NULL,
  tag_id TEXT NOT NULL,
  associated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (notebook_id, tag_id)
);

-- Adicionar FK para notebooks (CASCADE delete)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'notebook_tags_notebook_id_fkey'
  ) THEN
    ALTER TABLE notebook_tags
      ADD CONSTRAINT notebook_tags_notebook_id_fkey
      FOREIGN KEY (notebook_id)
      REFERENCES notebooks(id)
      ON DELETE CASCADE;
  END IF;
END $$;

-- Adicionar FK para tags (RESTRICT delete - não permitir deletar tag em uso)
-- NOTA: Descomente quando a tabela 'tags' existir no mesmo database
/*
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'notebook_tags_tag_id_fkey'
  ) THEN
    ALTER TABLE notebook_tags
      ADD CONSTRAINT notebook_tags_tag_id_fkey
      FOREIGN KEY (tag_id)
      REFERENCES tags(id)
      ON DELETE RESTRICT;
  END IF;
END $$;
*/

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_notebook_tags_notebook_id
  ON notebook_tags(notebook_id);

CREATE INDEX IF NOT EXISTS idx_notebook_tags_tag_id
  ON notebook_tags(tag_id);

-- ==============================================================================
-- PARTE 2: Migrar dados existentes de JSON → Junction Table
-- ==============================================================================

-- Função auxiliar para extrair tag IDs do JSON array
CREATE OR REPLACE FUNCTION migrate_tags_to_junction()
RETURNS void AS $$
DECLARE
  notebook_record RECORD;
  tag_id TEXT;
  tag_array JSONB;
BEGIN
  -- Para cada notebook que tem tags
  FOR notebook_record IN
    SELECT id, tags
    FROM notebooks
    WHERE tags IS NOT NULL
      AND tags != ''
      AND tags != '[]'
      AND is_deleted = false
  LOOP
    BEGIN
      -- Parse JSON array
      tag_array := notebook_record.tags::jsonb;

      -- Para cada tag ID no array
      FOR tag_id IN
        SELECT jsonb_array_elements_text(tag_array)
      LOOP
        -- Inserir na junction table (ignorar duplicatas)
        INSERT INTO notebook_tags (notebook_id, tag_id, associated_at)
        VALUES (notebook_record.id, tag_id, CURRENT_TIMESTAMP)
        ON CONFLICT (notebook_id, tag_id) DO NOTHING;
      END LOOP;
    EXCEPTION WHEN OTHERS THEN
      -- Log erro mas continua processando
      RAISE NOTICE 'Erro ao migrar notebook %: %', notebook_record.id, SQLERRM;
    END;
  END LOOP;

  RAISE NOTICE 'Migração concluída!';
END;
$$ LANGUAGE plpgsql;

-- Executar a migração
SELECT migrate_tags_to_junction();

-- Dropar função auxiliar
DROP FUNCTION migrate_tags_to_junction();

-- ==============================================================================
-- PARTE 3: Verificação pós-migração
-- ==============================================================================

-- Contar registros migrados
DO $$
DECLARE
  notebooks_count INTEGER;
  associations_count INTEGER;
BEGIN
  SELECT COUNT(DISTINCT notebook_id) INTO notebooks_count FROM notebook_tags;
  SELECT COUNT(*) INTO associations_count FROM notebook_tags;

  RAISE NOTICE '✓ Notebooks com tags: %', notebooks_count;
  RAISE NOTICE '✓ Total de associações: %', associations_count;
END $$;

-- ==============================================================================
-- PARTE 4: (OPCIONAL) Remover coluna tags após validar que tudo funciona
-- ==============================================================================
-- CUIDADO: Só execute após confirmar que a junction table está funcionando!
-- Para executar, descomente as linhas abaixo:

-- -- Remover índice GIN da coluna tags
-- DROP INDEX IF EXISTS idx_notebooks_tags_gin;
--
-- -- Backup da coluna (cria coluna temporária)
-- ALTER TABLE notebooks ADD COLUMN IF NOT EXISTS tags_backup TEXT;
-- UPDATE notebooks SET tags_backup = tags WHERE tags IS NOT NULL;
--
-- -- Remover coluna tags
-- ALTER TABLE notebooks DROP COLUMN IF EXISTS tags;
--
-- COMMENT ON TABLE notebooks IS 'Tags agora são gerenciadas via notebook_tags junction table';

-- ==============================================================================
-- ROLLBACK (caso necessário reverter)
-- ==============================================================================
-- Para reverter a migração:
/*
-- 1. Recriar coluna tags
ALTER TABLE notebooks ADD COLUMN IF NOT EXISTS tags TEXT;

-- 2. Migrar de volta: junction → JSON
UPDATE notebooks n
SET tags = (
  SELECT jsonb_agg(tag_id)::text
  FROM notebook_tags nt
  WHERE nt.notebook_id = n.id
)
WHERE EXISTS (
  SELECT 1 FROM notebook_tags nt WHERE nt.notebook_id = n.id
);

-- 3. Limpar junction table
TRUNCATE notebook_tags;
*/
