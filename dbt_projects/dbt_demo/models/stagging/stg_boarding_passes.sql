-- Staging model for boarding passes
-- Extracts and standardizes boarding pass data from the source

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
)

SELECT
    -- Composite key
    ticket_no,
    flight_id,
    
    -- Boarding information
    boarding_no,
    seat_no,
    
    -- Extract seat details
    REGEXP_REPLACE(seat_no, '[^0-9]', '', 'g') AS seat_row,
    REGEXP_REPLACE(seat_no, '[0-9]', '', 'g') AS seat_position,
    
    -- Determine seat location type
    CASE 
        WHEN REGEXP_REPLACE(seat_no, '[0-9]', '', 'g') IN ('A', 'F', 'K') THEN 'Window'
        WHEN REGEXP_REPLACE(seat_no, '[0-9]', '', 'g') IN ('B', 'E', 'J') THEN 'Middle'
        ELSE 'Aisle'
    END AS seat_location_type,
    
    -- Categorize boarding priority
    CASE 
        WHEN boarding_no <= 10 THEN 'Priority'
        WHEN boarding_no <= 50 THEN 'Early'
        ELSE 'Regular'
    END AS boarding_group

FROM source_boarding_passes
