
-- ====================================================================
-- GUIDE COMPLET DES FONCTIONS WINDOW EN SQL
-- Base de données : Airlines Demo
-- ====================================================================
-- Les fonctions window permettent d'effectuer des calculs sur un ensemble 
-- de lignes liées à la ligne courante, sans regrouper les données comme GROUP BY.
-- Syntaxe générale : function() OVER (PARTITION BY ... ORDER BY ... ROWS/RANGE ...)

-- ====================================================================
-- 1. FONCTIONS DE CLASSEMENT (RANKING FUNCTIONS)
-- ====================================================================

-- 1.1 ROW_NUMBER() - Attribue un numéro de ligne unique
-- Utilité : Numérotation séquentielle, pagination, élimination des doublons
-- ====================================================================

-- Exemple : Numéroter les vols par ordre de départ pour chaque aéroport
SELECT 
    flight_no,
    departure_airport,
    scheduled_departure,
    -- Attribue un numéro séquentiel à chaque vol par aéroport de départ
    ROW_NUMBER() OVER (
        PARTITION BY departure_airport 
        ORDER BY scheduled_departure
    ) AS vol_numero
FROM flights
ORDER BY departure_airport, scheduled_departure;

-- 1.2 RANK() - Attribue un rang avec des ex-aequos (des trous dans la numérotation)
-- Utilité : Classement avec égalités, permet les ex-aequos
-- ====================================================================

-- Exemple : Classement des réservations par montant total avec égalités possibles
SELECT 
    book_ref,
    total_amount,
    -- Si deux réservations ont le même montant, elles auront le même rang
    -- Le rang suivant sautera les positions occupées par les ex-aequos
    RANK() OVER (ORDER BY total_amount DESC) AS rang_montant
FROM bookings
ORDER BY total_amount DESC;

-- 1.3 DENSE_RANK() - Comme RANK() mais sans trous dans la numérotation
-- Utilité : Classement dense, pas de saut de rang après les ex-aequos
-- ====================================================================

-- Exemple : Classement dense des vols par retard de départ
SELECT 
    flight_no,
    departure_airport,
    scheduled_departure,
    actual_departure,
    EXTRACT(EPOCH FROM (actual_departure - scheduled_departure))/60 AS retard_minutes,
    -- Classement avec ex-aequos mais sans saut de rang
    DENSE_RANK() OVER (
        PARTITION BY departure_airport 
        ORDER BY EXTRACT(EPOCH FROM (actual_departure - scheduled_departure))/60 DESC
    ) AS rang_retard_dense
FROM flights
WHERE actual_departure IS NOT NULL
ORDER BY departure_airport, retard_minutes DESC;

-- ====================================================================
-- 2. FONCTIONS DE DÉCALAGE (OFFSET FUNCTIONS)  
-- ====================================================================

-- 2.1 LAG() - Accède à la valeur de la ligne précédente
-- Utilité : Comparaison avec les valeurs précédentes, calcul de différences
-- ====================================================================

-- Exemple : Comparer le montant de chaque réservation avec la précédente
SELECT 
    book_ref,
    book_date,
    total_amount,
    -- Récupère le montant de la réservation précédente (chronologiquement)
    LAG(total_amount, 1) OVER (ORDER BY book_date) AS montant_precedent,
    -- Calcule la différence avec la réservation précédente
    total_amount - LAG(total_amount, 1) OVER (ORDER BY book_date) AS difference_precedent
FROM bookings
ORDER BY book_date;

-- 2.2 LEAD() - Accède à la valeur de la ligne suivante  
-- Utilité : Comparaison avec les valeurs futures, anticipation
-- ====================================================================

-- Exemple : Comparer les horaires de départ entre vols consécutifs du même avion
SELECT 
    flight_no,
    aircraft_code,
    scheduled_departure,
    -- Récupère l'heure de départ du vol suivant du même avion
    LEAD(scheduled_departure, 1) OVER (
        PARTITION BY aircraft_code 
        ORDER BY scheduled_departure
    ) AS prochain_depart,
    -- Calcule le temps entre deux vols consécutifs du même avion
    LEAD(scheduled_departure, 1) OVER (
        PARTITION BY aircraft_code 
        ORDER BY scheduled_departure
    ) - scheduled_departure AS temps_entre_vols
FROM flights
ORDER BY aircraft_code, scheduled_departure;

-- ====================================================================
-- 3. FONCTIONS DE VALEUR (VALUE FUNCTIONS)
-- ====================================================================

-- 3.1 FIRST_VALUE() - Récupère la première valeur de la fenêtre
-- Utilité : Comparaison avec le premier élément d'un groupe
-- ====================================================================

