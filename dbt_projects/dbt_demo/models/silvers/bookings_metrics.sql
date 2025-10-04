-- Intermediate model: Bookings with aggregated metrics
-- Enriches bookings with ticket count, passenger count, and flight segments

{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['silver', 'bookings', 'metrics']
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

-- Aggregate ticket-level information
ticket_agg AS (
    SELECT
        t.id_book,
        COUNT(DISTINCT t.id) AS ticket_count,
        COUNT(DISTINCT t.passenger_id) AS passenger_count,
        COUNT(DISTINCT tf.flight_id) AS flight_segment_count,
        SUM(tf.amount_cents) AS total_ticket_flight_amount_cents,
        MIN(tf.fare_conditions) AS min_fare_condition,
        MAX(tf.fare_conditions) AS max_fare_condition
    FROM tickets t
    LEFT JOIN ticket_flights tf ON t.id = tf.ticket_no
    GROUP BY t.id_book
)

SELECT
    -- Booking identifiers
    b.id AS booking_ref,
    b.date AS booking_date,
    
    -- Date components for analysis
    DATE(b.date) AS booking_date_only,
    EXTRACT(YEAR FROM b.date) AS booking_year,
    EXTRACT(MONTH FROM b.date) AS booking_month,
    EXTRACT(DAY FROM b.date) AS booking_day,
    EXTRACT(DOW FROM b.date) AS booking_day_of_week,
    TO_CHAR(b.date, 'Day') AS booking_day_name,
    TO_CHAR(b.date, 'Month') AS booking_month_name,
    
    -- Financial information
    b.amount AS booking_amount_cents,
    {{ cents_to_currency('b.amount') }} AS booking_amount_currency,
    
    -- Aggregated metrics
    COALESCE(ta.ticket_count, 0) AS ticket_count,
    COALESCE(ta.passenger_count, 0) AS passenger_count,
    COALESCE(ta.flight_segment_count, 0) AS flight_segment_count,
    
    -- Per-passenger metrics
    CASE 
        WHEN COALESCE(ta.passenger_count, 0) > 0 
        THEN {{ cents_to_currency('b.amount') }} / ta.passenger_count
        ELSE 0
    END AS amount_per_passenger,
    
    -- Fare class information
    ta.min_fare_condition,
    ta.max_fare_condition,
    
    -- Booking type categorization
    CASE
        WHEN COALESCE(ta.passenger_count, 0) = 1 THEN 'Solo'
        WHEN COALESCE(ta.passenger_count, 0) = 2 THEN 'Couple'
        WHEN COALESCE(ta.passenger_count, 0) BETWEEN 3 AND 5 THEN 'Small Group'
        WHEN COALESCE(ta.passenger_count, 0) > 5 THEN 'Large Group'
        ELSE 'Unknown'
    END AS booking_type,
    
    CASE
        WHEN COALESCE(ta.flight_segment_count, 0) = 1 THEN 'Direct'
        WHEN COALESCE(ta.flight_segment_count, 0) = 2 THEN 'One Stop'
        WHEN COALESCE(ta.flight_segment_count, 0) > 2 THEN 'Multiple Stops'
        ELSE 'Unknown'
    END AS trip_complexity

FROM bookings b
LEFT JOIN ticket_agg ta ON b.id = ta.id_book
