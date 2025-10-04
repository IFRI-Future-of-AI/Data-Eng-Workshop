-- Staging model for seats
-- Extracts and standardizes seat configuration data from the source

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
)

SELECT
    -- Composite key components
    aircraft_code,
    seat_no,
    
    -- Seat classification
    fare_conditions,
    
    -- Extract row and position from seat number
    REGEXP_REPLACE(seat_no, '[^0-9]', '', 'g') AS seat_row,
    REGEXP_REPLACE(seat_no, '[0-9]', '', 'g') AS seat_position,
    
    -- Determine if window, middle or aisle based on position letter
    CASE 
        WHEN REGEXP_REPLACE(seat_no, '[0-9]', '', 'g') IN ('A', 'F', 'K') THEN 'Window'
        WHEN REGEXP_REPLACE(seat_no, '[0-9]', '', 'g') IN ('B', 'E', 'J') THEN 'Middle'
        ELSE 'Aisle'
    END AS seat_location_type

FROM source_seats
