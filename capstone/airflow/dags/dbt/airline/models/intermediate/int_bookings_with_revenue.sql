-- Modèle intermédiaire: Réservations avec métriques de revenus et passagers
-- Agrège les données de billets et segments de vol par réservation
{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['intermediate', 'bookings', 'revenue']
    )
}}

WITH bookings AS (
    SELECT * FROM {{ ref('stg_bookings') }}
),

tickets AS (
    SELECT * FROM {{ ref('stg_tickets') }}
),

ticket_flights AS (
    SELECT * FROM {{ ref('stg_ticket_flights') }}
),

-- Agrégation des billets par réservation
tickets_aggregated AS (
    SELECT
        t.id_book,
        COUNT(DISTINCT t.id) AS total_passengers,
        COUNT(DISTINCT t.passenger_id) AS unique_passengers,
        STRING_AGG(DISTINCT t.passenger_name, ', ') AS passenger_names
    FROM tickets t
    GROUP BY t.id_book
),

-- Agrégation des segments de vol par réservation
segments_aggregated AS (
    SELECT
        t.id_book,
        COUNT(DISTINCT tf.flight_id) AS total_flight_segments,
        SUM(tf.segment_price) AS total_segments_revenue,
        AVG(tf.segment_price) AS avg_segment_price,
        MIN(tf.segment_price) AS min_segment_price,
        MAX(tf.segment_price) AS max_segment_price,
        -- Répartition par classe
        COUNT(DISTINCT CASE WHEN tf.cabin_class = 'Economy' THEN tf.flight_id END) AS economy_segments,
        COUNT(DISTINCT CASE WHEN tf.cabin_class = 'Comfort' THEN tf.flight_id END) AS comfort_segments,
        COUNT(DISTINCT CASE WHEN tf.cabin_class = 'Business' THEN tf.flight_id END) AS business_segments
    FROM tickets t
    INNER JOIN ticket_flights tf
        ON t.id = tf.ticket_no
    GROUP BY t.id_book
),

enriched_bookings AS (
    SELECT
        -- Identifiants
        b.id AS booking_ref,
        b.date AS booking_date,
        
        -- Métriques temporelles
        EXTRACT(YEAR FROM b.date) AS booking_year,
        EXTRACT(MONTH FROM b.date) AS booking_month,
        EXTRACT(DAY FROM b.date) AS booking_day,
        TO_CHAR(b.date, 'Day') AS booking_day_of_week,
        TO_CHAR(b.date, 'YYYY-MM') AS booking_year_month,
        
        -- Métriques de revenus
        b.amount AS total_booking_amount,
        ta.total_passengers,
        ta.unique_passengers,
        b.amount / NULLIF(ta.total_passengers, 0) AS revenue_per_passenger,
        
        -- Informations passagers
        ta.passenger_names,
        
        -- Métriques de segments
        sa.total_flight_segments,
        sa.total_segments_revenue,
        sa.avg_segment_price,
        sa.min_segment_price,
        sa.max_segment_price,
        
        -- Distribution par classe
        sa.economy_segments,
        sa.comfort_segments,
        sa.business_segments,
        
        -- Type de voyage (estimation basée sur nombre de segments)
        CASE
            WHEN sa.total_flight_segments = 1 THEN 'Direct'
            WHEN sa.total_flight_segments = 2 THEN 'Aller-Retour'
            WHEN sa.total_flight_segments > 2 THEN 'Multi-destinations'
        END AS trip_type,
        
        -- Catégorie de valeur client
        CASE
            WHEN b.amount < 10000 THEN 'Économique'
            WHEN b.amount BETWEEN 10000 AND 50000 THEN 'Standard'
            WHEN b.amount BETWEEN 50000 AND 150000 THEN 'Premium'
            WHEN b.amount > 150000 THEN 'VIP'
        END AS customer_value_segment,
        
        -- Métadonnées
        CURRENT_TIMESTAMP AS dbt_updated_at
        
    FROM bookings b
    LEFT JOIN tickets_aggregated ta
        ON b.id = ta.id_book
    LEFT JOIN segments_aggregated sa
        ON b.id = sa.id_book
)

SELECT
    *
FROM enriched_bookings
