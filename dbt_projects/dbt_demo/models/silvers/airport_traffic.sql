-- Intermediate model: Airport traffic metrics
-- Analyzes traffic patterns, volumes, and performance by airport

{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['silver', 'airport', 'traffic']
    )
}}

WITH flights AS (
    SELECT * FROM {{ ref('flights_enriched') }}
),

airports AS (
    SELECT * FROM {{ ref('stg_airports') }}
),

-- Departure metrics
departure_stats AS (
    SELECT
        departure_airport_code AS airport_code,
        COUNT(*) AS total_departures,
        AVG(departure_delay_minutes) AS avg_departure_delay,
        SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_departures
    FROM flights
    GROUP BY departure_airport_code
),

-- Arrival metrics
arrival_stats AS (
    SELECT
        arrival_airport_code AS airport_code,
        COUNT(*) AS total_arrivals,
        AVG(arrival_delay_minutes) AS avg_arrival_delay,
        SUM(CASE WHEN status = 'Arrived' THEN 1 ELSE 0 END) AS completed_arrivals
    FROM flights
    GROUP BY arrival_airport_code
)

SELECT
    -- Airport identification
    a.airport_code,
    a.airport_name_en,
    a.city_en,
    a.timezone,
    
    -- Departure statistics
    COALESCE(ds.total_departures, 0) AS total_departures,
    ROUND(COALESCE(ds.avg_departure_delay, 0), 2) AS avg_departure_delay_minutes,
    COALESCE(ds.cancelled_departures, 0) AS cancelled_departures,
    
    -- Arrival statistics
    COALESCE(ars.total_arrivals, 0) AS total_arrivals,
    ROUND(COALESCE(ars.avg_arrival_delay, 0), 2) AS avg_arrival_delay_minutes,
    COALESCE(ars.completed_arrivals, 0) AS completed_arrivals,
    
    -- Combined metrics
    COALESCE(ds.total_departures, 0) + COALESCE(ars.total_arrivals, 0) AS total_traffic,
    
    -- Traffic categorization
    CASE
        WHEN COALESCE(ds.total_departures, 0) + COALESCE(ars.total_arrivals, 0) > 1000 THEN 'Major Hub'
        WHEN COALESCE(ds.total_departures, 0) + COALESCE(ars.total_arrivals, 0) > 500 THEN 'Regional Hub'
        WHEN COALESCE(ds.total_departures, 0) + COALESCE(ars.total_arrivals, 0) > 100 THEN 'Secondary Airport'
        ELSE 'Small Airport'
    END AS airport_category,
    
    -- Performance indicators
    CASE
        WHEN COALESCE(ds.avg_departure_delay, 0) > 30 THEN 'Poor Performance'
        WHEN COALESCE(ds.avg_departure_delay, 0) > 15 THEN 'Below Average'
        WHEN COALESCE(ds.avg_departure_delay, 0) < 5 THEN 'Excellent'
        ELSE 'Average'
    END AS performance_rating

FROM airports a
LEFT JOIN departure_stats ds ON a.airport_code = ds.airport_code
LEFT JOIN arrival_stats ars ON a.airport_code = ars.airport_code
WHERE COALESCE(ds.total_departures, 0) + COALESCE(ars.total_arrivals, 0) > 0
