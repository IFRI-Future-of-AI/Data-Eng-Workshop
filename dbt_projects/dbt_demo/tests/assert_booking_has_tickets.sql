-- Test: Ensure every booking has at least one ticket
-- Validates referential integrity

SELECT
    b.booking_ref
FROM {{ ref('stg_bookings') }} b
LEFT JOIN {{ ref('stg_tickets') }} t 
    ON b.id = t.id_book
WHERE t.id IS NULL
