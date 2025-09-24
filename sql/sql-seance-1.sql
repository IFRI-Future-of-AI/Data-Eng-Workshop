SELECT
    flight_id AS id ,
    flight_no AS no,
    departure_airport AS depart_airport,
    arrival_airport AS arrival_airport ,
    COALESCE(actual_departure, '2025-01-01') AS actual_departure
FROM flights
/*
 Entre 0 et 1000 disons Bas
 Entre 1000 et 10000 Prix Moyen
 Entre 10000 et 100000 Prix Élevé
 Si > 100000 N/A
 */

/*
SELECT
    book_ref AS id,
    book_date AS date,
    total_amount AS montant,
    CASE
        WHEN total_amount < 1000 THEN 'Bas'
        WHEN total_amount >=1000 AND total_amount < 10000 THEN 'Moyen'
        WHEN total_amount >=10000 AND total_amount < 100000 THEN 'Élevé'
        ELSE 'N/A'
    END AS categorie
FROM bookings
ORDER BY categorie DESC
/*
/*
SELECT
    total_amount::INT
FROM bookings
*/
/*
WITH nombre AS (
    SELECT
    generate_series(
        1,
        10,
        1
    ) AS nombre
)
SELECT
    nombre,
    seat_no
FROM nombre
CROSS JOIN seats
*/


/*
SELECT
    tk.*,
    bk.*
FROM tickets tk
FULL JOIN   bookings bk
ON tk.book_ref = bk.book_ref
--WHERE bk.book_ref IS NULL
*/

/*SELECT
    fare_conditions,
    COUNT(seat_no) AS nombre_sieges
FROM seats
GROUP BY fare_conditions
ORDER BY nombre_sieges DESC
*/
/*
SELECT
    *
FROM seats
WHERE  seat_no NOT LIKE '2%'

*/
/*
 SELECT
    book_ref AS id,
    book_date AS date,
    total_amount AS montant
FROM bookings
WHERE total_amount BETWEEN  10000 AND 20000
        AND book_ref LIKE '%A%'
        AND book_ref IN (
                '65A4C7', 'FCF4AF', '685D3A'
        )
ORDER BY montant DESC
 */