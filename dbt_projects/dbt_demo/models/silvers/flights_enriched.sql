-- Intermediate model: Flights enriched with airport and aircraft information
-- Joins flights with airports (departure/arrival) and aircrafts data

{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['silver', 'flights', 'enriched']
    )
}}

WITH flights AS (
    SELECT * FROM {{ ref('stg_fligths') }}
),

airports AS (
    SELECT * FROM {{ ref('stg_airports') }}
),

aircrafts AS (
    SELECT * FROM {{ ref('stg_aircrafts') }}
)

SELECT
    -- Flight identifiers
    f.id AS flight_id,
    f.no AS flight_no,
    
    -- Timing information
    f.scheduled_departure,
    f.actual_departure,
    f.scheduled_arrival,
    f.actual_arrival,
    f.status,
    
    -- Calculate durations using macro
    {{ get_flight_duration('f.scheduled_departure', 'f.scheduled_arrival', 'minutes') }} AS scheduled_duration_minutes,
    {{ get_flight_duration('f.actual_departure', 'f.actual_arrival', 'minutes') }} AS actual_duration_minutes,
    
    -- Calculate delays using macro
    {{ calculate_delay('f.scheduled_departure', 'f.actual_departure', 'minutes') }} AS departure_delay_minutes,
    {{ calculate_delay('f.scheduled_arrival', 'f.actual_arrival', 'minutes') }} AS arrival_delay_minutes,
    
    -- Status categorization
    {{ categorize_flight_status('f.status') }} AS status_fr,
    
    -- Departure airport information
    f.departure_airport AS departure_airport_code,
    dep_airport.airport_name_en AS departure_airport_name,
    dep_airport.city_en AS departure_city,
    dep_airport.timezone AS departure_timezone,
    
    -- Arrival airport information
    f.arrival_airport AS arrival_airport_code,
    arr_airport.airport_name_en AS arrival_airport_name,
    arr_airport.city_en AS arrival_city,
    arr_airport.timezone AS arrival_timezone,
    
    -- Aircraft information
    f.aircraft_code,
    ac.model_en AS aircraft_model,
    ac.range_km AS aircraft_range_km,
    ac.range_category AS aircraft_range_category

FROM flights f
LEFT JOIN airports dep_airport 
    ON f.departure_airport = dep_airport.airport_code
LEFT JOIN airports arr_airport 
    ON f.arrival_airport = arr_airport.airport_code
LEFT JOIN aircrafts ac 
    ON f.aircraft_code = ac.aircraft_code
