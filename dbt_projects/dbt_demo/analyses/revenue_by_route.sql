-- Analyse: Revenus par route aérienne
-- Identifie les routes les plus rentables pour optimiser l'offre

WITH flight_revenue AS (
    SELECT
        f.departure_airport_code,
        f.departure_city,
        f.arrival_airport_code,
        f.arrival_city,
        f.route_distance_km,
        COUNT(DISTINCT pj.ticket_no) AS total_passengers,
        COUNT(DISTINCT pj.flight_id) AS total_flights,
        SUM(pj.segment_price) AS total_revenue,
        AVG(pj.segment_price) AS avg_ticket_price,
        SUM(pj.segment_price) / NULLIF(COUNT(DISTINCT pj.flight_id), 0) AS revenue_per_flight,
        SUM(pj.segment_price) / NULLIF(f.route_distance_km * COUNT(DISTINCT pj.flight_id), 0) AS revenue_per_km
    FROM {{ ref('int_flights_enriched') }} f
    INNER JOIN {{ ref('int_passenger_journeys') }} pj
        ON f.flight_id = pj.flight_id
    GROUP BY
        f.departure_airport_code,
        f.departure_city,
        f.arrival_airport_code,
        f.arrival_city,
        f.route_distance_km
)

SELECT
    departure_airport_code || ' → ' || arrival_airport_code AS route,
    departure_city || ' → ' || arrival_city AS city_route,
    route_distance_km,
    total_passengers,
    total_flights,
    total_revenue,
    avg_ticket_price,
    revenue_per_flight,
    revenue_per_km,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY revenue_per_km DESC) AS efficiency_rank
FROM flight_revenue
ORDER BY total_revenue DESC
LIMIT 50
