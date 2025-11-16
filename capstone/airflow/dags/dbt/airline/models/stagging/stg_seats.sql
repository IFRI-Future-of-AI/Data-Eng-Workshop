-- Staging model pour les sièges
-- Configuration des sièges par appareil
{{
    config(
        materialized = 'view',
        schema = 'dbt_demo',
        tags = ['stg', 'seats', 'reference']
    )
}}

WITH source_seats AS (
    SELECT
        aircraft_code,
        seat_no,
        fare_conditions
    FROM {{ source('demo', 'seats') }}
),

cleaned_seats AS (
    SELECT
        aircraft_code,
        seat_no,
        fare_conditions AS cabin_class,
        -- Extraction de la rangée du siège
        toInt32(replaceRegexpAll(seat_no, '[A-Z]', '')) AS seat_row,
        -- Extraction de la lettre du siège
        replaceRegexpAll(seat_no, '[0-9]', '') AS seat_letter,
        -- Position du siège (fenêtre, milieu, couloir)
        CASE
            WHEN replaceRegexpAll(seat_no, '[0-9]', '') IN ('A', 'F') THEN 'Fenêtre'
            WHEN replaceRegexpAll(seat_no, '[0-9]', '') IN ('C', 'D') THEN 'Couloir'
            ELSE 'Milieu'
        END AS seat_position,
        -- Métadonnées de traçabilité
        now() AS dbt_loaded_at
    FROM source_seats
)

SELECT
    *
FROM cleaned_seats
