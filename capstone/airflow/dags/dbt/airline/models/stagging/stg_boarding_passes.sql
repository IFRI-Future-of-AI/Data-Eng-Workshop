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
        toInt32(replaceRegexpAll(seat_no, '[A-Z]', '')) AS seat_row,
        -- Extraction de la lettre du siège
        replaceRegexpAll(seat_no, '[0-9]', '') AS seat_letter,
        -- Métadonnées de traçabilité
        now() AS dbt_loaded_at
    FROM source_boarding_passes
)

SELECT
    *
FROM cleaned_boarding_passes
