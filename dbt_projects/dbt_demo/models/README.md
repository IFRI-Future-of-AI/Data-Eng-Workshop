# 📊 Documentation des Modèles dbt - Airlines Database

## 🏗️ Architecture du Projet

Ce projet dbt suit une architecture en couches (layered architecture) pour garantir la maintenabilité et la clarté des transformations de données.

```
models/
├── 📁 sources (schema.yml)      # Définition des sources de données brutes
├── 📁 staging/                  # Couche 1: Nettoyage et standardisation
├── 📁 intermediate/             # Couche 2: Enrichissements et jointures
└── 📁 marts/                    # Couche 3: Modèles finaux pour l'analyse
    ├── finance/                 # Métriques financières
    ├── operations/              # Métriques opérationnelles
    └── customers/               # Métriques clients
```

---

## 📚 Couche 1: Staging (Vue)

**Objectif**: Nettoyer et standardiser les données brutes de la source.

### Modèles Disponibles

| Modèle | Description | Clé Primaire |
|--------|-------------|--------------|
| `stg_bookings` | Réservations nettoyées | `id` (book_ref) |
| `stg_tickets` | Billets passagers | `id` (ticket_no) |
| `stg_fligths` | Vols avec dates réelles uniquement | `id` (flight_id) |
| `stg_airports` | Aéroports avec coordonnées GPS | `airport_code` |
| `stg_aircrafts` | Modèles d'appareils | `aircraft_code` |
| `stg_seats` | Configuration sièges | `aircraft_code, seat_no` |
| `stg_boarding_passes` | Cartes d'embarquement | `ticket_no, flight_id` |
| `stg_ticket_flights` | Segments de vol | `ticket_no, flight_id` |

### Transformations Appliquées

- ✅ Extraction de données JSONB (noms multilingues, contacts)
- ✅ Standardisation des noms de colonnes
- ✅ Filtrage des données invalides
- ✅ Ajout de métadonnées de chargement (`dbt_loaded_at`)

### Exemple d'utilisation

```sql
-- Utiliser un modèle staging dans une transformation
SELECT * FROM {{ ref('stg_bookings') }}
```

---

## 🔄 Couche 2: Intermediate (Table)

**Objectif**: Enrichir les données avec des jointures et calculs métier.

### Modèles Disponibles

| Modèle | Description | Dépendances |
|--------|-------------|-------------|
| `int_flights_enriched` | Vols enrichis avec aéroports et appareils | stg_fligths, stg_airports, stg_aircrafts |
| `int_bookings_with_revenue` | Réservations avec métriques financières | stg_bookings, stg_tickets, stg_ticket_flights |
| `int_passenger_journeys` | Parcours complets des passagers | stg_tickets, stg_ticket_flights, int_flights_enriched |

### Enrichissements Clés

#### `int_flights_enriched`
- ⏱️ Calcul durées de vol (réelles et prévues)
- 📉 Calcul des retards (départ et arrivée)
- 🗺️ Calcul distances avec formule Haversine
- 🏷️ Catégorisation des retards
- 📍 Informations géographiques complètes

#### `int_bookings_with_revenue`
- 💰 Agrégation des revenus par réservation
- 👥 Comptage des passagers
- ✈️ Métriques de segments de vol
- 🏆 Segmentation de valeur client
- 📊 Distribution par classe de cabine

#### `int_passenger_journeys`
- 🎫 Reconstitution du parcours complet
- 🔢 Numérotation des segments
- 🚩 Identification origine/destination
- 💺 Informations d'embarquement
- 📈 Métriques cumulées du voyage

---

## 🎯 Couche 3: Marts (Table)

**Objectif**: Modèles finaux optimisés pour l'analyse et le reporting.

### 📁 Domaine: Finance

| Modèle | Type | Description |
|--------|------|-------------|
| `fct_bookings` | Fait | Métriques de revenus et réservations |

**Cas d'usage**: 
- Analyse des revenus par période
- Segmentation de valeur client
- Patterns de réservation

### 📁 Domaine: Operations

| Modèle | Type | Description |
|--------|------|-------------|
| `fct_flights` | Fait | Performance des vols |
| `dim_airports` | Dimension | Référentiel aéroports |
| `dim_aircrafts` | Dimension | Référentiel appareils |

**Cas d'usage**:
- Analyse de ponctualité
- Optimisation des routes
- Gestion de flotte

### 📁 Domaine: Customers

| Modèle | Type | Description |
|--------|------|-------------|
| `dim_passengers` | Dimension | Profil et historique passagers |

