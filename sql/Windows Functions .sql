


WITH fligths_arrived AS (

    SELECT
        flight_id AS id ,
        flight_no AS number,
        status,
        scheduled_departure::DATE AS scheduled_departure,
        actual_departure,
        EXTRACT( EPOCH FROM (scheduled_departure-actual_departure) )/60 AS delay_departure,
        scheduled_arrival,
        actual_arrival,
        EXTRACT( EPOCH FROM (scheduled_arrival - actual_arrival) )/60 AS delay_arrival
    FROM flights
    WHERE status ='Arrived'
),
ranking_delay_rwn AS (
    SELECT
        id,
        number,
        delay_departure,
       -- delay_arrival,
        scheduled_departure,
        ROW_NUMBER() OVER ( PARTITION BY scheduled_departure::DATE  ORDER BY delay_departure ) AS rwn,
        RANK() OVER ( PARTITION BY scheduled_departure::DATE  ORDER BY delay_departure ) AS rk,
        DENSE_RANK() OVER ( PARTITION BY scheduled_departure::DATE  ORDER BY delay_departure ) AS drnk

    FROM fligths_arrived
),
total_amount_per_day AS (
    SELECT
        book_date::DATE AS book_date,
        SUM( total_amount )  AS amount
    FROM bookings
    GROUP BY  book_date::DATE
    ORDER BY book_date
),
amount_windows AS (
    SELECT
     book_date,
     amount,
     SUM(amount) OVER (
         ORDER BY book_date ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
     ) AS sum_amount,
    ROUND(
        AVG(amount) OVER (
         ORDER BY book_date ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
        ) ,2
    ) AS avg_amount,
    LEAD(amount, 1) OVER( ORDER BY  book_date ) AS lead_date,
    LAG(amount, 1) OVER( ORDER BY  book_date ) AS lead_date,
    LAG(amount, 7) OVER( ORDER BY  book_date ) AS lead_date_7,
    DATE_TRUNC('month', book_date)::DATE AS date_month ,
    FIRST_VALUE(amount) OVER(PARTITION BY DATE_TRUNC('month', book_date)::DATE ),
    LAST_VALUE(amount) OVER(PARTITION BY DATE_TRUNC('month', book_date)::DATE )
    FROM total_amount_per_day
)
SELECT
    *
FROM amount_windows