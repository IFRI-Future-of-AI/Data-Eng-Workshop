-- Fact table: Flights
-- Final analytical table for flight performance analysis

{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['gold', 'fact', 'flights']
    )
}}

SELECT
    -- Surrogate key
    {{ generate_surrogate_key(['flight_id']) }} AS flight_key,
    
    -- Natural key
    flight_id,
    flight_no,
    
    -- Foreign keys to dimensions
    {{ generate_surrogate_key(['departure_airport_code']) }} AS departure_airport_key,
    {{ generate_surrogate_key(['arrival_airport_code']) }} AS arrival_airport_key,
    {{ generate_surrogate_key(['aircraft_code']) }} AS aircraft_key,
    
    -- Temporal information
    scheduled_departure,
    actual_departure,
    scheduled_arrival,
    actual_arrival,
    
    -- Status
    status,
    status_fr,
    
    -- Duration metrics
    scheduled_duration_minutes,
    actual_duration_minutes,
    
    -- Delay metrics
    departure_delay_minutes,
    arrival_delay_minutes,
    
    -- Delay categorization
    CASE
        WHEN departure_delay_minutes > 60 THEN 'Severe Delay'
        WHEN departure_delay_minutes > 30 THEN 'Moderate Delay'
        WHEN departure_delay_minutes > 15 THEN 'Minor Delay'
        WHEN departure_delay_minutes BETWEEN -5 AND 15 THEN 'On Time'
        ELSE 'Early'
    END AS departure_performance,
    
    CASE
        WHEN arrival_delay_minutes > 60 THEN 'Severe Delay'
        WHEN arrival_delay_minutes > 30 THEN 'Moderate Delay'
        WHEN arrival_delay_minutes > 15 THEN 'Minor Delay'
        WHEN arrival_delay_minutes BETWEEN -5 AND 15 THEN 'On Time'
        ELSE 'Early'
    END AS arrival_performance,
    
    -- Route information (natural keys for joins)
    departure_airport_code,
    arrival_airport_code,
    aircraft_code

FROM {{ ref('flights_enriched') }}
