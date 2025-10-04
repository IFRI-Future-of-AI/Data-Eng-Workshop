-- Dimension table: Airports
-- Master data for airport analysis

{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['gold', 'dimension', 'airports']
    )
}}

WITH airport_enriched AS (
    SELECT
        a.*,
        t.total_traffic,
        t.airport_category,
        t.performance_rating,
        t.total_departures,
        t.total_arrivals,
        t.avg_departure_delay_minutes,
        t.avg_arrival_delay_minutes
    FROM {{ ref('stg_airports') }} a
    LEFT JOIN {{ ref('airport_traffic') }} t 
        ON a.airport_code = t.airport_code
)

SELECT
    -- Surrogate key
    {{ generate_surrogate_key(['airport_code']) }} AS airport_key,
    
    -- Natural key
    airport_code,
    
    -- Airport attributes
    airport_name_en,
    airport_name_ru,
    city_en,
    city_ru,
    timezone,
    coordinates,
    coordinates_text,
    
    -- Traffic metrics
    COALESCE(total_traffic, 0) AS total_traffic,
    COALESCE(total_departures, 0) AS total_departures,
    COALESCE(total_arrivals, 0) AS total_arrivals,
    
    -- Performance metrics
    COALESCE(avg_departure_delay_minutes, 0) AS avg_departure_delay_minutes,
    COALESCE(avg_arrival_delay_minutes, 0) AS avg_arrival_delay_minutes,
    
    -- Categories
    COALESCE(airport_category, 'Small Airport') AS airport_category,
    COALESCE(performance_rating, 'Unknown') AS performance_rating

FROM airport_enriched
