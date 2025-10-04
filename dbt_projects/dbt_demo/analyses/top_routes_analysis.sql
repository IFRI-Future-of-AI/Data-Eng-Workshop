-- Analysis: Top Routes by Traffic
-- Identifies the most popular flight routes with detailed metrics

WITH route_metrics AS (
    SELECT
        departure_airport_code,
        departure_airport_name,
        departure_city,
        arrival_airport_code,
        arrival_airport_name,
        arrival_city,
        COUNT(*) AS total_flights,
        AVG(actual_duration_minutes) AS avg_duration_minutes,
        AVG(departure_delay_minutes) AS avg_departure_delay,
        AVG(arrival_delay_minutes) AS avg_arrival_delay,
        COUNT(DISTINCT aircraft_code) AS aircraft_types_used,
        SUM(CASE WHEN status = 'Arrived' THEN 1 ELSE 0 END) AS completed_flights,
        SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_flights
    FROM {{ ref('flights_enriched') }}
    GROUP BY 
        departure_airport_code,
        departure_airport_name,
        departure_city,
        arrival_airport_code,
        arrival_airport_name,
        arrival_city
)

SELECT
    -- Route identification
    departure_airport_code || ' → ' || arrival_airport_code AS route,
    departure_city || ' → ' || arrival_city AS city_route,
    
    -- Traffic metrics
    total_flights,
    completed_flights,
    cancelled_flights,
    ROUND(cancelled_flights * 100.0 / NULLIF(total_flights, 0), 2) AS cancellation_rate,
    
    -- Operational metrics
    ROUND(avg_duration_minutes, 0) AS avg_duration_minutes,
    ROUND(avg_departure_delay, 1) AS avg_departure_delay_minutes,
    ROUND(avg_arrival_delay, 1) AS avg_arrival_delay_minutes,
    aircraft_types_used,
    
    -- Performance rating
    CASE
        WHEN avg_departure_delay < 10 AND cancelled_flights * 100.0 / NULLIF(total_flights, 0) < 2 THEN 'Excellent'
        WHEN avg_departure_delay < 20 AND cancelled_flights * 100.0 / NULLIF(total_flights, 0) < 5 THEN 'Good'
        WHEN avg_departure_delay < 30 THEN 'Average'
        ELSE 'Poor'
    END AS route_performance

FROM route_metrics
WHERE total_flights >= 5  -- Filter routes with at least 5 flights
ORDER BY total_flights DESC
LIMIT 50
