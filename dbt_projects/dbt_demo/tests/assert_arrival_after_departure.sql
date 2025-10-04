-- Test: Ensure arrival time is after departure time
-- Validates temporal logic for completed flights

SELECT
    flight_id,
    actual_departure,
    actual_arrival
FROM {{ ref('flights_enriched') }}
WHERE actual_departure IS NOT NULL
    AND actual_arrival IS NOT NULL
    AND actual_arrival <= actual_departure
