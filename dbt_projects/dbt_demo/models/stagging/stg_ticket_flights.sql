-- Staging model for ticket flights
-- Extracts and standardizes ticket-flight segment data from the source

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
)

SELECT
    -- Composite key
    ticket_no,
    flight_id,
    
    -- Fare information
    fare_conditions,
    amount AS amount_cents,
    ROUND(amount / 100.0, 2) AS amount_dollars,
    
    -- Fare condition categorization
    CASE fare_conditions
        WHEN 'Economy' THEN 1
        WHEN 'Comfort' THEN 2
        WHEN 'Business' THEN 3
        ELSE 0
    END AS fare_tier

FROM source_ticket_flights
