-- Staging model for airports
-- Extracts and standardizes airport data from the source

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
    FROM {{ source('demo', 'airports') }}
)

SELECT
    -- Primary key
    airport_code AS airport_code,
    
    -- Airport information
    airport_name::jsonb->>'en' AS airport_name_en,
    airport_name::jsonb->>'ru' AS airport_name_ru,
    city::jsonb->>'en' AS city_en,
    city::jsonb->>'ru' AS city_ru,
    
    -- Geographic data
    coordinates,
    CAST(coordinates AS TEXT) AS coordinates_text,
    timezone,
    
    -- Raw data for reference
    airport_name AS airport_name_json,
    city AS city_json

FROM source_airports
