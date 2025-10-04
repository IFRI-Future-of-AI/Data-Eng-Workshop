-- Staging model pour les cartes d'embarquement
-- Informations de check-in et assignation de sièges
{{
    config(
        materialized = 'view',
        schema = 'dbt_demo',
        tags = ['stg', 'boarding_passes']
    )
}}

WITH source_boarding_passes AS (
    SELECT
        ticket_no,
        flight_id,
        boarding_no,
        seat_no
    FROM {{ source('demo', 'boarding_passes') }}
),

cleaned_boarding_passes AS (
    SELECT
        ticket_no,
        flight_id,
        boarding_no,
        seat_no,
        -- Extraction de la rangée du siège
        CAST(REGEXP_REPLACE(seat_no, '[A-Z]', '', 'g') AS INTEGER) AS seat_row,
        -- Extraction de la lettre du siège
        REGEXP_REPLACE(seat_no, '[0-9]', '', 'g') AS seat_letter,
        -- Métadonnées de traçabilité
        CURRENT_TIMESTAMP AS dbt_loaded_at
    FROM source_boarding_passes
)

SELECT
    *
FROM cleaned_boarding_passes
