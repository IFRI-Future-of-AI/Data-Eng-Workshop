-- Dimension table: Passagers
-- Vue unique des passagers avec métriques agrégées
{{
    config(
        materialized = 'table',
        schema = 'marts',
        tags = ['marts', 'customers', 'dimension']
    )
}}

WITH passenger_tickets AS (
    SELECT * FROM {{ ref('stg_tickets') }}
),

passenger_journeys AS (
    SELECT * FROM {{ ref('int_passenger_journeys') }}
),

passenger_metrics AS (
    SELECT
        pt.passenger_id,
        pt.passenger_name,
        pt.contact_data,
        
        -- Métriques d'activité
        COUNT(DISTINCT pt.id) AS total_tickets,
        COUNT(DISTINCT pt.id_book) AS total_bookings,
        COUNT(DISTINCT pj.flight_id) AS total_flights_taken,
        
        -- Métriques financières
        SUM(pj.segment_price) AS lifetime_value,
        AVG(pj.segment_price) AS avg_segment_spend,
        
        -- Métriques de voyage
        SUM(pj.route_distance_km) AS total_km_traveled,
        SUM(pj.actual_flight_duration_hours) AS total_hours_flown,
        
        -- Préférences de classe
        COUNT(CASE WHEN pj.cabin_class = 'Economy' THEN 1 END) AS economy_flights,
        COUNT(CASE WHEN pj.cabin_class = 'Comfort' THEN 1 END) AS comfort_flights,
        COUNT(CASE WHEN pj.cabin_class = 'Business' THEN 1 END) AS business_flights,
        
        -- Classe favorite
        MODE() WITHIN GROUP (ORDER BY pj.cabin_class) AS preferred_cabin_class,
        
        -- Dates clés
        MIN(pj.scheduled_departure) AS first_flight_date,
        MAX(pj.scheduled_departure) AS last_flight_date,
        
        -- Métadonnées
        CURRENT_TIMESTAMP AS dbt_updated_at
        
    FROM passenger_tickets pt
    LEFT JOIN passenger_journeys pj
        ON pt.id = pj.ticket_no
    GROUP BY 
        pt.passenger_id,
        pt.passenger_name,
        pt.contact_data
)

SELECT
    *
FROM passenger_metrics
