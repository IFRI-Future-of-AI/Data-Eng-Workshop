-- Dimension table: Aéroports
-- Référentiel des aéroports pour l'analyse géographique
{{
    config(
        materialized = 'table',
        schema = 'marts',
        tags = ['marts', 'operations', 'dimension']
    )
}}

SELECT
    airport_code,
    airport_name,
    city_name,
    timezone,
    latitude,
    longitude,
    dbt_loaded_at
FROM {{ ref('stg_airports') }}
