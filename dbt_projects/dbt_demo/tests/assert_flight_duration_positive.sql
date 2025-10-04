-- Test: Ensure flight durations are positive and reasonable
-- Validates that actual flight durations are between 10 minutes and 24 hours

SELECT
    flight_id,
    actual_duration_minutes
FROM {{ ref('flights_enriched') }}
WHERE actual_duration_minutes IS NOT NULL
    AND (actual_duration_minutes < 10 OR actual_duration_minutes > 1440)
