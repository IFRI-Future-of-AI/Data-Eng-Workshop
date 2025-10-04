# 🌱 Seeds - Données de Référence

## 📋 Vue d'ensemble

Les seeds sont des fichiers CSV contenant des données de référence qui complètent les données transactionnelles de la base Airlines. Ils sont chargés dans la base de données par dbt et peuvent être référencés dans les modèles.

---

## 📁 Seeds Disponibles

### 1. flight_status_codes.csv

**Description**: Référentiel des codes et catégories de statuts de vol.

**Colonnes**:
- `status_code`: Code court du statut (SCH, OT, DEL, etc.)
- `status_name`: Nom complet du statut
- `status_category`: Catégorie du statut (Programmé, En cours, Terminé, Annulé)
- `description`: Description détaillée

**Utilisation**:
```sql
SELECT
    f.flight_no,
    f.status,
    sc.status_category
FROM {{ ref('fct_flights') }} f
LEFT JOIN {{ ref('flight_status_codes') }} sc
    ON f.status = sc.status_name
```

---

### 2. fare_class_descriptions.csv

**Description**: Descriptions détaillées des classes tarifaires avec services inclus.

**Colonnes**:
- `fare_class`: Code de classe (Economy, Comfort, Business)
- `class_name`: Nom complet de la classe
- `amenities`: Services et équipements inclus
- `baggage_allowance`: Franchise bagage
- `priority_boarding`: Embarquement prioritaire (Oui/Non)

**Utilisation**:
```sql
SELECT
    t.passenger_name,
    tf.cabin_class,
    fc.class_name,
    fc.amenities
FROM {{ ref('int_passenger_journeys') }} t
LEFT JOIN {{ ref('fare_class_descriptions') }} fc
    ON t.cabin_class = fc.fare_class
```

---

### 3. airport_regions.csv

**Description**: Classification géographique des aéroports par région et type de hub.

**Colonnes**:
- `airport_code`: Code IATA de l'aéroport
- `region`: Région géographique
- `country`: Pays
- `continent`: Continent
- `hub_type`: Type de hub (Hub Principal, Hub Régional, Régional)

**Utilisation**:
```sql
SELECT
    ar.region,
    ar.hub_type,
    COUNT(DISTINCT f.flight_id) AS total_flights
FROM {{ ref('fct_flights') }} f
LEFT JOIN {{ ref('airport_regions') }} ar
    ON f.departure_airport_code = ar.airport_code
GROUP BY ar.region, ar.hub_type
```

---

### 4. aircraft_manufacturers.csv

**Description**: Informations sur les constructeurs et modèles d'appareils.

**Colonnes**:
- `aircraft_code`: Code de l'appareil
- `manufacturer`: Constructeur (Boeing, Airbus, etc.)
- `first_flight_year`: Année du premier vol
- `production_status`: Statut de production
- `typical_capacity`: Capacité typique en passagers

**Utilisation**:
```sql
SELECT
    am.manufacturer,
    am.production_status,
    COUNT(DISTINCT f.flight_id) AS total_flights,
    AVG(f.route_distance_km) AS avg_distance
FROM {{ ref('fct_flights') }} f
INNER JOIN {{ ref('dim_aircrafts') }} a
    ON f.aircraft_code = a.aircraft_code
LEFT JOIN {{ ref('aircraft_manufacturers') }} am
    ON a.aircraft_code = am.aircraft_code
GROUP BY am.manufacturer, am.production_status
```

---

## 🚀 Commandes

### Charger tous les seeds
```bash
dbt seed
```

### Charger un seed spécifique
```bash
dbt seed --select flight_status_codes
```

### Recharger en forçant la mise à jour
```bash
dbt seed --full-refresh
```

---

## ✨ Bonnes Pratiques

1. **Format CSV standard**: Utiliser UTF-8, virgule comme séparateur
2. **En-têtes clairs**: Noms de colonnes explicites en snake_case
3. **Pas de données sensibles**: Ne jamais mettre de données personnelles
4. **Données stables**: Réserver aux données qui changent rarement
5. **Documentation**: Toujours documenter les seeds dans ce README

---

## 🔄 Maintenance

- **Fréquence de mise à jour**: Trimestrielle ou selon besoin métier
- **Validation**: Vérifier la cohérence avec les données transactionnelles
- **Versioning**: Documenter les changements dans le contrôle de version

---

## 📊 Exemple d'Analyse Combinée

```sql
-- Analyse des vols par constructeur et région
WITH flight_analysis AS (
    SELECT
        ar.region,
        am.manufacturer,
        COUNT(DISTINCT f.flight_id) AS total_flights,
        AVG(f.route_distance_km) AS avg_distance,
        AVG(f.arrival_delay_minutes) AS avg_delay
    FROM {{ ref('fct_flights') }} f
    INNER JOIN {{ ref('dim_aircrafts') }} a
        ON f.aircraft_code = a.aircraft_code
    LEFT JOIN {{ ref('aircraft_manufacturers') }} am
        ON a.aircraft_code = am.aircraft_code
    LEFT JOIN {{ ref('airport_regions') }} ar
        ON f.departure_airport_code = ar.airport_code
    GROUP BY ar.region, am.manufacturer
)

SELECT *
FROM flight_analysis
ORDER BY total_flights DESC
```

---

**Note**: Ces seeds sont des exemples pour démonstration. Adaptez-les selon vos besoins spécifiques.
