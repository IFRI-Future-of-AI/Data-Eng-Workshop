-- Test: Ensure all booking amounts are positive
-- Validates that there are no negative or zero booking amounts

SELECT
    booking_ref,
    booking_amount_currency
FROM {{ ref('fct_bookings') }}
WHERE booking_amount_currency <= 0
