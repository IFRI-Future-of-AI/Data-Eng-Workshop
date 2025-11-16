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
        dateDiff('second', f.actual_departure, f.actual_arrival)/3600.0 AS actual_flight_duration_hours,
        dateDiff('second', f.scheduled_departure, f.scheduled_arrival)/3600.0 AS scheduled_flight_duration_hours,
        
        -- Calcul des retards
        dateDiff('second', f.scheduled_departure, f.actual_departure)/60.0 AS departure_delay_minutes,
        dateDiff('second', f.scheduled_arrival, f.actual_arrival)/60.0 AS arrival_delay_minutes,
        
        -- Classification du retard
        CASE
            WHEN dateDiff('second', f.scheduled_arrival, f.actual_arrival)/60.0 <= 0 THEN 'À l''heure'
            WHEN dateDiff('second', f.scheduled_arrival, f.actual_arrival)/60.0 BETWEEN 1 AND 15 THEN 'Retard mineur'
            WHEN dateDiff('second', f.scheduled_arrival, f.actual_arrival)/60.0 BETWEEN 16 AND 60 THEN 'Retard modéré'
            WHEN dateDiff('second', f.scheduled_arrival, f.actual_arrival)/60.0 > 60 THEN 'Retard majeur'
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
        
        -- Calcul distance approximative (formule haversine)
        -- Distance en km entre deux points GPS
        2 * 6371 * asin(sqrt(
            pow(sin((arr_apt.latitude - dep_apt.latitude) * pi() / 360), 2) +
            cos(dep_apt.latitude * pi() / 180) * cos(arr_apt.latitude * pi() / 180) *
            pow(sin((arr_apt.longitude - dep_apt.longitude) * pi() / 360), 2)
        )) AS route_distance_km,
        
        -- Métadonnées
        now() AS dbt_updated_at
        
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
