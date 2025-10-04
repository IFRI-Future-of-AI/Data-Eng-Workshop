-- Dimension table: Appareils
-- Référentiel des modèles d'appareils pour l'analyse de flotte
{{
    config(
        materialized = 'table',
        schema = 'marts',
        tags = ['marts', 'operations', 'dimension']
    )
}}

SELECT
    aircraft_code,
    aircraft_model,
    flight_range_km,
    aircraft_category,
    dbt_loaded_at
FROM {{ ref('stg_aircrafts') }}
