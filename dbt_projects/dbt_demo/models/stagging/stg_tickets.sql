
{{
    config(
        materialized = 'table',
        unique_key = 'id',
        schema = 'dbt_demo',
        tags  = ['stg', 'tickets']
    )
}}

WITH stg_tickets AS (

    SELECT
        ticket_no AS id,
        book_ref AS id_book,
        passenger_id,
        passenger_name,
        contact_data
    FROM  {{ source('demo', 'tickets') }}
)
SELECT
    *
FROM stg_tickets