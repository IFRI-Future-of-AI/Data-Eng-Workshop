{{
    config(
        materialized = 'table',
        unique_key = 'id',
        schema = 'dbt_demo',
        tags  = ['stg', 'bookings']
    )
}}

WITH stg_bookings AS (
    SELECT
            book_ref AS id,
            book_date AS date,
            total_amount AS amount
    FROM {{ source('demo', 'bookings') }}
)

SELECT
    *
FROM stg_bookings