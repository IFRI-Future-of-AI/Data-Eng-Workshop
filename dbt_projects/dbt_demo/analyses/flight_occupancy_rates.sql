-- Analyse: Taux d'occupation des vols
-- Calcule le taux de remplissage des avions pour optimiser la capacité

WITH flight_capacity AS (
    SELECT
        f.flight_id,
        f.flight_no,
        f.departure_airport_code,
        f.arrival_airport_code,
        f.aircraft_code,
        f.aircraft_model,
        COUNT(DISTINCT s.seat_no) AS total_seats
    FROM {{ ref('int_flights_enriched') }} f
    INNER JOIN {{ ref('stg_seats') }} s
        ON f.aircraft_code = s.aircraft_code
    GROUP BY
        f.flight_id,
        f.flight_no,
        f.departure_airport_code,
        f.arrival_airport_code,
        f.aircraft_code,
        f.aircraft_model
),

flight_bookings AS (
    SELECT
        pj.flight_id,
        COUNT(DISTINCT pj.ticket_no) AS booked_seats
    FROM {{ ref('int_passenger_journeys') }} pj
    GROUP BY pj.flight_id
),

occupancy_analysis AS (
    SELECT
        fc.flight_id,
        fc.flight_no,
        fc.departure_airport_code || ' → ' || fc.arrival_airport_code AS route,
        fc.aircraft_model,
        fc.total_seats,
        COALESCE(fb.booked_seats, 0) AS booked_seats,
        fc.total_seats - COALESCE(fb.booked_seats, 0) AS empty_seats,
        ROUND(100.0 * COALESCE(fb.booked_seats, 0) / NULLIF(fc.total_seats, 0), 2) AS occupancy_rate,
        CASE
            WHEN COALESCE(fb.booked_seats, 0) = fc.total_seats THEN 'Complet'
            WHEN COALESCE(fb.booked_seats, 0) >= fc.total_seats * 0.85 THEN 'Quasi-complet'
            WHEN COALESCE(fb.booked_seats, 0) >= fc.total_seats * 0.60 THEN 'Bon remplissage'
            WHEN COALESCE(fb.booked_seats, 0) >= fc.total_seats * 0.40 THEN 'Moyen'
            ELSE 'Faible'
        END AS occupancy_category
    FROM flight_capacity fc
    LEFT JOIN flight_bookings fb
        ON fc.flight_id = fb.flight_id
)

SELECT
    route,
    COUNT(*) AS total_flights,
    AVG(occupancy_rate) AS avg_occupancy_rate,
    MIN(occupancy_rate) AS min_occupancy_rate,
    MAX(occupancy_rate) AS max_occupancy_rate,
    SUM(booked_seats) AS total_passengers,
    SUM(empty_seats) AS total_empty_seats,
    COUNT(CASE WHEN occupancy_category = 'Complet' THEN 1 END) AS full_flights,
    COUNT(CASE WHEN occupancy_category = 'Faible' THEN 1 END) AS low_occupancy_flights
FROM occupancy_analysis
GROUP BY route
ORDER BY avg_occupancy_rate DESC
