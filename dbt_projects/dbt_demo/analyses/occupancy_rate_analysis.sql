-- Analysis: Flight Occupancy Rate
-- Analyzes seat occupancy rates by aircraft, route, and time period

WITH flight_occupancy AS (
    SELECT
        f.flight_id,
        f.flight_no,
        f.departure_airport_code,
        f.arrival_airport_code,
        f.aircraft_code,
        DATE(f.scheduled_departure) AS flight_date,
        a.total_seats,
        COUNT(bp.ticket_no) AS seats_occupied
    FROM {{ ref('flights_enriched') }} f
    LEFT JOIN {{ ref('dim_aircrafts') }} a 
        ON f.aircraft_code = a.aircraft_code
    LEFT JOIN {{ ref('stg_boarding_passes') }} bp 
        ON f.flight_id = bp.flight_id
    WHERE f.status IN ('Departed', 'Arrived')
    GROUP BY 
        f.flight_id,
        f.flight_no,
        f.departure_airport_code,
        f.arrival_airport_code,
        f.aircraft_code,
        DATE(f.scheduled_departure),
        a.total_seats
),

occupancy_metrics AS (
    SELECT
        *,
        CASE 
            WHEN total_seats > 0 THEN ROUND((seats_occupied * 100.0 / total_seats), 2)
            ELSE 0
        END AS occupancy_rate,
        total_seats - seats_occupied AS empty_seats
    FROM flight_occupancy
)

SELECT
    -- Flight identification
    flight_no,
    flight_date,
    departure_airport_code || ' → ' || arrival_airport_code AS route,
    aircraft_code,
    
    -- Capacity metrics
    total_seats,
    seats_occupied,
    empty_seats,
    occupancy_rate,
    
    -- Occupancy categorization
    CASE
        WHEN occupancy_rate >= 90 THEN 'Full (90%+)'
        WHEN occupancy_rate >= 75 THEN 'High (75-90%)'
        WHEN occupancy_rate >= 50 THEN 'Medium (50-75%)'
        WHEN occupancy_rate >= 25 THEN 'Low (25-50%)'
        ELSE 'Very Low (<25%)'
    END AS occupancy_category,
    
    -- Revenue opportunity
    CASE
        WHEN occupancy_rate < 50 THEN 'High Risk - Low Occupancy'
        WHEN occupancy_rate < 75 THEN 'Room for Improvement'
        ELSE 'Healthy Occupancy'
    END AS revenue_health

FROM occupancy_metrics
ORDER BY flight_date DESC, occupancy_rate ASC
