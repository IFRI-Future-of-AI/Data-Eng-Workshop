-- Dimension table: Dates
-- Calendar dimension for time-based analysis

{{
    config(
        materialized = 'table',
        schema = 'dbt_demo',
        tags = ['gold', 'dimension', 'dates']
    )
}}

WITH date_range AS (
    -- Get the range of dates from bookings and flights
    SELECT 
        MIN(DATE(book_date)) AS min_date,
        MAX(DATE(book_date)) AS max_date
    FROM {{ source('demo', 'bookings') }}
    
    UNION ALL
    
    SELECT
        MIN(DATE(scheduled_departure)) AS min_date,
        MAX(DATE(scheduled_arrival)) AS max_date
    FROM {{ source('demo', 'flights') }}
),

date_bounds AS (
    SELECT
        MIN(min_date) AS start_date,
        MAX(max_date) AS end_date
    FROM date_range
),

date_series AS (
    SELECT 
        generate_series(
            (SELECT start_date FROM date_bounds),
            (SELECT end_date FROM date_bounds),
            '1 day'::interval
        )::date AS calendar_date
)

SELECT
    -- Surrogate key
    {{ generate_surrogate_key(['calendar_date']) }} AS date_key,
    
    -- Natural key
    calendar_date,
    
    -- Date components
    EXTRACT(YEAR FROM calendar_date) AS year,
    EXTRACT(MONTH FROM calendar_date) AS month,
    EXTRACT(DAY FROM calendar_date) AS day,
    EXTRACT(QUARTER FROM calendar_date) AS quarter,
    EXTRACT(WEEK FROM calendar_date) AS week_of_year,
    EXTRACT(DOW FROM calendar_date) AS day_of_week,
    EXTRACT(DOY FROM calendar_date) AS day_of_year,
    
    -- Text representations
    TO_CHAR(calendar_date, 'Month') AS month_name,
    TO_CHAR(calendar_date, 'Mon') AS month_short,
    TO_CHAR(calendar_date, 'Day') AS day_name,
    TO_CHAR(calendar_date, 'Dy') AS day_short,
    
    -- Date classifications
    CASE EXTRACT(DOW FROM calendar_date)
        WHEN 0 THEN TRUE
        WHEN 6 THEN TRUE
        ELSE FALSE
    END AS is_weekend,
    
    CASE EXTRACT(DOW FROM calendar_date)
        WHEN 0 THEN FALSE
        WHEN 6 THEN FALSE
        ELSE TRUE
    END AS is_weekday,
    
    -- Fiscal attributes (assuming fiscal year = calendar year)
    EXTRACT(YEAR FROM calendar_date) AS fiscal_year,
    EXTRACT(QUARTER FROM calendar_date) AS fiscal_quarter,
    
    -- Formatted date strings
    TO_CHAR(calendar_date, 'YYYY-MM-DD') AS date_iso,
    TO_CHAR(calendar_date, 'DD/MM/YYYY') AS date_eu,
    TO_CHAR(calendar_date, 'MM/DD/YYYY') AS date_us

FROM date_series
