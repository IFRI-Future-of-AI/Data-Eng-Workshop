
/*
SELECT
   flight_id AS id ,
   flight_no AS number,
   status
FROM flights
WHERE  status IN (
    SELECT status
    FROM flights
    WHERE status = 'On Time'
    )
 */

 WITH fligths_on_time AS (
    SELECT
        flight_id AS id ,
        flight_no AS number,
        status
    FROM flights
    WHERE status = 'On Time'
 )
 SELECT
     *
 FROM fligths_on_time