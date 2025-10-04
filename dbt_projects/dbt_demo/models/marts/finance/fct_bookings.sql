-- Fact table: Réservations avec métriques financières
-- Table de faits pour l'analyse des revenus et réservations
{{
    config(
        materialized = 'table',
        schema = 'marts',
        tags = ['marts', 'finance', 'fact']
    )
}}

SELECT
    booking_ref,
    booking_date,
    booking_year,
    booking_month,
    booking_day,
    booking_day_of_week,
    booking_year_month,
    total_booking_amount,
    total_passengers,
    unique_passengers,
    revenue_per_passenger,
    total_flight_segments,
    total_segments_revenue,
    avg_segment_price,
    economy_segments,
    comfort_segments,
    business_segments,
    trip_type,
    customer_value_segment,
    dbt_updated_at
FROM {{ ref('int_bookings_with_revenue') }}
