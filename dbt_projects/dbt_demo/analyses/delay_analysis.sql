-- Analysis: Flight Delay Patterns
-- Analyzes delay patterns by airport, time of day, day of week, and aircraft

WITH flight_delays AS (
    SELECT
        f.*,
        EXTRACT(HOUR FROM f.scheduled_departure) AS departure_hour,
        EXTRACT(DOW FROM f.scheduled_departure) AS day_of_week,
        TO_CHAR(f.scheduled_departure, 'Day') AS day_name,
        CASE
            WHEN EXTRACT(HOUR FROM f.scheduled_departure) BETWEEN 6 AND 11 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM f.scheduled_departure) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN EXTRACT(HOUR FROM f.scheduled_departure) BETWEEN 18 AND 23 THEN 'Evening'
            ELSE 'Night'
        END AS time_of_day
    FROM {{ ref('flights_enriched') }} f
    WHERE f.actual_departure IS NOT NULL
)

SELECT
    -- Grouping dimensions
    departure_airport_code,
    departure_airport_name,
    time_of_day,
    day_name,
    
    -- Flight counts
    COUNT(*) AS total_flights,
    
    -- Delay metrics
    ROUND(AVG(departure_delay_minutes), 1) AS avg_departure_delay,
    ROUND(AVG(arrival_delay_minutes), 1) AS avg_arrival_delay,
    MAX(departure_delay_minutes) AS max_departure_delay,
    MAX(arrival_delay_minutes) AS max_arrival_delay,
    
    -- Delay categories
    SUM(CASE WHEN departure_delay_minutes <= 0 THEN 1 ELSE 0 END) AS on_time_or_early,
    SUM(CASE WHEN departure_delay_minutes BETWEEN 1 AND 15 THEN 1 ELSE 0 END) AS minor_delay,
    SUM(CASE WHEN departure_delay_minutes BETWEEN 16 AND 30 THEN 1 ELSE 0 END) AS moderate_delay,
    SUM(CASE WHEN departure_delay_minutes > 30 THEN 1 ELSE 0 END) AS severe_delay,
    
    -- Performance percentages
    ROUND(SUM(CASE WHEN departure_delay_minutes <= 15 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS on_time_performance,
    
    -- Risk assessment
    CASE
        WHEN AVG(departure_delay_minutes) > 30 THEN 'High Delay Risk'
        WHEN AVG(departure_delay_minutes) > 15 THEN 'Moderate Delay Risk'
        ELSE 'Low Delay Risk'
    END AS delay_risk_level

FROM flight_delays
GROUP BY 
    departure_airport_code,
    departure_airport_name,
    time_of_day,
    day_name
HAVING COUNT(*) >= 3  -- Filter for statistical significance
ORDER BY avg_departure_delay DESC
