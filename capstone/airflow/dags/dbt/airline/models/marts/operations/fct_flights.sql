-- Fact table: Vols avec métriques opérationnelles
-- Table de faits pour l'analyse des performances de vols
{{
    config(
        materialized = 'table',
        schema = 'marts',
        tags = ['marts', 'operations', 'fact']
    )
}}

SELECT
    flight_id,
    flight_no,
    flight_status,
    scheduled_departure,
    actual_departure,
    scheduled_arrival,
    actual_arrival,
    actual_flight_duration_hours,
    scheduled_flight_duration_hours,
    departure_delay_minutes,
    arrival_delay_minutes,
    delay_category,
    departure_airport_code,
    arrival_airport_code,
    aircraft_code,
    route_distance_km,
    dbt_updated_at
FROM {{ ref('int_flights_enriched') }}
