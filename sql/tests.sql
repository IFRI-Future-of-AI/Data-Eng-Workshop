WITH lines AS (
            SELECT 
                d.city AS departure_city,
                d.coordinates AS departure_coords,
                a.city AS arrival_city,
                a.coordinates AS arrival_coords,
                date_trunc('week', f.actual_departure) + interval '6 days' AS week_start_monday,
                DATE_TRUNC('day', (DATE_TRUNC('day', f.actual_departure) + ((7 - EXTRACT(DOW FROM f.actual_departure)::INTEGER ) * INTERVAL '1 day'))) AS week_end
            FROM flights f
            JOIN airports_data d
            ON f.departure_airport = d.airport_code
            JOIN airports_data a
            ON f.arrival_airport = a.airport_code
        )
        SELECT 
            departure_city,
            departure_coords AS departure_coordinates,
            arrival_city,
            arrival_coords AS arrival_coordinates,
            week_end,
            week_start_monday
        FROM lines
        WHERE week_end <> week_start_monday

        