-- Fact table: Bookings
-- Final analytical table for booking analysis with all key metrics

{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['gold', 'fact', 'bookings']
    )
}}

SELECT
    -- Surrogate key
    {{ generate_surrogate_key(['booking_ref']) }} AS booking_key,
    
    -- Natural key
    booking_ref,
    
    -- Date dimensions
    booking_date,
    booking_date_only,
    booking_year,
    booking_month,
    booking_day,
    booking_day_of_week,
    booking_day_name,
    booking_month_name,
    
    -- Financial metrics
    booking_amount_cents,
    booking_amount_currency,
    amount_per_passenger,
    
    -- Quantity metrics
    ticket_count,
    passenger_count,
    flight_segment_count,
    
    -- Categories
    min_fare_condition,
    max_fare_condition,
    booking_type,
    trip_complexity

FROM {{ ref('bookings_metrics') }}
