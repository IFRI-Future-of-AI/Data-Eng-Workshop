-- Modèle intermédiaire: Parcours complets des passagers
-- Reconstitue le voyage de chaque passager avec tous ses segments
{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['intermediate', 'passengers', 'journeys']
    )
}}

WITH tickets AS (
    SELECT * FROM {{ ref('stg_tickets') }}
),

ticket_flights AS (
    SELECT * FROM {{ ref('stg_ticket_flights') }}
),

flights_enriched AS (
    SELECT * FROM {{ ref('int_flights_enriched') }}
),

boarding_passes AS (
    SELECT * FROM {{ ref('stg_boarding_passes') }}
),

passenger_journey_segments AS (
    SELECT
        -- Identifiants passager et voyage
        t.id AS ticket_no,
        t.id_book AS booking_ref,
        t.passenger_id,
        t.passenger_name,
        t.contact_data,
        
        -- Informations du segment de vol
        tf.flight_id,
        f.flight_no,
        f.flight_status,
        tf.cabin_class,
        tf.segment_price,
        tf.price_category,
        
        -- Informations temporelles du segment
        f.scheduled_departure,
        f.actual_departure,
        f.scheduled_arrival,
        f.actual_arrival,
        f.actual_flight_duration_hours,
        f.departure_delay_minutes,
        f.arrival_delay_minutes,
        f.delay_category,
        
        -- Informations de route du segment
        f.departure_airport_code,
        f.departure_airport_name,
        f.departure_city,
        f.arrival_airport_code,
        f.arrival_airport_name,
        f.arrival_city,
        f.route_distance_km,
        
        -- Informations appareil
        f.aircraft_code,
        f.aircraft_model,
        f.aircraft_category,
        
        -- Informations d'embarquement
        bp.boarding_no,
        bp.seat_no,
        bp.seat_row,
        bp.seat_letter,
        
        -- Numérotation des segments par passager (ordre chronologique)
        ROW_NUMBER() OVER (
            PARTITION BY t.id 
            ORDER BY f.scheduled_departure
        ) AS segment_number,
        
        -- Comptage total de segments par passager
        COUNT(*) OVER (PARTITION BY t.id) AS total_segments_in_journey,
        
        -- Identification premier et dernier segment
        CASE 
            WHEN ROW_NUMBER() OVER (PARTITION BY t.id ORDER BY f.scheduled_departure) = 1 
            THEN 1 ELSE 0
        END AS is_first_segment,
        
        CASE 
            WHEN ROW_NUMBER() OVER (PARTITION BY t.id ORDER BY f.scheduled_departure DESC) = 1 
            THEN 1 ELSE 0
        END AS is_last_segment
        
    FROM tickets t
    INNER JOIN ticket_flights tf
        ON t.id = tf.ticket_no
    INNER JOIN flights_enriched f
        ON tf.flight_id = f.flight_id
    LEFT JOIN boarding_passes bp
        ON tf.ticket_no = bp.ticket_no
        AND tf.flight_id = bp.flight_id
),

journey_summary AS (
    SELECT
        *,
        -- Calcul du temps total de voyage
        SUM(actual_flight_duration_hours) OVER (PARTITION BY ticket_no) AS total_travel_time_hours,
        
        -- Calcul du prix total du voyage
        SUM(segment_price) OVER (PARTITION BY ticket_no) AS total_journey_price,
        
        -- Distance totale parcourue
        SUM(route_distance_km) OVER (PARTITION BY ticket_no) AS total_journey_distance_km,
        
        -- Premier aéroport (origine du voyage)
        any(departure_airport_code) OVER (
            PARTITION BY ticket_no 
            ORDER BY scheduled_departure 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS journey_origin_airport,
        
        -- Dernier aéroport (destination finale)
        anyLast(arrival_airport_code) OVER (
            PARTITION BY ticket_no 
            ORDER BY scheduled_departure 
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS journey_destination_airport,
        
        -- Métadonnées
        now() AS dbt_updated_at
        
    FROM passenger_journey_segments
)

SELECT
    *
FROM journey_summary
