
{{
    config(
        materialized = 'table',
        unique_key = 'id',
        schema = 'dbt_demo',
        tags  = ['stg', 'flights']
    )
}}

WITH stg_fligths AS (
    SELECT
        flight_id AS id ,
        flight_no AS no ,
        scheduled_departure,
        actual_departure,
        scheduled_arrival,
        actual_arrival,
        status,
        aircraft_code,
        departure_airport,
        arrival_airport
    FROM {{ source('demo', 'flights') }} 
    WHERE actual_arrival IS NOT NULL
)
SELECT
        *
FROM stg_fligths