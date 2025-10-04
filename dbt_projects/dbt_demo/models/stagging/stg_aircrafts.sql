-- Staging model for aircrafts
-- Extracts and standardizes aircraft data from the source

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
    FROM {{ source('demo', 'aircrafts') }}
)

SELECT
    -- Primary key
    aircraft_code,
    
    -- Aircraft information
    model::jsonb->>'en' AS model_en,
    model::jsonb->>'ru' AS model_ru,
    range AS range_km,
    
    -- Categorize by range
    CASE 
        WHEN range < 3000 THEN 'Short-haul'
        WHEN range BETWEEN 3000 AND 6000 THEN 'Medium-haul'
        ELSE 'Long-haul'
    END AS range_category,
    
    -- Raw data for reference
    model AS model_json

FROM source_aircrafts
