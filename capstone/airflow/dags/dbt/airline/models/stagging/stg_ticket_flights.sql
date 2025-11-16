-- Staging model pour les segments de vol des billets
-- Association entre billets et vols avec tarification
{{
    config(
        materialized = 'view',
        schema = 'dbt_demo',
        tags = ['stg', 'ticket_flights']
    )
}}

WITH source_ticket_flights AS (
    SELECT
        ticket_no,
        flight_id,
        fare_conditions,
        amount
    FROM {{ source('demo', 'ticket_flights') }}
),

cleaned_ticket_flights AS (
    SELECT
        ticket_no,
        flight_id,
        fare_conditions AS cabin_class,
        amount AS segment_price,
        -- Catégorisation du prix
        CASE
            WHEN amount < 5000 THEN 'Économique'
            WHEN amount BETWEEN 5000 AND 15000 THEN 'Standard'
            WHEN amount BETWEEN 15000 AND 50000 THEN 'Premium'
            WHEN amount > 50000 THEN 'Luxe'
        END AS price_category,
        -- Métadonnées de traçabilité
        now() AS dbt_loaded_at
    FROM source_ticket_flights
)

SELECT
    *
FROM cleaned_ticket_flights
