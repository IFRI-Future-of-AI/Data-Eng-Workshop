-- Dimension table: Passengers
-- Master data for passenger analysis (one row per unique passenger)

{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['gold', 'dimension', 'passengers']
    )
}}

WITH passenger_data AS (
    SELECT
        passenger_id,
        passenger_name,
        {{ extract_phone_number('contact_data') }} AS phone,
        {{ extract_email('contact_data') }} AS email,
        MIN(id_book) AS first_booking_ref,
        COUNT(DISTINCT id_book) AS total_bookings,
        COUNT(id) AS total_tickets
    FROM {{ ref('stg_tickets') }}
    GROUP BY passenger_id, passenger_name, contact_data
),

passenger_flights AS (
    SELECT
        t.passenger_id,
        COUNT(DISTINCT tf.flight_id) AS total_flights,
        SUM(tf.amount_cents) AS total_spent_cents
    FROM {{ ref('stg_tickets') }} t
    LEFT JOIN {{ ref('stg_ticket_flights') }} tf 
        ON t.id = tf.ticket_no
    GROUP BY t.passenger_id
)

SELECT
    -- Surrogate key
    {{ generate_surrogate_key(['pd.passenger_id']) }} AS passenger_key,
    
    -- Natural key
    pd.passenger_id,
    
    -- Passenger attributes
    pd.passenger_name,
    pd.phone,
    pd.email,
    
    -- Booking history
    pd.first_booking_ref,
    pd.total_bookings,
    pd.total_tickets,
    COALESCE(pf.total_flights, 0) AS total_flights,
    
    -- Financial metrics
    {{ cents_to_currency('COALESCE(pf.total_spent_cents, 0)') }} AS total_spent,
    CASE 
        WHEN COALESCE(pf.total_flights, 0) > 0 
        THEN {{ cents_to_currency('COALESCE(pf.total_spent_cents, 0)') }} / pf.total_flights
        ELSE 0 
    END AS avg_spent_per_flight,
    
    -- Passenger categorization
    CASE
        WHEN pd.total_bookings >= 10 THEN 'Frequent Flyer'
        WHEN pd.total_bookings >= 5 THEN 'Regular'
        WHEN pd.total_bookings >= 2 THEN 'Occasional'
        ELSE 'One-time'
    END AS passenger_tier

FROM passenger_data pd
LEFT JOIN passenger_flights pf 
    ON pd.passenger_id = pf.passenger_id
