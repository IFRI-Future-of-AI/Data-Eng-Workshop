-- Dimension table: Aircrafts
-- Master data for aircraft analysis

{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['gold', 'dimension', 'aircrafts']
    )
}}

WITH aircraft_enriched AS (
    SELECT
        a.*,
        u.total_seats,
        u.business_seats,
        u.comfort_seats,
        u.economy_seats,
        u.total_flights,
        u.completed_flights,
        u.cancelled_flights,
        u.avg_flight_duration_minutes,
        u.avg_occupancy_rate,
        u.performance_category
    FROM {{ ref('stg_aircrafts') }} a
    LEFT JOIN {{ ref('aircraft_utilization') }} u 
        ON a.aircraft_code = u.aircraft_code
)

SELECT
    -- Surrogate key
    {{ generate_surrogate_key(['aircraft_code']) }} AS aircraft_key,
    
    -- Natural key
    aircraft_code,
    
    -- Aircraft attributes
    model_en,
    model_ru,
    range_km,
    range_category,
    
    -- Seat configuration
    COALESCE(total_seats, 0) AS total_seats,
    COALESCE(business_seats, 0) AS business_seats,
    COALESCE(comfort_seats, 0) AS comfort_seats,
    COALESCE(economy_seats, 0) AS economy_seats,
    
    -- Utilization metrics
    COALESCE(total_flights, 0) AS total_flights,
    COALESCE(completed_flights, 0) AS completed_flights,
    COALESCE(cancelled_flights, 0) AS cancelled_flights,
    COALESCE(avg_flight_duration_minutes, 0) AS avg_flight_duration_minutes,
    COALESCE(avg_occupancy_rate, 0) AS avg_occupancy_rate,
    
    -- Performance
    COALESCE(performance_category, 'Unknown') AS performance_category

FROM aircraft_enriched
