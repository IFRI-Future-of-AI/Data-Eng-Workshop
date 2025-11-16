-- Modèle intermédiaire: Vols enrichis avec informations aéroports et appareils
-- Consolide les données de vols avec leurs contextes opérationnels
{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['intermediate', 'flights', 'enriched']
    )
}}

WITH flights AS (
    SELECT * FROM {{ ref('stg_fligths') }}
),

departure_airports AS (
    SELECT * FROM {{ ref('stg_airports') }}
),

arrival_airports AS (
    SELECT * FROM {{ ref('stg_airports') }}
),

aircrafts AS (
    SELECT * FROM {{ ref('stg_aircrafts') }}
),

enriched_flights AS (
    SELECT
        -- Identifiants du vol
        f.id AS flight_id,
        f.no AS flight_no,
        f.status AS flight_status,
        
        -- Informations temporelles
        f.scheduled_departure,
        f.actual_departure,
        f.scheduled_arrival,
        f.actual_arrival,
        
        -- Calcul de la durée de vol
        EXTRACT(EPOCH FROM (f.actual_arrival - f.actual_departure))/3600 AS actual_flight_duration_hours,
        EXTRACT(EPOCH FROM (f.scheduled_arrival - f.scheduled_departure))/3600 AS scheduled_flight_duration_hours,
        
        -- Calcul des retards
        EXTRACT(EPOCH FROM (f.actual_departure - f.scheduled_departure))/60 AS departure_delay_minutes,
        EXTRACT(EPOCH FROM (f.actual_arrival - f.scheduled_arrival))/60 AS arrival_delay_minutes,
        
        -- Classification du retard
        CASE
            WHEN EXTRACT(EPOCH FROM (f.actual_arrival - f.scheduled_arrival))/60 <= 0 THEN 'À l''heure'
            WHEN EXTRACT(EPOCH FROM (f.actual_arrival - f.scheduled_arrival))/60 BETWEEN 1 AND 15 THEN 'Retard mineur'
            WHEN EXTRACT(EPOCH FROM (f.actual_arrival - f.scheduled_arrival))/60 BETWEEN 16 AND 60 THEN 'Retard modéré'
            WHEN EXTRACT(EPOCH FROM (f.actual_arrival - f.scheduled_arrival))/60 > 60 THEN 'Retard majeur'
        END AS delay_category,
        
        -- Informations aéroport de départ
        f.departure_airport AS departure_airport_code,
        dep_apt.airport_name AS departure_airport_name,
        dep_apt.city_name AS departure_city,
        dep_apt.timezone AS departure_timezone,
        dep_apt.latitude AS departure_latitude,
        dep_apt.longitude AS departure_longitude,
        
        -- Informations aéroport d'arrivée
        f.arrival_airport AS arrival_airport_code,
        arr_apt.airport_name AS arrival_airport_name,
        arr_apt.city_name AS arrival_city,
        arr_apt.timezone AS arrival_timezone,
        arr_apt.latitude AS arrival_latitude,
        arr_apt.longitude AS arrival_longitude,
        
        -- Informations appareil
        f.aircraft_code,
        ac.aircraft_model,
        ac.flight_range_km,
        ac.aircraft_category,
        
        -- Calcul distance approximative (formule haversine simplifiée)
        -- Distance en km entre deux points GPS
        111.045 * DEGREES(ACOS(
            COS(RADIANS(dep_apt.latitude))
            * COS(RADIANS(arr_apt.latitude))
            * COS(RADIANS(dep_apt.longitude) - RADIANS(arr_apt.longitude))
            + SIN(RADIANS(dep_apt.latitude))
            * SIN(RADIANS(arr_apt.latitude))
        )) AS route_distance_km,
        
        -- Métadonnées
        CURRENT_TIMESTAMP AS dbt_updated_at
        
    FROM flights f
    INNER JOIN departure_airports dep_apt
        ON f.departure_airport = dep_apt.airport_code
    INNER JOIN arrival_airports arr_apt
        ON f.arrival_airport = arr_apt.airport_code
    INNER JOIN aircrafts ac
        ON f.aircraft_code = ac.aircraft_code
)

SELECT
    *
FROM enriched_flights
