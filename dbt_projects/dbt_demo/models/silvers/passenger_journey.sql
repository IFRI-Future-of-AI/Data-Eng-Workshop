-- Intermediate model: Complete passenger journey
-- Tracks the full journey of each passenger from booking to boarding

{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['silver', 'passenger', 'journey']
    )
}}

WITH tickets AS (
    SELECT * FROM {{ ref('stg_tickets') }}
),

bookings AS (
    SELECT * FROM {{ ref('stg_bookings') }}
),

ticket_flights AS (
    SELECT * FROM {{ ref('stg_ticket_flights') }}
),

flights AS (
    SELECT * FROM {{ ref('flights_enriched') }}
),

boarding_passes AS (
    SELECT * FROM {{ ref('stg_boarding_passes') }}
)

SELECT
    -- Passenger identification
    t.passenger_id,
    t.passenger_name,
    {{ extract_phone_number('t.contact_data') }} AS passenger_phone,
    {{ extract_email('t.contact_data') }} AS passenger_email,
    
    -- Booking information
    t.id_book AS booking_ref,
    b.date AS booking_date,
    {{ cents_to_currency('b.amount') }} AS booking_amount,
    
    -- Ticket information
    t.id AS ticket_no,
    
    -- Flight segment information
    tf.flight_id,
    f.flight_no,
    tf.fare_conditions,
    {{ cents_to_currency('tf.amount_cents') }} AS segment_amount,
    
    -- Flight details
    f.scheduled_departure,
    f.actual_departure,
    f.scheduled_arrival,
    f.actual_arrival,
    f.status,
    f.status_fr,
    f.departure_airport_code,
    f.departure_airport_name,
    f.departure_city,
    f.arrival_airport_code,
    f.arrival_airport_name,
    f.arrival_city,
    f.aircraft_model,
    
    -- Boarding information
    bp.boarding_no,
    bp.seat_no,
    bp.seat_location_type,
    bp.boarding_group,
    
    -- Journey status
    CASE
        WHEN bp.ticket_no IS NOT NULL THEN 'Boarded'
        WHEN f.status = 'Arrived' THEN 'Flight Completed (Not Boarded)'
        WHEN f.status IN ('Departed', 'On Time', 'Delayed') THEN 'Flight Active'
        WHEN f.status = 'Cancelled' THEN 'Flight Cancelled'
        ELSE 'Scheduled'
    END AS journey_status

FROM tickets t
INNER JOIN bookings b ON t.id_book = b.id
LEFT JOIN ticket_flights tf ON t.id = tf.ticket_no
LEFT JOIN flights f ON tf.flight_id = f.flight_id
LEFT JOIN boarding_passes bp ON t.id = bp.ticket_no AND tf.flight_id = bp.flight_id
