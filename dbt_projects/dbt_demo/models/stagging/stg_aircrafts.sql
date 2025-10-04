-- Staging model pour les appareils
-- Nettoie et standardise les données de la table aircrafts_data
{{
    config(
        materialized = 'view',
        schema = 'dbt_demo',
        tags = ['stg', 'aircrafts', 'reference']
    )
}}

WITH source_aircrafts AS (
    SELECT
        aircraft_code,
        model,
        range
    FROM {{ source('demo', 'aircrafts_data') }}
),

cleaned_aircrafts AS (
    SELECT
        aircraft_code,
        -- Extraction du modèle en anglais depuis JSONB
        model::jsonb->>'en' AS aircraft_model,
        range AS flight_range_km,
        -- Catégorisation par autonomie
        CASE
            WHEN range < 3000 THEN 'Court-courrier'
            WHEN range BETWEEN 3000 AND 6000 THEN 'Moyen-courrier'
            WHEN range > 6000 THEN 'Long-courrier'
        END AS aircraft_category,
        -- Métadonnées de traçabilité
        CURRENT_TIMESTAMP AS dbt_loaded_at
    FROM source_aircrafts
)

SELECT
    *
FROM cleaned_aircrafts
