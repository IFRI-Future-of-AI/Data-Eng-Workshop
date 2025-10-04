# 📊 Projet dbt Airlines - Vue d'ensemble

## 🎯 Objectif du projet

Ce projet dbt transforme les données brutes d'une compagnie aérienne en un data warehouse analytique structuré selon l'architecture médaillon (Bronze, Silver, Gold).

## 🏗️ Architecture du projet

### Structure en couches (Medallion Architecture)

```
┌─────────────────────────────────────────────────────────────┐
│                      SOURCE LAYER                           │
│  Base de données PostgreSQL "demo.bookings"                 │
│  8 tables: bookings, tickets, flights, airports, etc.       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    BRONZE LAYER (Staging)                    │
│  Views - Extraction et nettoyage des données sources        │
│  • stg_bookings      • stg_tickets      • stg_flights       │
│  • stg_airports      • stg_aircrafts    • stg_seats         │
│  • stg_ticket_flights • stg_boarding_passes                 │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    SILVER LAYER (Intermediate)               │
│  Tables - Jointures et métriques métier                     │
│  • flights_enriched        • bookings_metrics               │
│  • passenger_journey       • aircraft_utilization           │
│  • airport_traffic                                          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                     GOLD LAYER (Analytics)                   │
│  Tables - Modèles dimensionnels pour BI                     │
│  Facts:              Dimensions:                            │
│  • fct_bookings      • dim_airports                         │
│  • fct_flights       • dim_aircrafts                        │
│                      • dim_passengers                       │
│                      • dim_dates                            │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Structure des dossiers

```
dbt_demo/
├── models/
│   ├── schema.yml              # Documentation des sources
│   ├── stagging/               # Layer Bronze (Views)
│   │   ├── _stagging.yml       # Documentation staging
│   │   ├── stg_bookings.sql
│   │   ├── stg_tickets.sql
│   │   ├── stg_fligths.sql
│   │   ├── stg_airports.sql
│   │   ├── stg_aircrafts.sql
│   │   ├── stg_seats.sql
│   │   ├── stg_ticket_flights.sql
│   │   └── stg_boarding_passes.sql
│   │
│   ├── silvers/                # Layer Silver (Tables)
│   │   ├── _silvers.yml        # Documentation silver
│   │   ├── flights_enriched.sql
│   │   ├── bookings_metrics.sql
│   │   ├── passenger_journey.sql
│   │   ├── aircraft_utilization.sql
│   │   ├── airport_traffic.sql
│   │   └── tickets_with_bookings.sql
│   │
│   └── golds/                  # Layer Gold (Tables)
│       ├── _golds.yml          # Documentation gold
│       ├── fct_bookings.sql
│       ├── fct_flights.sql
│       ├── dim_airports.sql
│       ├── dim_aircrafts.sql
│       ├── dim_passengers.sql
│       └── dim_dates.sql
│
├── macros/                     # Fonctions réutilisables
│   ├── get_flight_duration.sql
│   ├── calculate_delay.sql
│   ├── categorize_flight_status.sql
│   ├── extract_phone_number.sql
│   ├── extract_email.sql
│   ├── cents_to_currency.sql
│   └── generate_surrogate_key.sql
│
├── seeds/                      # Données de référence
│   ├── flight_status_mapping.csv
│   ├── fare_conditions_mapping.csv
│   └── airport_regions.csv
│
├── analyses/                   # Requêtes analytiques
│   ├── top_routes_analysis.sql
│   ├── revenue_analysis.sql
│   ├── occupancy_rate_analysis.sql
│   ├── delay_analysis.sql
│   └── passenger_segmentation.sql
│
└── tests/                      # Tests personnalisés
    ├── assert_positive_amounts.sql
    ├── assert_flight_duration_positive.sql
    ├── assert_arrival_after_departure.sql
    ├── assert_booking_has_tickets.sql
    └── assert_seat_assigned_once_per_flight.sql
