-- Analyse: Fidélité et segmentation des passagers
-- Identifie les passagers fréquents et leurs habitudes de voyage

WITH passenger_segments AS (
    SELECT
        passenger_id,
        passenger_name,
        total_tickets,
        total_bookings,
        total_flights_taken,
        lifetime_value,
        avg_segment_spend,
        total_km_traveled,
        total_hours_flown,
        preferred_cabin_class,
        first_flight_date,
        last_flight_date,
        
        -- Calcul ancienneté client
        EXTRACT(DAYS FROM (last_flight_date - first_flight_date)) AS customer_tenure_days,
        
        -- Segmentation RFM (Récence, Fréquence, Montant)
        CASE
            WHEN total_flights_taken >= 20 AND lifetime_value >= 100000 THEN 'VIP Elite'
            WHEN total_flights_taken >= 10 AND lifetime_value >= 50000 THEN 'Fidèle Premium'
            WHEN total_flights_taken >= 5 AND lifetime_value >= 20000 THEN 'Régulier'
            WHEN total_flights_taken >= 2 THEN 'Occasionnel'
            ELSE 'Nouveau'
        END AS loyalty_segment,
        
        -- Classification par type de voyageur
        CASE
            WHEN preferred_cabin_class = 'Business' THEN 'Business Traveler'
            WHEN total_flights_taken >= 10 AND preferred_cabin_class IN ('Economy', 'Comfort') THEN 'Frequent Economy'
            ELSE 'Leisure Traveler'
        END AS traveler_type,
        
        -- Valeur moyenne par vol
        lifetime_value / NULLIF(total_flights_taken, 0) AS value_per_flight
        
    FROM {{ ref('dim_passengers') }}
)

SELECT
    loyalty_segment,
    traveler_type,
    COUNT(*) AS passenger_count,
    AVG(total_flights_taken) AS avg_flights,
    AVG(lifetime_value) AS avg_lifetime_value,
    AVG(total_km_traveled) AS avg_km_traveled,
    AVG(customer_tenure_days) AS avg_tenure_days,
    SUM(lifetime_value) AS total_segment_revenue,
    -- Part du chiffre d'affaires
    ROUND(100.0 * SUM(lifetime_value) / SUM(SUM(lifetime_value)) OVER (), 2) AS revenue_share_pct
FROM passenger_segments
GROUP BY loyalty_segment, traveler_type
ORDER BY total_segment_revenue DESC
