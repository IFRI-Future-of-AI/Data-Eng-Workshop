
{{
    config(
        materialized = 'table',
        unique_key = 'id',
        schema = 'dbt_demo',
        tags  = ['stg', 'bookings']
    )
}}


WITH stg_tickets AS (
    SELECT
        *
    FROM {{ ref('stg_tickets') }}
),
stg_bookings AS (
    SELECT
        *
    FROM {{ ref('stg_bookings') }}
)
SELECT
    stg_tickets.*,
    stg_bookings.date,
    stg_bookings.amount
FROM stg_tickets
LEFT JOIN stg_bookings
ON stg_bookings.id = stg_tickets.id_book