-- Exemple : Comparer chaque prix de billet avec le moins cher de la même classe
SELECT 
    t.ticket_no,
    t.passenger_name,
    tf.fare_conditions,
    tf.amount,
    -- Récupère le prix le plus bas pour cette classe de service
    FIRST_VALUE(tf.amount) OVER (
        PARTITION BY tf.fare_conditions 
        ORDER BY tf.amount ASC 
        ROWS UNBOUNDED PRECEDING
    ) AS prix_min_classe,
    -- Calcule la différence avec le prix minimum de la classe
    tf.amount - FIRST_VALUE(tf.amount) OVER (
        PARTITION BY tf.fare_conditions 
        ORDER BY tf.amount ASC 
        ROWS UNBOUNDED PRECEDING
    ) AS difference_avec_min
FROM tickets t
JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
ORDER BY tf.fare_conditions, tf.amount;

-- 3.2 LAST_VALUE() - Récupère la dernière valeur de la fenêtre
-- Utilité : Comparaison avec le dernier élément, valeurs cumulatives
-- ====================================================================

-- Exemple : Évolution mensuelle des réservations vs pic mensuel
SELECT 
    DATE_TRUNC('month', book_date) AS mois,
    COUNT(*) AS reservations_mois,
    -- Récupère le nombre max de réservations dans la période analysée
    LAST_VALUE(COUNT(*)) OVER (
        ORDER BY DATE_TRUNC('month', book_date) 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS pic_reservations
FROM bookings
GROUP BY DATE_TRUNC('month', book_date)
ORDER BY mois;

-- 3.3 NTH_VALUE() - Récupère la Nième valeur de la fenêtre
-- Utilité : Accès à une position spécifique dans un classement
-- ====================================================================

-- Exemple : Comparer chaque vol avec le 3ème vol le plus long de sa route
SELECT 
    flight_no,
    departure_airport,
    arrival_airport,
    scheduled_arrival - scheduled_departure AS duree_vol,
    -- Récupère la durée du 3ème vol le plus long sur cette route
    NTH_VALUE(scheduled_arrival - scheduled_departure, 3) OVER (
        PARTITION BY departure_airport, arrival_airport
        ORDER BY (scheduled_arrival - scheduled_departure) DESC
        ROWS UNBOUNDED PRECEDING
    ) AS duree_3eme_plus_long
FROM flights
ORDER BY departure_airport, arrival_airport, duree_vol DESC;

-- ====================================================================
-- 4. FONCTIONS D'AGRÉGATION WINDOW 
-- ====================================================================

-- 4.1 SUM() OVER - Somme cumulative ou sur une fenêtre glissante
-- Utilité : Totaux cumulés, moyennes mobiles, analyses de tendances
-- ====================================================================

-- Exemple : Évolution cumulative du chiffre d'affaires quotidien
SELECT 
    book_date::DATE AS date_reservation,
    COUNT(*) AS nb_reservations,
    SUM(total_amount) AS ca_quotidien,
    -- Cumul du CA depuis le début
    SUM(SUM(total_amount)) OVER (
        ORDER BY book_date::DATE 
        ROWS UNBOUNDED PRECEDING
    ) AS ca_cumule,
    -- Moyenne mobile sur 7 jours
    ROUND(
        AVG(SUM(total_amount)) OVER (
            ORDER BY book_date::DATE 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moyenne_mobile_7j
FROM bookings
GROUP BY book_date::DATE
ORDER BY book_date::DATE;

-- 4.2 AVG() OVER - Moyenne sur une fenêtre
-- Utilité : Moyennes mobiles, comparaison avec la moyenne d'un groupe
-- ====================================================================

-- Exemple : Analyse des prix des billets vs moyenne par route
SELECT 
    f.flight_no,
    f.departure_airport,
    f.arrival_airport,
    tf.fare_conditions,
    tf.amount AS prix_billet,
    -- Moyenne des prix sur cette route pour cette classe
    ROUND(
        AVG(tf.amount) OVER (
            PARTITION BY f.departure_airport, f.arrival_airport, tf.fare_conditions
        ), 2
    ) AS prix_moyen_route_classe,
    -- Écart du prix par rapport à la moyenne de la route/classe
    ROUND(
        tf.amount - AVG(tf.amount) OVER (
            PARTITION BY f.departure_airport, f.arrival_airport, tf.fare_conditions
        ), 2
    ) AS ecart_moyenne
FROM flights f
JOIN ticket_flights tf ON f.flight_id = tf.flight_id
ORDER BY f.departure_airport, f.arrival_airport, tf.fare_conditions;

-- 4.3 COUNT() OVER - Comptage sur une fenêtre
-- Utilité : Compteurs cumulés, nombres mobiles
-- ====================================================================

-- Exemple : Évolution du nombre de vols cumulés par compagnie aérienne
WITH vols_par_jour AS (
    SELECT 
        LEFT(flight_no, 2) AS compagnie,  -- Extraction du code compagnie
        scheduled_departure::DATE AS date_vol,
        COUNT(*) AS nb_vols_jour
    FROM flights
    GROUP BY LEFT(flight_no, 2), scheduled_departure::DATE
)
SELECT 
    compagnie,
    date_vol,
    nb_vols_jour,
    -- Nombre cumulé de vols depuis le début
    SUM(nb_vols_jour) OVER (
        PARTITION BY compagnie 
        ORDER BY date_vol 
        ROWS UNBOUNDED PRECEDING
    ) AS vols_cumules
FROM vols_par_jour
ORDER BY compagnie, date_vol;

-- ====================================================================
-- 5. FONCTIONS STATISTIQUES ET DE DISTRIBUTION
-- ====================================================================

-- 5.1 PERCENT_RANK() - Rang en pourcentage (0 à 1)
-- Utilité : Percentiles, répartition statistique
-- ====================================================================

-- Exemple : Positionnement des réservations par rapport au montant
SELECT 
    book_ref,
    total_amount,
    -- Position en pourcentage (0 = minimum, 1 = maximum)
    ROUND(PERCENT_RANK() OVER (ORDER BY total_amount), 3) AS percentile_rang,
    -- Interprétation en pourcentage
    ROUND(PERCENT_RANK() OVER (ORDER BY total_amount) * 100, 1) AS pourcentage
FROM bookings
ORDER BY total_amount DESC;

-- 5.2 CUME_DIST() - Distribution cumulative (pourcentage de valeurs <= valeur courante)
-- Utilité : Analyse de distribution, quartiles
-- ====================================================================

-- Exemple : Distribution cumulative des prix des billets
SELECT 
    tf.fare_conditions,
    tf.amount,
    -- Pourcentage de billets de cette classe ayant un prix <= prix courant
    ROUND(CUME_DIST() OVER (
        PARTITION BY tf.fare_conditions 
        ORDER BY tf.amount
    ), 3) AS distribution_cumulative,
    -- Quartile d'appartenance
    CASE 
        WHEN CUME_DIST() OVER (PARTITION BY tf.fare_conditions ORDER BY tf.amount) <= 0.25 THEN 'Q1 (25% moins chers)'
        WHEN CUME_DIST() OVER (PARTITION BY tf.fare_conditions ORDER BY tf.amount) <= 0.50 THEN 'Q2 (médiane)'
        WHEN CUME_DIST() OVER (PARTITION BY tf.fare_conditions ORDER BY tf.amount) <= 0.75 THEN 'Q3'
        ELSE 'Q4 (25% plus chers)'
    END AS quartile
FROM ticket_flights tf
ORDER BY tf.fare_conditions, tf.amount;

-- 5.3 NTILE() - Divise les données en N groupes de taille égale
-- Utilité : Segmentation, classification en buckets
-- ====================================================================

-- Exemple : Segmentation des passagers par fréquence de voyage
WITH passager_stats AS (
    SELECT 
        passenger_name,
        COUNT(*) AS nb_voyages,
        SUM(tf.amount) AS montant_total_depense
    FROM tickets t
    JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
    GROUP BY passenger_name
)
SELECT 
    passenger_name,
    nb_voyages,
    montant_total_depense,
    -- Segmentation en 4 groupes selon la fréquence de voyage
    NTILE(4) OVER (ORDER BY nb_voyages) AS segment_frequence,
    -- Segmentation en 5 groupes selon les dépenses
    NTILE(5) OVER (ORDER BY montant_total_depense) AS segment_valeur,
    -- Interprétation du segment fréquence
    CASE NTILE(4) OVER (ORDER BY nb_voyages)
        WHEN 1 THEN 'Voyageurs occasionnels'
        WHEN 2 THEN 'Voyageurs réguliers'
        WHEN 3 THEN 'Voyageurs fréquents'
        WHEN 4 THEN 'Grands voyageurs'
    END AS profil_voyageur
FROM passager_stats
ORDER BY nb_voyages DESC;

-- ====================================================================
-- 6. EXEMPLES AVANCÉS - COMBINAISONS DE FONCTIONS WINDOW
-- ====================================================================

-- 6.1 Analyse complète des performances de vol par route
-- ====================================================================
SELECT 
    flight_no,
    departure_airport,
    arrival_airport,
    scheduled_departure,
    actual_departure,
    EXTRACT(EPOCH FROM (actual_departure - scheduled_departure))/60 AS retard_minutes,
    
    -- Classements multiples
    ROW_NUMBER() OVER (PARTITION BY departure_airport, arrival_airport ORDER BY scheduled_departure) AS numero_vol_route,
    RANK() OVER (PARTITION BY departure_airport, arrival_airport ORDER BY EXTRACT(EPOCH FROM (actual_departure - scheduled_departure))/60) AS rang_ponctualite,
    
    -- Comparaisons avec vols précédents/suivants
    LAG(EXTRACT(EPOCH FROM (actual_departure - scheduled_departure))/60, 1) OVER (
        PARTITION BY departure_airport, arrival_airport 
        ORDER BY scheduled_departure
    ) AS retard_vol_precedent,
    
    -- Statistiques de la route
    ROUND(AVG(EXTRACT(EPOCH FROM (actual_departure - scheduled_departure))/60) OVER (
        PARTITION BY departure_airport, arrival_airport
    ), 2) AS retard_moyen_route,
    
    -- Position percentile sur la route
    ROUND(PERCENT_RANK() OVER (
        PARTITION BY departure_airport, arrival_airport 
        ORDER BY EXTRACT(EPOCH FROM (actual_departure - scheduled_departure))/60
    ) * 100, 1) AS percentile_ponctualite

FROM flights
WHERE actual_departure IS NOT NULL
ORDER BY departure_airport, arrival_airport, scheduled_departure;

-- 6.2 Analyse temporelle des réservations avec tendances
-- ====================================================================
WITH reservations_quotidiennes AS (
    SELECT 
        book_date::DATE AS date_reservation,
        COUNT(*) AS nb_reservations,
        SUM(total_amount) AS ca_quotidien,
        AVG(total_amount) AS panier_moyen
    FROM bookings
    GROUP BY book_date::DATE
)
SELECT 
    date_reservation,
    nb_reservations,
    ca_quotidien,
    panier_moyen,
    
    -- Tendances et évolutions
    LAG(nb_reservations, 1) OVER (ORDER BY date_reservation) AS reservations_veille,
    nb_reservations - LAG(nb_reservations, 1) OVER (ORDER BY date_reservation) AS evolution_quotidienne,
    
    -- Moyennes mobiles
    ROUND(AVG(nb_reservations) OVER (
        ORDER BY date_reservation 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 1) AS moyenne_mobile_7j,
    
    -- Cumuls
    SUM(nb_reservations) OVER (
        ORDER BY date_reservation 
        ROWS UNBOUNDED PRECEDING
    ) AS reservations_cumulees,
    
    -- Comparaison avec extremes
    FIRST_VALUE(nb_reservations) OVER (
        ORDER BY date_reservation 
        ROWS UNBOUNDED PRECEDING
    ) AS premiere_journee,
    MAX(nb_reservations) OVER (
        ORDER BY date_reservation 
        ROWS UNBOUNDED PRECEDING
    ) AS record_reservations_atteint

FROM reservations_quotidiennes
ORDER BY date_reservation;

-- ====================================================================
-- NOTES IMPORTANTES SUR LES FONCTIONS WINDOW :
-- ====================================================================
/*
1. PARTITION BY : Divise les données en groupes (optionnel)
   - Sans PARTITION BY : calcul sur toutes les lignes
   - Avec PARTITION BY : calcul séparé pour chaque groupe

2. ORDER BY : Définit l'ordre pour le calcul (requis pour certaines fonctions)
   - Obligatoire pour : ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD
   - Optionnel pour : les fonctions d'agrégation

3. FRAME (ROWS/RANGE) : Définit la fenêtre de calcul
   - ROWS : basé sur le nombre de lignes physiques
   - RANGE : basé sur les valeurs logiques
   - UNBOUNDED PRECEDING/FOLLOWING : depuis le début/jusqu'à la fin
   - CURRENT ROW : ligne courante
   - n PRECEDING/FOLLOWING : n lignes avant/après

4. Performance : 
   - Les fonctions window sont généralement plus efficaces que les sous-requêtes
   - Utilisent un seul passage sur les données
   - Peuvent bénéficier d'index sur les colonnes PARTITION BY et ORDER BY

5. Cas d'usage typiques :
   - Classements et top N
   - Calculs de pourcentages sur le total
   - Comparaisons avec valeurs précédentes/suivantes  
   - Moyennes mobiles et tendances
   - Analyses de cohortes et de rétention
*/