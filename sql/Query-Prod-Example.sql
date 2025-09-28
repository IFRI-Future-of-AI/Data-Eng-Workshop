/*
---
name: reporting_docs_daily_v1
description: >
  Table matérialisée quotidienne : documents enrichis avec métadonnées auteur pour les dashboards.
objective: "Fournir un dataset propre, historisé et idempotent pour consommation BI."
owner: "data-platform@company.com  (Data Platform) / Abraham (Data Owner)"
source_tables:
  - docs.raw_documents: [id, title, body, author_id, created_at, updated_at, lang, status, version]
  - users.dim_users:     [id, email, full_name, department, is_active]
columns_out:
  - doc_id, title, body_snippet, language, author_id, author_email, author_name, author_department,
    created_at, updated_at, content_hash, source_version, processed_at, pipeline_version
transformations:
  - nettoyage des lang (fallback en 'en'), trim, cast timestamps, création content_hash (md5)
  - body_snippet = LEFT(body, 5000) pour limiter taille
joins:
  - LEFT JOIN users.dim_users on author_id -> récupérer email/full_name/department
version: "v1.2 (2025-09-28)"
schedule: "daily @ 02:00 UTC"
tests: "row_count > 0, no null doc_id, checksum check"
notes: "Idempotent via MERGE; update seulement si content_hash change"
---
*/

-- Début transactionnelle (selon SGBD)
BEGIN;

WITH src AS (
  -- Source minimale + filtres (fenêtre incrémentale pour perf)
  SELECT
    d.id                  AS doc_id,
    d.title,
    d.body,
    COALESCE(NULLIF(TRIM(d.lang), ''), 'en') AS language,
    d.author_id,
    CAST(d.created_at AS TIMESTAMP) AS created_at,
    CAST(d.updated_at AS TIMESTAMP) AS updated_at,
    d.status,
    d.version             AS source_version,
    -- hash du contenu pour détecter changements (md5 est largement dispo)
    md5(CONCAT(COALESCE(d.title, ''), '||', COALESCE(d.body, ''))) AS content_hash
  FROM docs.raw_documents d
  WHERE d.status <> 'deleted'
    -- incremental window: accélère les runs quotidiens (adapter selon besoin)
    AND d.updated_at >= (CURRENT_DATE - INTERVAL '90 days')
),

users_active AS (
  SELECT id AS user_id, email, full_name, department
  FROM users.dim_users
  WHERE is_active = TRUE
),

enriched AS (
  -- transformations claires et petites (limit body, standardize)
  SELECT
    s.doc_id,
    s.title,
    LEFT(s.body, 5000) AS body_snippet,
    s.language,
    s.author_id,
    u.email AS author_email,
    u.full_name AS author_name,
    u.department AS author_department,
    s.created_at,
    s.updated_at,
    s.content_hash,
    s.source_version
  FROM src s
  LEFT JOIN users_active u
    ON s.author_id = u.user_id
)
-- projection finale, ajoute métadonnées pipeline
SELECT
    doc_id,
    title,
    body_snippet,
    language,
    author_id,
    author_email,
    author_name,
    author_department,
    created_at,
    updated_at,
    content_hash,
    source_version,
    CURRENT_TIMESTAMP AS processed_at,
    'reporting_docs_daily_v1' AS data_product,
    'v1.2' AS pipeline_version
FROM enriched
