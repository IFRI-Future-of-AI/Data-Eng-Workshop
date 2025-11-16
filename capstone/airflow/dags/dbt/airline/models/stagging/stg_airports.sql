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
        -- Extraction du nom en anglais depuis JSON
        JSONExtractString(airport_name, 'en') AS airport_name,
        -- Extraction de la ville en anglais depuis JSON
        JSONExtractString(city, 'en') AS city_name,
        coordinates,
        -- Extraction latitude et longitude depuis Tuple/Point
        tupleElement(coordinates, 1) AS longitude,
        tupleElement(coordinates, 2) AS latitude,
        timezone,
        -- Métadonnées de traçabilité
        now() AS dbt_loaded_at
    FROM source_airports
)

SELECT
    *
FROM cleaned_airports
