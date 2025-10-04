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
        CAST(REGEXP_REPLACE(seat_no, '[A-Z]', '', 'g') AS INTEGER) AS seat_row,
        -- Extraction de la lettre du siège
        REGEXP_REPLACE(seat_no, '[0-9]', '', 'g') AS seat_letter,
        -- Position du siège (fenêtre, milieu, couloir)
        CASE
            WHEN REGEXP_REPLACE(seat_no, '[0-9]', '', 'g') IN ('A', 'F') THEN 'Fenêtre'
            WHEN REGEXP_REPLACE(seat_no, '[0-9]', '', 'g') IN ('C', 'D') THEN 'Couloir'
            ELSE 'Milieu'
        END AS seat_position,
        -- Métadonnées de traçabilité
        CURRENT_TIMESTAMP AS dbt_loaded_at
    FROM source_seats
)

SELECT
    *
FROM cleaned_seats
