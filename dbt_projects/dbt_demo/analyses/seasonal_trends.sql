-- Analyse: Tendances saisonnières des réservations
-- Identifie les patterns temporels pour la planification de capacité

WITH monthly_bookings AS (
    SELECT
        booking_year,
        booking_month,
        booking_year_month,
        TO_DATE(booking_year_month || '-01', 'YYYY-MM-DD') AS month_date,
        COUNT(*) AS total_bookings,
        SUM(total_booking_amount) AS total_revenue,
        SUM(total_passengers) AS total_passengers,
        AVG(total_booking_amount) AS avg_booking_value,
        AVG(revenue_per_passenger) AS avg_revenue_per_passenger
    FROM {{ ref('fct_bookings') }}
    GROUP BY booking_year, booking_month, booking_year_month
),

monthly_metrics AS (
    SELECT
        *,
        -- Calcul de la croissance mensuelle
        LAG(total_revenue) OVER (ORDER BY month_date) AS prev_month_revenue,
        total_revenue - LAG(total_revenue) OVER (ORDER BY month_date) AS revenue_change,
        ROUND(
            100.0 * (total_revenue - LAG(total_revenue) OVER (ORDER BY month_date)) 
            / NULLIF(LAG(total_revenue) OVER (ORDER BY month_date), 0), 
            2
        ) AS revenue_growth_pct,
        
        -- Moyenne mobile sur 3 mois
        AVG(total_revenue) OVER (
            ORDER BY month_date 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS revenue_3month_avg,
        
        -- Indice de saisonnalité
        ROUND(
            100.0 * total_revenue / AVG(total_revenue) OVER (), 
            2
        ) AS seasonality_index
    FROM monthly_bookings
)

SELECT
    booking_year,
    booking_month,
    CASE booking_month
        WHEN 1 THEN 'Janvier'
        WHEN 2 THEN 'Février'
        WHEN 3 THEN 'Mars'
        WHEN 4 THEN 'Avril'
        WHEN 5 THEN 'Mai'
        WHEN 6 THEN 'Juin'
        WHEN 7 THEN 'Juillet'
        WHEN 8 THEN 'Août'
        WHEN 9 THEN 'Septembre'
        WHEN 10 THEN 'Octobre'
        WHEN 11 THEN 'Novembre'
        WHEN 12 THEN 'Décembre'
    END AS month_name,
    total_bookings,
    total_revenue,
    total_passengers,
    avg_booking_value,
    revenue_growth_pct,
    revenue_3month_avg,
    seasonality_index,
    CASE
        WHEN seasonality_index >= 120 THEN 'Haute saison'
        WHEN seasonality_index >= 90 THEN 'Saison normale'
        ELSE 'Basse saison'
    END AS season_category
FROM monthly_metrics
ORDER BY booking_year, booking_month
