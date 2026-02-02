-- Script de Diagnóstico: Verificar Associações de Tags em Notebooks
-- Execute este script para verificar o estado atual dos dados

-- 1. Verificar se a coluna tags existe
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'notebooks' AND column_name = 'tags';

-- 2. Verificar índices na tabela notebooks
SELECT
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'notebooks';

-- 3. Contar notebooks com e sem tags
SELECT
  'Total de notebooks' as tipo,
  COUNT(*) as quantidade
FROM notebooks
WHERE is_deleted = false
UNION ALL
SELECT
  'Notebooks COM tags' as tipo,
  COUNT(*) as quantidade
FROM notebooks
WHERE is_deleted = false
  AND tags IS NOT NULL
  AND tags != ''
  AND tags != '[]'
UNION ALL
SELECT
  'Notebooks SEM tags' as tipo,
  COUNT(*) as quantidade
FROM notebooks
WHERE is_deleted = false
  AND (tags IS NULL OR tags = '' OR tags = '[]');

-- 4. Listar notebooks recentes com suas tags
SELECT
  id,
  title,
  tags,
  created_at
FROM notebooks
WHERE is_deleted = false
ORDER BY created_at DESC
LIMIT 10;

-- 5. Verificar formato dos dados de tags
SELECT
  id,
  title,
  tags,
  CASE
    WHEN tags IS NULL THEN 'NULL'
    WHEN tags = '' THEN 'String vazia'
    WHEN tags = '[]' THEN 'Array JSON vazio'
    ELSE 'Possui tags'
  END as status_tags
FROM notebooks
WHERE is_deleted = false
ORDER BY created_at DESC
LIMIT 10;

-- 6. Testar se o índice GIN funciona (busca por tag específica)
-- Substitua 'tag-id-aqui' por um ID real de tag
EXPLAIN ANALYZE
SELECT id, title, tags
FROM notebooks
WHERE tags::jsonb @> '["tag-id-aqui"]'::jsonb
  AND is_deleted = false;