```

## 🔧 Macros disponibles

### Calculs de durée et retards
- `get_flight_duration(departure_col, arrival_col, unit)` - Calcule la durée d'un vol
- `calculate_delay(scheduled_col, actual_col, unit)` - Calcule le retard

### Transformations de données
- `cents_to_currency(amount_col, decimals)` - Convertit centimes en devise
- `extract_phone_number(contact_data_col)` - Extrait le téléphone du JSON
- `extract_email(contact_data_col)` - Extrait l'email du JSON
- `categorize_flight_status(status_col)` - Traduit le statut en français
- `generate_surrogate_key(field_list)` - Génère une clé de substitution MD5

## 📊 Modèles principaux

### Tables de faits (Facts)

#### fct_bookings
Table de faits des réservations avec métriques agrégées
- Métriques: montant, nombre de passagers, segments de vol
- Dimensions: date, type de réservation, complexité du voyage

#### fct_flights
Table de faits des vols avec performance opérationnelle
- Métriques: durées, retards
- Dimensions: aéroports, appareil, dates
- Catégories de performance

### Tables de dimension (Dimensions)

#### dim_airports
Dimension des aéroports avec trafic et performance
- Attributs: code, nom, ville, fuseau horaire
- Métriques: trafic, retards moyens
- Catégories: type d'aéroport, note de performance

#### dim_aircrafts
Dimension des appareils avec utilisation
- Attributs: code, modèle, autonomie
- Métriques: vols, taux d'occupation
- Configuration: nombre de sièges par classe

#### dim_passengers
Dimension des passagers avec historique
- Attributs: nom, contacts
- Métriques: réservations, dépenses totales
- Segmentation: niveau de fidélité

#### dim_dates
Dimension calendaire pour analyses temporelles
- Composantes: année, mois, jour, trimestre, semaine
- Indicateurs: week-end, jour de semaine
- Formats multiples

## 🧪 Tests implémentés

### Tests génériques (dans .yml)
- `unique` - Unicité des clés primaires
- `not_null` - Non-nullité des colonnes critiques
- `relationships` - Intégrité référentielle
- `accepted_values` - Valeurs acceptables (status, fare_conditions)

### Tests personnalisés (dans tests/)
- Montants positifs
- Durées de vol valides
- Logique temporelle (arrivée après départ)
- Intégrité des réservations
- Unicité des sièges par vol

## 📈 Analyses disponibles

1. **top_routes_analysis** - Routes les plus fréquentées
2. **revenue_analysis** - Analyse des revenus par période et classe
3. **occupancy_rate_analysis** - Taux d'occupation des vols
4. **delay_analysis** - Patterns de retards
5. **passenger_segmentation** - Segmentation de la clientèle

## 🚀 Utilisation

### Commandes de base

```bash
# Installer les dépendances
cd dbt_projects/dbt_demo

# Charger les seeds
dbt seed

# Exécuter tous les modèles
dbt run

# Exécuter les tests
dbt test

# Générer la documentation
dbt docs generate

# Servir la documentation
dbt docs serve
```

### Exécution sélective

```bash
# Par layer
dbt run --select tag:staging
dbt run --select tag:silver
dbt run --select tag:gold

# Par modèle spécifique
dbt run --select stg_flights
dbt run --select fct_flights+

# Tests sur un modèle
dbt test --select fct_bookings
```

### Exécution des analyses

```bash
# Compiler une analyse
dbt compile --select analyses/top_routes_analysis

# Le SQL compilé sera dans target/compiled/dbt_demo/analyses/
```

## 🎨 Conventions de nommage

### Modèles
- **Staging**: `stg_<table_name>`
- **Intermediate**: `<entity>_<metric/purpose>`
- **Facts**: `fct_<entity>`
- **Dimensions**: `dim_<entity>`

### Colonnes
- Clés primaires: `<table>_id` ou natural key
- Clés de substitution: `<table>_key`
- Clés étrangères: `<referenced_table>_id` ou natural key
- Montants: `<name>_cents` et `<name>_currency`
- Dates: `<event>_date`, `<event>_datetime`

### Tags
- `staging`, `bronze` - Layer de staging
- `intermediate`, `silver` - Layer intermédiaire
- `analytics`, `gold` - Layer analytique
- `seed`, `reference` - Données de référence

## 📚 Documentation

Chaque modèle inclut:
- Description du modèle
- Description de chaque colonne
- Tests de qualité de données
- Relations entre tables

La documentation complète est accessible via:
```bash
dbt docs generate
dbt docs serve
```

## 🔄 Lineage (Lignage des données)

Le lineage complet est visualisable dans la documentation dbt:
1. Sources → Staging (Bronze)
2. Staging → Intermediate (Silver)
3. Intermediate → Analytics (Gold)

## 🎯 KPIs et métriques clés

### Opérationnel
- Taux de ponctualité des vols
- Taux d'annulation
- Taux d'occupation des avions
- Retards moyens par aéroport

### Commercial
- Revenu total et par classe
- Revenu moyen par passager
- Taux de réservation par période
- Segmentation client

### Performance
- Utilisation des appareils
- Performance des routes
- Efficacité des aéroports

## 👥 Contributeurs

Projet créé pour le Data Engineering Workshop - IFRI Future of AI
