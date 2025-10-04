-- Analyse: Performance de ponctualité des vols
-- Évalue les retards par route, appareil et période

WITH flight_performance AS (
    SELECT
        flight_id,
        flight_no,
        departure_airport_code || ' → ' || arrival_airport_code AS route,
        aircraft_model,
        scheduled_departure,
        actual_departure,
        scheduled_arrival,
        actual_arrival,
        departure_delay_minutes,
        arrival_delay_minutes,
        delay_category,
        
        -- Classification de performance
        CASE
            WHEN arrival_delay_minutes <= 0 THEN 'À l''heure'
            WHEN arrival_delay_minutes <= 15 THEN 'Acceptable'
            WHEN arrival_delay_minutes <= 60 THEN 'Retardé'
            ELSE 'Très retardé'
        END AS performance_category,
        
        -- Date pour analyse temporelle
        DATE_TRUNC('month', scheduled_departure) AS month,
        TO_CHAR(scheduled_departure, 'Day') AS day_of_week,
        EXTRACT(HOUR FROM scheduled_departure) AS departure_hour
    FROM {{ ref('fct_flights') }}
),

route_performance AS (
    SELECT
        route,
        COUNT(*) AS total_flights,
        
        -- Statistiques de retards
        AVG(arrival_delay_minutes) AS avg_delay_minutes,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY arrival_delay_minutes) AS median_delay_minutes,
        MAX(arrival_delay_minutes) AS max_delay_minutes,
        
        -- Taux de ponctualité
        ROUND(100.0 * COUNT(CASE WHEN arrival_delay_minutes <= 15 THEN 1 END) / COUNT(*), 2) AS on_time_rate_pct,
        ROUND(100.0 * COUNT(CASE WHEN arrival_delay_minutes > 60 THEN 1 END) / COUNT(*), 2) AS severe_delay_rate_pct,
        
        -- Répartition des performances
        COUNT(CASE WHEN performance_category = 'À l''heure' THEN 1 END) AS on_time_flights,
        COUNT(CASE WHEN performance_category = 'Acceptable' THEN 1 END) AS acceptable_flights,
        COUNT(CASE WHEN performance_category = 'Retardé' THEN 1 END) AS delayed_flights,
        COUNT(CASE WHEN performance_category = 'Très retardé' THEN 1 END) AS severely_delayed_flights
    FROM flight_performance
    GROUP BY route
),

aircraft_performance AS (
    SELECT
        aircraft_model,
        COUNT(*) AS total_flights,
        AVG(arrival_delay_minutes) AS avg_delay_minutes,
        ROUND(100.0 * COUNT(CASE WHEN arrival_delay_minutes <= 15 THEN 1 END) / COUNT(*), 2) AS on_time_rate_pct
    FROM flight_performance
    GROUP BY aircraft_model
)

-- Performance par route
SELECT
    'Par Route' AS analysis_type,
    route AS category,
    total_flights,
    avg_delay_minutes,
    on_time_rate_pct,
    severe_delay_rate_pct,
    on_time_flights,
    delayed_flights
FROM route_performance
WHERE total_flights >= 5  -- Seuil minimum pour statistiques significatives
ORDER BY on_time_rate_pct ASC
LIMIT 20

UNION ALL

-- Performance par appareil
SELECT
    'Par Appareil' AS analysis_type,
    aircraft_model AS category,
    total_flights,
    avg_delay_minutes,
    on_time_rate_pct,
    NULL AS severe_delay_rate_pct,
    NULL AS on_time_flights,
    NULL AS delayed_flights
FROM aircraft_performance
ORDER BY on_time_rate_pct ASC