**Cas d'usage**:
- Programmes de fidélité
- Segmentation client
- Analyse de comportement

---

## 🔧 Macros Disponibles

Des macros réutilisables pour simplifier les transformations:

### `calculate_flight_duration()`
Calcule la durée entre deux timestamps.

```sql
{{ calculate_flight_duration('actual_departure', 'actual_arrival', 'hours') }}
```

### `categorize_flight_status()`
Catégorise le statut d'un vol.

```sql
{{ categorize_flight_status('status') }} AS status_category
```

### `extract_json_contact()`
Extrait un champ d'un objet JSONB.

```sql
{{ extract_json_contact('contact_data', 'email') }} AS passenger_email
```

### `calculate_haversine_distance()`
Calcule la distance entre deux points GPS.

```sql
{{ calculate_haversine_distance('lat1', 'lon1', 'lat2', 'lon2') }} AS distance_km
```

---

## 🧪 Tests de Qualité

Tous les modèles sont testés avec:

- ✅ **Tests d'unicité** sur les clés primaires
- ✅ **Tests de non-nullité** sur les colonnes critiques
- ✅ **Tests de relations** (foreign keys)
- ✅ **Tests de valeurs acceptées** (énumérations)
- ✅ **Test personnalisé** `valid_airport_code` pour codes IATA

### Exécuter les tests

```bash
# Tous les tests
dbt test

# Tests d'un modèle spécifique
dbt test --select stg_bookings

# Tests d'une couche
dbt test --select staging
```

---

## 📈 Analyses Disponibles

Requêtes analytiques prêtes à l'emploi dans le dossier `analyses/`:

| Analyse | Description |
|---------|-------------|
| `revenue_by_route.sql` | Routes les plus rentables |
| `flight_occupancy_rates.sql` | Taux de remplissage des vols |
| `passenger_loyalty_analysis.sql` | Segmentation et fidélité clients |
| `seasonal_trends.sql` | Tendances saisonnières |
| `on_time_performance.sql` | Performance de ponctualité |

### Exécuter une analyse

```bash
dbt compile --select analysis:revenue_by_route
```

---

## 🌱 Seeds (Données de Référence)

Tables de référence chargées depuis CSV:

| Seed | Description |
|------|-------------|
| `flight_status_codes` | Codes et catégories de statuts |
| `fare_class_descriptions` | Descriptions des classes tarifaires |
| `airport_regions` | Régions et types de hubs |
| `aircraft_manufacturers` | Constructeurs d'appareils |

### Charger les seeds

```bash
dbt seed
```

---

## 🚀 Commandes Utiles

```bash
# Exécuter tous les modèles
dbt run

# Exécuter une couche spécifique
dbt run --select staging
dbt run --select intermediate
dbt run --select marts

# Exécuter un domaine spécifique
dbt run --select marts.finance
dbt run --select marts.operations

# Générer la documentation
dbt docs generate
dbt docs serve

# Pipeline complet (seeds + run + test)
dbt seed && dbt run && dbt test
```

---

## 📊 DAG (Lineage)

Le projet crée un DAG de dépendances automatique:

```
Sources (bookings DB)
    ↓
Staging Layer (views)
    ↓
Intermediate Layer (tables)
    ↓
Marts Layer (tables)
```

Visualisez le DAG avec:
```bash
dbt docs generate
dbt docs serve
```

---

## 🎓 Bonnes Pratiques Implémentées

1. ✅ **Séparation des couches** : Staging → Intermediate → Marts
2. ✅ **Nommage cohérent** : Préfixes `stg_`, `int_`, `fct_`, `dim_`
3. ✅ **Documentation complète** : Tous les modèles et colonnes documentés
4. ✅ **Tests systématiques** : Qualité de données garantie
5. ✅ **Macros réutilisables** : DRY (Don't Repeat Yourself)
6. ✅ **Métriques métier** : Calculs cohérents centralisés
7. ✅ **Traçabilité** : Métadonnées `dbt_loaded_at`, `dbt_updated_at`

---

## 🤝 Contribution

Pour ajouter un nouveau modèle:

1. Créer le fichier `.sql` dans le bon dossier
2. Ajouter la documentation dans le fichier `_<layer>.yml`
3. Ajouter les tests appropriés
4. Exécuter `dbt run` et `dbt test`
5. Vérifier le lineage dans `dbt docs`

---

**Créé dans le cadre du Data Engineering Workshop - IFRI Future of AI**
