# 🚀 Guide Complet du Projet dbt Airlines

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture](#architecture)
3. [Installation](#installation)
4. [Structure des modèles](#structure-des-modèles)
5. [Utilisation](#utilisation)
6. [Tests et qualité](#tests-et-qualité)
7. [Cas d'usage](#cas-dusage)
8. [Bonnes pratiques](#bonnes-pratiques)

## 🎯 Vue d'ensemble

Le projet dbt Airlines transforme les données brutes d'une compagnie aérienne en un data warehouse analytique prêt pour la Business Intelligence. Il implémente une architecture médaillon (Bronze/Silver/Gold) avec:

- **20 modèles SQL** organisés en 3 couches
- **7 macros réutilisables** pour les transformations
- **4 seeds** pour les données de référence
- **5 analyses prédéfinies** pour les cas d'usage métier
- **Tests complets** de qualité de données

### Statistiques du projet

| Composant | Nombre | Description |
|-----------|--------|-------------|
| Sources | 8 | Tables de base de données |
| Modèles Staging | 8 | Layer Bronze (Views) |
| Modèles Intermediate | 6 | Layer Silver (Tables) |
| Modèles Analytics | 6 | Layer Gold (Tables) |
| Macros | 7 | Fonctions réutilisables |
| Seeds | 4 | Données de référence |
| Analyses | 5 | Requêtes métier |
| Tests | 50+ | Tests de qualité |

## 🏗️ Architecture

### Architecture médaillon

```
┌────────────────────────────────────────────────────────────────┐
│                        SOURCE LAYER                            │
│                 PostgreSQL - demo.bookings                     │
│  bookings | tickets | flights | airports | aircrafts          │
│  seats | ticket_flights | boarding_passes                     │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│                   BRONZE LAYER - Staging                       │
│                      Materialized: VIEW                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │stg_bookings  │  │ stg_tickets  │  │ stg_flights  │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │stg_airports  │  │stg_aircrafts │  │  stg_seats   │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│  ┌──────────────┐  ┌──────────────┐                           │
│  │stg_ticket_   │  │stg_boarding_ │                           │
│  │   flights    │  │   passes     │                           │
│  └──────────────┘  └──────────────┘                           │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│                  SILVER LAYER - Intermediate                   │
│                     Materialized: TABLE                        │
│  ┌──────────────────┐  ┌──────────────────┐                   │
│  │flights_enriched  │  │bookings_metrics  │                   │
│  └──────────────────┘  └──────────────────┘                   │
│  ┌──────────────────┐  ┌──────────────────┐                   │
│  │passenger_journey │  │aircraft_util...  │                   │
│  └──────────────────┘  └──────────────────┘                   │
│  ┌──────────────────┐  ┌──────────────────┐                   │
│  │airport_traffic   │  │tickets_with_...  │                   │
│  └──────────────────┘  └──────────────────┘                   │
└────────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│                   GOLD LAYER - Analytics                       │
│                     Materialized: TABLE                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │
│  │fct_bookings │  │ fct_flights │  │             │           │
│  └─────────────┘  └─────────────┘  │             │           │
│                                     │             │           │
│  ┌─────────────┐  ┌─────────────┐  │ Star Schema │           │
│  │dim_airports │  │dim_aircrafts│  │   Ready     │           │
│  └─────────────┘  └─────────────┘  │             │           │
│  ┌─────────────┐  ┌─────────────┐  │             │           │
│  │dim_passengers│ │  dim_dates  │  │             │           │
│  └─────────────┘  └─────────────┘  └─────────────┘           │
└────────────────────────────────────────────────────────────────┘
```

## 🛠️ Installation

### Prérequis

```bash
# Python 3.7+
python --version

# PostgreSQL (via Docker)
docker --version
docker compose --version
```

### Installation de dbt

```bash
# Installer dbt-core et l'adaptateur PostgreSQL
pip install dbt-core dbt-postgres

# Vérifier l'installation
dbt --version
```

### Configuration

```bash
# Naviguer vers le projet
cd dbt_projects/dbt_demo

# Configurer le profil (déjà configuré dans profiles.yml)
# Adapter si nécessaire pour votre environnement

# Tester la connexion
dbt debug
```

### Lancement de la base de données

```bash
# Retour au répertoire racine
cd ../../

# Lancer PostgreSQL avec Docker Compose
docker compose up -d

# Vérifier que la base est accessible
docker compose ps
```

## 📊 Structure des modèles

### Layer Bronze (Staging)

**Objectif**: Nettoyage et standardisation des données sources

| Modèle | Description | Transformations clés |
|--------|-------------|---------------------|
| `stg_bookings` | Réservations | Renommage colonnes, alias |
| `stg_tickets` | Billets | Extraction contacts JSON |
| `stg_fligths` | Vols complétés | Filtrage vols atterris |
| `stg_airports` | Aéroports | Extraction noms multilingues |
| `stg_aircrafts` | Appareils | Catégorisation autonomie |
| `stg_seats` | Sièges | Parsing numéros de siège |
| `stg_ticket_flights` | Segments | Conversion montants |
| `stg_boarding_passes` | Cartes embarquement | Groupes prioritaires |

### Layer Silver (Intermediate)

**Objectif**: Enrichissements et métriques métier

| Modèle | Description | Métriques calculées |
|--------|-------------|---------------------|
| `flights_enriched` | Vols enrichis | Durées, retards, statuts |
| `bookings_metrics` | Métriques réservations | Nombre passagers, segments |
| `passenger_journey` | Parcours passagers | Statut voyage complet |
| `aircraft_utilization` | Utilisation avions | Taux occupation, performance |
| `airport_traffic` | Trafic aéroports | Volumes, retards moyens |
| `tickets_with_bookings` | Billets-réservations | Jointure simple |

### Layer Gold (Analytics)

**Objectif**: Modèle dimensionnel pour BI

#### Tables de faits

| Table | Grain | Métriques principales |
|-------|-------|----------------------|
| `fct_bookings` | Une ligne = une réservation | Montant, nb passagers, segments |
| `fct_flights` | Une ligne = un vol | Durées, retards, performance |

#### Tables de dimension

| Table | Type | Attributs clés |
|-------|------|---------------|
| `dim_airports` | SCD Type 0 | Code, nom, trafic, performance |
| `dim_aircrafts` | SCD Type 0 | Code, modèle, sièges, utilisation |
| `dim_passengers` | SCD Type 2 | ID, nom, historique, tier |
| `dim_dates` | SCD Type 0 | Date, composantes, indicateurs |

## 🎮 Utilisation

### Commandes essentielles

```bash
# Charger les données de référence
dbt seed

# Exécuter tous les modèles
dbt run

# Exécuter par layer
dbt run --select tag:staging
dbt run --select tag:silver
dbt run --select tag:gold

# Exécuter un modèle spécifique avec ses dépendances
dbt run --select +fct_flights

# Exécuter les tests
dbt test

# Tester un modèle spécifique
dbt test --select fct_bookings

# Générer la documentation
dbt docs generate

# Visualiser la documentation
dbt docs serve
```

### Exécution des analyses

```bash
# Compiler une analyse (sans exécution)
dbt compile --select analyses/top_routes_analysis

# Le SQL compilé sera disponible dans:
# target/compiled/dbt_demo/analyses/top_routes_analysis.sql

# Pour exécuter, copier le SQL et l'exécuter manuellement
# dans votre client PostgreSQL
```

## 🧪 Tests et qualité

### Types de tests implémentés

#### 1. Tests génériques (dans .yml)

```yaml
# Exemple de tests sur une colonne
columns:
  - name: booking_ref
    tests:
      - unique              # Pas de doublons
      - not_null            # Pas de valeurs nulles
      - relationships:      # Intégrité référentielle
          to: source('demo', 'bookings')
          field: book_ref
```

#### 2. Tests personnalisés (dans tests/)

| Test | Validation |
|------|-----------|
| `assert_positive_amounts` | Montants > 0 |
| `assert_flight_duration_positive` | Durées entre 10 min et 24h |
| `assert_arrival_after_departure` | Arrivée > Départ |
| `assert_booking_has_tickets` | Chaque réservation a ≥1 billet |
| `assert_seat_assigned_once` | Pas de sièges dupliqués |

### Exécution des tests

```bash
# Tous les tests
dbt test

# Tests d'un modèle
dbt test --select fct_flights

# Tests d'un type spécifique
dbt test --select test_type:unique
dbt test --select test_type:relationship

# Tests par layer
dbt test --select tag:gold
```

## 💼 Cas d'usage

### 1. Analyse des retards de vol

```sql
-- Compiler l'analyse
-- dbt compile --select analyses/delay_analysis

-- Puis exécuter le SQL compilé pour voir:
-- - Retards par aéroport et période
-- - Patterns de retards (matin/soir, jour de semaine)
-- - Taux de ponctualité
-- - Classification des risques de retard
```

### 2. Analyse des revenus

```sql
-- dbt compile --select analyses/revenue_analysis

-- Obtenir:
-- - Revenus par jour/mois
-- - Revenus par classe tarifaire
-- - Revenus moyens par passager
-- - Comparaison weekend vs semaine
```

### 3. Segmentation client

```sql
-- dbt compile --select analyses/passenger_segmentation

-- Classifier les passagers par:
-- - Fréquence de voyage (Frequent/Occasional/One-time)
-- - Valeur (VIP/High/Medium/Low)
-- - Préférences (Business/Comfort/Economy)
-- - Diversité géographique
```

### 4. Performance des routes

```sql
-- dbt compile --select analyses/top_routes_analysis

-- Analyser:
-- - Routes les plus fréquentées
-- - Taux d'annulation par route
-- - Retards moyens par route
-- - Performance globale
```

### 5. Taux d'occupation

```sql
-- dbt compile --select analyses/occupancy_rate_analysis

-- Calculer:
-- - Taux d'occupation par vol
-- - Taux moyens par appareil
-- - Opportunités de revenus
-- - Vols à risque (faible occupation)
```

## ✨ Bonnes pratiques

### Conventions de nommage

```
Sources:        <table_name>
Staging:        stg_<entity>
Intermediate:   <entity>_<purpose>
Facts:          fct_<entity>
Dimensions:     dim_<entity>
Analyses:       <topic>_analysis
```

### Structure des requêtes

```sql
-- 1. Configuration
{{ config(materialized='table') }}

-- 2. CTEs pour lisibilité
WITH source AS (
    SELECT * FROM {{ ref('stg_table') }}
),

transformed AS (
    SELECT
        -- Transformations
    FROM source
)

-- 3. Requête finale
SELECT * FROM transformed
```

### Documentation

- Documenter TOUS les modèles dans .yml
- Inclure descriptions pour chaque colonne critique
- Ajouter des tests sur clés et relations
- Maintenir PROJECT_OVERVIEW.md à jour

### Performance

- Staging: **views** (données fraîches)
- Intermediate: **tables** (performance)
- Analytics: **tables** (optimisé pour BI)
- Utiliser incremental pour gros volumes (si nécessaire)

### Tests

- Au minimum: unique + not_null sur clés
- Relationships pour foreign keys
- Accepted_values pour énumérations
- Custom tests pour logique métier complexe

## 📚 Ressources supplémentaires

### Documentation dbt
- [dbt Docs](https://docs.getdbt.com/)
- [Best Practices](https://docs.getdbt.com/guides/best-practices)
- [dbt Learn](https://courses.getdbt.com/)

### Fichiers du projet
- `PROJECT_OVERVIEW.md` - Architecture détaillée
- `README.md` - Guide de démarrage
- `models/schema.yml` - Documentation des sources
- `models/*/_.yml` - Documentation par layer

### Communauté
- [dbt Slack](https://community.getdbt.com/)
- [dbt Discourse](https://discourse.getdbt.com/)

---

**Projet créé pour le Data Engineering Workshop - IFRI Future of AI**

Pour toute question ou contribution, consultez le dépôt principal: [Data-Eng-Workshop](https://github.com/IFRI-Future-of-AI/Data-Eng-Workshop)
