-- Test: Ensure each seat is assigned only once per flight
-- Validates no duplicate seat assignments on the same flight

SELECT
    flight_id,
    seat_no,
    COUNT(*) AS assignment_count
FROM {{ ref('stg_boarding_passes') }}
GROUP BY flight_id, seat_no
HAVING COUNT(*) > 1
