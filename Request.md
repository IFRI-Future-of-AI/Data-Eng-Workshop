# Requêtes SQL
### 1. **Afficher tous les vols programmés**
```sql
SELECT 
    * 
FROM flights;
```

***

### 2. **Lister les numéros de ticket et nom des passagers (table `tickets`)**
```sql
SELECT 
    ticket_no, 
    passenger_name
FROM tickets;
```

***

### 3. **Trouver les vols au départ d’un aéroport donné (ex : LED)**
```sql
SELECT 
    flight_no, 
    scheduled_departure
FROM flights
WHERE departure_airport = 'LED';
```

***

### 4. **Donner les 5 derniers vols enregistrés (plus récents)**
```sql
SELECT 
    flight_no, 
    scheduled_departure
FROM flights
ORDER BY scheduled_departure DESC
LIMIT 5;
```

***

### 5. **Nombre total de tickets émis**
```sql
SELECT 
    COUNT(*) AS total_tickets
FROM tickets;
```

***

### 6. **Lister les vols avec le nom de l’aéroport d’arrivée (INNER JOIN flights + airports)**
```sql
SELECT 
    f.flight_no, 
    a.airport_name AS arrival_airport
FROM flights f
INNER JOIN airports a 
ON f.arrival_airport = a.airport_code;
```

***

### 7. **Afficher toutes les combinaisons possibles: vol et appareil impliqué (CROSS JOIN)**
```sql
SELECT 
    f.flight_no, 
    ac.model
FROM flights f
CROSS JOIN aircrafts ac;
```

***

### 8. **Afficher le vol, la date de départ, et la convertir en texte**
```sql
SELECT 
    flight_no, 
    scheduled_departure::text AS depart_text
FROM flights;
```

***

### 9. **Catégoriser le statut du vol (CASE WHEN)**
```sql
SELECT 
    flight_no, 
    status,
       CASE
           WHEN status = 'On Time' THEN 'Ponctuel'
           WHEN status = 'Delayed' THEN 'Retardé'
           ELSE 'Autre'
       END AS statut_catégorisé
FROM flights;
```

***

### 10. **Afficher nom de passager et contact si renseigné, sinon un message (COALESCE)**
```sql
SELECT
    passenger_name,
    COALESCE(contact_data->>'phone', 'Non renseigné') AS phone
FROM tickets;


```