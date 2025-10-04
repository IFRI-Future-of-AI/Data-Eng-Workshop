-- Staging model pour les aéroports
-- Nettoie et standardise les données de la table airports_data
{{
    config(
        materialized = 'view',
        schema = 'dbt_demo',
        tags = ['stg', 'airports', 'reference']
    )
}}

WITH source_airports AS (
    SELECT
        airport_code,
        airport_name,
        city,
        coordinates,
        timezone
    FROM {{ source('demo', 'airports_data') }}
),

cleaned_airports AS (
    SELECT
        airport_code AS airport_code,
        -- Extraction du nom en anglais depuis JSONB
        airport_name::jsonb->>'en' AS airport_name,
        -- Extraction de la ville en anglais depuis JSONB
        city::jsonb->>'en' AS city_name,
        coordinates,
        -- Extraction latitude et longitude depuis POINT
        coordinates[0] AS longitude,
        coordinates[1] AS latitude,
        timezone,
        -- Métadonnées de traçabilité
        CURRENT_TIMESTAMP AS dbt_loaded_at
    FROM source_airports
)

SELECT
    *
FROM cleaned_airports
