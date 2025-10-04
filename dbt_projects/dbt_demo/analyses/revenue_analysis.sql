-- Analysis: Revenue Analysis
-- Comprehensive revenue breakdown by time period, fare class, and route

WITH daily_revenue AS (
    SELECT
        booking_date_only,
        booking_year,
        booking_month,
        booking_day_of_week,
        booking_day_name,
        booking_month_name,
        fare_conditions,
        COUNT(*) AS booking_count,
        SUM(booking_amount_currency) AS total_revenue,
        SUM(passenger_count) AS total_passengers,
        AVG(booking_amount_currency) AS avg_booking_value,
        AVG(amount_per_passenger) AS avg_per_passenger
    FROM {{ ref('fct_bookings') }} fb
    LEFT JOIN {{ ref('stg_ticket_flights') }} tf 
        ON fb.booking_ref = (SELECT id_book FROM {{ ref('stg_tickets') }} WHERE id = tf.ticket_no LIMIT 1)
    GROUP BY 
        booking_date_only,
        booking_year,
        booking_month,
        booking_day_of_week,
        booking_day_name,
        booking_month_name,
        fare_conditions
)

SELECT
    -- Time dimensions
    booking_date_only AS date,
    booking_year AS year,
    booking_month AS month,
    booking_month_name,
    booking_day_name,
    
    -- Fare class
    COALESCE(fare_conditions, 'Unknown') AS fare_class,
    
    -- Volume metrics
    booking_count,
    total_passengers,
    
    -- Revenue metrics
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(avg_booking_value, 2) AS avg_booking_value,
    ROUND(avg_per_passenger, 2) AS avg_revenue_per_passenger,
    
    -- Day type indicator
    CASE 
        WHEN booking_day_of_week IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type

FROM daily_revenue
ORDER BY booking_date_only DESC, fare_conditions
