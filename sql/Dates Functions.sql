
SELECT

    flight_id,
    scheduled_arrival,
    EXTRACT( YEAR FROM  scheduled_arrival) AS year_arrival ,
    EXTRACT( MONTH FROM  scheduled_arrival) AS month_arrival     ,
    EXTRACT( DAY FROM  scheduled_arrival) AS day_arrival,
    EXTRACT( DOW FROM  scheduled_arrival) AS day_of_week_arrival,
    scheduled_departure,
    DATE_PART('year' , scheduled_departure) AS year_departure,
    DATE_PART('month' , scheduled_departure) AS month_departure,
    DATE_PART('day' , scheduled_departure) AS day_departure,
    DATE_PART('dow' , scheduled_departure) AS dow_departure,
    scheduled_arrival AS arrival_date_trunc,
    DATE_TRUNC( 'year'  , scheduled_arrival) as date_trunc_year,
    DATE_TRUNC( 'month'  , scheduled_arrival) as date_trunc_month,
    DATE_TRUNC( 'day'  , scheduled_arrival) as date_trunc_day,

    scheduled_departure AS departure_add_interval ,
    scheduled_departure + INTERVAL '1 day' AS departure_plus_one_day,
    scheduled_departure + INTERVAL '2 days' AS departure_plus_two_day,
    scheduled_departure - INTERVAL '1 month' AS departure_plus_one_month,
    scheduled_departure + INTERVAL '2 months' AS departure_plus_two_month,
    scheduled_departure + INTERVAL '1 year' AS departure_plus_one_year,
    scheduled_departure - INTERVAL '10 minutes' AS departure_plus_ten_minutes,
    scheduled_departure + INTERVAL '10 hours' AS departure_plus_ten_hours
    scheduled_departure AS departure_add_interval ,
    TO_CHAR( scheduled_departure, 'Day') AS dqy_of_week,
    TO_CHAR( scheduled_departure, 'Month') AS dqy_of_week,
    TO_CHAR( scheduled_departure, 'Day DD Month YYYY') AS dqy_of_week,
    TO_CHAR( scheduled_departure, 'YYYY-MM-DD') AS dqy_of_week,
    TO_CHAR( scheduled_departure, 'YYYY-MM-DD HH:MI:SS') AS dqy_of_week,
    TO_CHAR( scheduled_departure, 'YYYY-MM-DD HH:MI:SS AM') AS dqy_of_week,
    TO_CHAR( scheduled_departure, 'Month DDth , YYYY') AS dqy_of_week,

    TO_DATE('2025-01-01' , 'YYYY-MM-DD'),
    TO_DATE('2025-01-01' , 'YYYY-MM-DD HH:MI:SS'),
    '2025-01-01'::DATE,
    '2025-01-01'::TIMESTAMP,
    TO_TIMESTAMP('2025-01-01' , 'YYYY-MM-DD HH:MI:SS')




FROM flights