-- Analysis: Passenger Segmentation
-- Segments passengers by travel patterns, spending, and loyalty

WITH passenger_summary AS (
    SELECT
        p.passenger_id,
        p.passenger_name,
        p.passenger_tier,
        p.total_bookings,
        p.total_flights,
        p.total_spent,
        p.avg_spent_per_flight,
        
        -- Calculate additional metrics from journey data
        COUNT(DISTINCT j.booking_ref) AS unique_bookings,
        COUNT(DISTINCT j.flight_id) AS unique_flights,
        MIN(j.booking_date) AS first_booking_date,
        MAX(j.booking_date) AS last_booking_date,
        COUNT(DISTINCT j.departure_airport_code) AS airports_departed_from,
        COUNT(DISTINCT j.arrival_airport_code) AS airports_arrived_at,
        COUNT(DISTINCT DATE(j.scheduled_departure)) AS travel_days,
        
        -- Fare class preferences
        MAX(CASE WHEN j.fare_conditions = 'Business' THEN 1 ELSE 0 END) AS uses_business,
        MAX(CASE WHEN j.fare_conditions = 'Comfort' THEN 1 ELSE 0 END) AS uses_comfort,
        MAX(CASE WHEN j.fare_conditions = 'Economy' THEN 1 ELSE 0 END) AS uses_economy
        
    FROM {{ ref('dim_passengers') }} p
    LEFT JOIN {{ ref('passenger_journey') }} j 
        ON p.passenger_id = j.passenger_id
    GROUP BY 
        p.passenger_id,
        p.passenger_name,
        p.passenger_tier,
        p.total_bookings,
        p.total_flights,
        p.total_spent,
        p.avg_spent_per_flight
)

SELECT
    -- Passenger identification
    passenger_id,
    passenger_name,
    passenger_tier,
    
    -- Travel metrics
    total_bookings,
    total_flights,
    travel_days,
    airports_departed_from,
    airports_arrived_at,
    
    -- Financial metrics
    ROUND(total_spent, 2) AS total_spent,
    ROUND(avg_spent_per_flight, 2) AS avg_spent_per_flight,
    
    -- Travel pattern
    first_booking_date,
    last_booking_date,
    EXTRACT(DAY FROM (last_booking_date - first_booking_date)) AS customer_lifetime_days,
    
    -- Preferred fare class
    CASE
        WHEN uses_business = 1 THEN 'Business Traveler'
        WHEN uses_comfort = 1 THEN 'Comfort Seeker'
        ELSE 'Economy Traveler'
    END AS travel_preference,
    
    -- Value segmentation
    CASE
        WHEN total_spent > 100000 THEN 'VIP'
        WHEN total_spent > 50000 THEN 'High Value'
        WHEN total_spent > 20000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS value_segment,
    
    -- Travel frequency
    CASE
        WHEN total_bookings >= 10 THEN 'Very Frequent'
        WHEN total_bookings >= 5 THEN 'Frequent'
        WHEN total_bookings >= 2 THEN 'Occasional'
        ELSE 'Rare'
    END AS frequency_segment,
    
    -- Geographic diversity
    CASE
        WHEN airports_departed_from + airports_arrived_at > 10 THEN 'Diverse Traveler'
        WHEN airports_departed_from + airports_arrived_at > 5 THEN 'Moderate Variety'
        ELSE 'Limited Routes'
    END AS geographic_diversity

FROM passenger_summary
WHERE total_bookings > 0
ORDER BY total_spent DESC
