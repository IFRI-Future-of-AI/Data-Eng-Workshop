-- Intermediate model: Aircraft utilization metrics
-- Analyzes aircraft usage, flight counts, and performance

{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['silver', 'aircraft', 'utilization']
    )
}}

WITH flights AS (
    SELECT * FROM {{ ref('flights_enriched') }}
),

seats AS (
    SELECT * FROM {{ ref('stg_seats') }}
),

boarding_passes AS (
    SELECT * FROM {{ ref('stg_boarding_passes') }}
),

-- Aggregate seat information by aircraft
seat_config AS (
    SELECT
        aircraft_code,
        COUNT(*) AS total_seats,
        SUM(CASE WHEN fare_conditions = 'Business' THEN 1 ELSE 0 END) AS business_seats,
        SUM(CASE WHEN fare_conditions = 'Comfort' THEN 1 ELSE 0 END) AS comfort_seats,
        SUM(CASE WHEN fare_conditions = 'Economy' THEN 1 ELSE 0 END) AS economy_seats
    FROM seats
    GROUP BY aircraft_code
),

-- Aggregate flight information by aircraft
flight_stats AS (
    SELECT
        aircraft_code,
        COUNT(*) AS total_flights,
        AVG(actual_duration_minutes) AS avg_flight_duration_minutes,
        AVG(departure_delay_minutes) AS avg_departure_delay_minutes,
        AVG(arrival_delay_minutes) AS avg_arrival_delay_minutes,
        SUM(CASE WHEN status = 'Arrived' THEN 1 ELSE 0 END) AS completed_flights,
        SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_flights
    FROM flights
    GROUP BY aircraft_code
),

-- Count passengers per flight
passenger_counts AS (
    SELECT
        f.aircraft_code,
        f.flight_id,
        COUNT(bp.ticket_no) AS passengers_boarded,
        sc.total_seats
    FROM flights f
    LEFT JOIN boarding_passes bp ON f.flight_id = bp.flight_id
    LEFT JOIN seat_config sc ON f.aircraft_code = sc.aircraft_code
    GROUP BY f.aircraft_code, f.flight_id, sc.total_seats
),

-- Calculate occupancy rates
occupancy_stats AS (
    SELECT
        aircraft_code,
        AVG(CASE WHEN total_seats > 0 
            THEN (passengers_boarded * 100.0 / total_seats) 
            ELSE 0 END) AS avg_occupancy_rate
    FROM passenger_counts
    GROUP BY aircraft_code
)

SELECT
    -- Aircraft identification
    f.aircraft_code,
    f.aircraft_model,
    f.aircraft_range_km,
    f.aircraft_range_category,
    
    -- Seat configuration
    sc.total_seats,
    sc.business_seats,
    sc.comfort_seats,
    sc.economy_seats,
    
    -- Flight statistics
    fs.total_flights,
    fs.completed_flights,
    fs.cancelled_flights,
    ROUND(fs.avg_flight_duration_minutes, 2) AS avg_flight_duration_minutes,
    ROUND(fs.avg_departure_delay_minutes, 2) AS avg_departure_delay_minutes,
    ROUND(fs.avg_arrival_delay_minutes, 2) AS avg_arrival_delay_minutes,
    
    -- Occupancy metrics
    ROUND(os.avg_occupancy_rate, 2) AS avg_occupancy_rate,
    
    -- Performance indicators
    CASE
        WHEN fs.cancelled_flights * 100.0 / NULLIF(fs.total_flights, 0) > 5 THEN 'Poor'
        WHEN fs.avg_departure_delay_minutes > 30 THEN 'Below Average'
        WHEN os.avg_occupancy_rate > 80 THEN 'Excellent'
        WHEN os.avg_occupancy_rate > 60 THEN 'Good'
        ELSE 'Average'
    END AS performance_category

FROM (SELECT DISTINCT aircraft_code, aircraft_model, aircraft_range_km, aircraft_range_category 
      FROM flights) f
LEFT JOIN seat_config sc ON f.aircraft_code = sc.aircraft_code
LEFT JOIN flight_stats fs ON f.aircraft_code = fs.aircraft_code
LEFT JOIN occupancy_stats os ON f.aircraft_code = os.aircraft_code
