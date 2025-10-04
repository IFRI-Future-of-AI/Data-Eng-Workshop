# 📐 Structure Complète du Projet dbt - Airlines

## 🎯 Vue d'ensemble de l'Architecture

Ce document décrit la structure complète du projet dbt enrichi, avec toutes les couches, modèles, et dépendances.

---

## 📊 Diagramme de Lineage

```
┌─────────────────────────────────────────────────────────────────────┐
│                         SOURCES (PostgreSQL)                         │
├─────────────────────────────────────────────────────────────────────┤
│  bookings  │  tickets  │  flights  │  airports_data  │  aircrafts_data  │
│  ticket_flights  │  boarding_passes  │  seats                       │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     STAGING LAYER (Views)                            │
├─────────────────────────────────────────────────────────────────────┤
│  stg_bookings      │  stg_tickets       │  stg_fligths              │
│  stg_airports      │  stg_aircrafts     │  stg_seats                │
│  stg_boarding_passes  │  stg_ticket_flights                         │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   INTERMEDIATE LAYER (Tables)                        │
├─────────────────────────────────────────────────────────────────────┤
│  int_flights_enriched                                                │
│      ↑ stg_fligths + stg_airports + stg_aircrafts                  │
│                                                                      │
│  int_bookings_with_revenue                                          │
│      ↑ stg_bookings + stg_tickets + stg_ticket_flights             │
│                                                                      │
│  int_passenger_journeys                                             │
│      ↑ stg_tickets + stg_ticket_flights + int_flights_enriched     │
│         + stg_boarding_passes                                       │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        MARTS LAYER (Tables)                          │
├─────────────────────────────────────────────────────────────────────┤
│  📁 Finance/                                                         │
│    └─ fct_bookings  ←  int_bookings_with_revenue                   │
│                                                                      │
│  📁 Operations/                                                      │
│    ├─ fct_flights  ←  int_flights_enriched                         │
│    ├─ dim_airports  ←  stg_airports                                │
│    └─ dim_aircrafts  ←  stg_aircrafts                              │
│                                                                      │
│  📁 Customers/                                                       │
│    └─ dim_passengers  ←  stg_tickets + int_passenger_journeys      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📁 Arborescence Détaillée

```
dbt_projects/dbt_demo/
│
├── 📄 dbt_project.yml          # Configuration principale du projet
├── 📄 profiles.yml             # Configuration connexion PostgreSQL
├── 📄 README.md                # Documentation principale (280 lignes)
├── 📄 STRUCTURE.md             # Ce fichier (architecture détaillée)
│
├── 📁 models/                  # Tous les modèles SQL
│   │
│   ├── 📄 README.md            # Guide complet des modèles (330 lignes)
│   ├── 📄 schema.yml           # Définition des 8 sources avec tests
│   │
│   ├── 📁 staging/             # Couche 1: Nettoyage (8 modèles)
│   │   ├── 📄 _staging.yml     # Documentation staging (195 lignes)
│   │   ├── 📄 stg_bookings.sql
│   │   ├── 📄 stg_tickets.sql
│   │   ├── 📄 stg_fligths.sql
│   │   ├── 📄 stg_airports.sql
│   │   ├── 📄 stg_aircrafts.sql
│   │   ├── 📄 stg_seats.sql
│   │   ├── 📄 stg_boarding_passes.sql
│   │   └── 📄 stg_ticket_flights.sql
│   │
│   ├── 📁 intermediate/        # Couche 2: Enrichissement (3 modèles)
│   │   ├── 📄 _intermediate.yml # Documentation intermediate (142 lignes)
│   │   ├── 📄 int_flights_enriched.sql
│   │   ├── 📄 int_bookings_with_revenue.sql
│   │   └── 📄 int_passenger_journeys.sql
│   │
│   ├── 📁 marts/               # Couche 3: Analytics (5 modèles)
│   │   ├── 📄 _marts.yml       # Documentation marts (163 lignes)
│   │   │
│   │   ├── 📁 finance/         # Domaine Finance
│   │   │   └── 📄 fct_bookings.sql
│   │   │
│   │   ├── 📁 operations/      # Domaine Opérations
│   │   │   ├── 📄 fct_flights.sql
│   │   │   ├── 📄 dim_airports.sql
│   │   │   └── 📄 dim_aircrafts.sql
│   │   │
│   │   └── 📁 customers/       # Domaine Clients
│   │       └── 📄 dim_passengers.sql
│   │
│   └── 📁 silvers/             # Legacy (à migrer)
│       └── 📄 tickets_with_bookings.sql
│
├── 📁 macros/                  # Macros réutilisables (6 macros)
│   ├── 📄 calculate_flight_duration.sql
│   ├── 📄 calculate_haversine_distance.sql
│   ├── 📄 categorize_flight_status.sql
│   ├── 📄 extract_json_contact.sql
│   ├── 📄 generate_schema_name.sql
│   └── 📄 test_valid_airport_code.sql
│
├── 📁 seeds/                   # Données de référence (4 seeds)
│   ├── 📄 README.md            # Documentation seeds (160 lignes)
│   ├── 📄 flight_status_codes.csv
│   ├── 📄 fare_class_descriptions.csv
│   ├── 📄 airport_regions.csv
│   ├── 📄 aircraft_manufacturers.csv
│   └── 📄 mock_data.csv        # Legacy
│
├── 📁 analyses/                # Requêtes analytiques (5 analyses)
│   ├── 📄 README.md            # Guide des analyses (280 lignes)
│   ├── 📄 revenue_by_route.sql
│   ├── 📄 flight_occupancy_rates.sql
│   ├── 📄 passenger_loyalty_analysis.sql
│   ├── 📄 seasonal_trends.sql
│   └── 📄 on_time_performance.sql
│
├── 📁 tests/                   # Tests personnalisés
│   └── 📄 .gitkeep
│
└── 📁 snapshots/               # Snapshots SCD (future use)
    └── 📄 .gitkeep
```

---

## 🔢 Statistiques du Projet

### Modèles SQL
- **Total**: 16 modèles
- **Staging**: 8 views
- **Intermediate**: 3 tables
- **Marts**: 5 tables (2 facts + 3 dimensions)

### Documentation
- **Total**: 9 fichiers de documentation
- **Lignes de doc**: ~1,550 lignes
- **Sources documentées**: 8 tables
- **Modèles documentés**: 16 modèles
- **Colonnes documentées**: ~150 colonnes

### Tests
- **Tests génériques**: ~80 tests
  - Unique: ~15 tests
  - Not null: ~35 tests
  - Relationships: ~15 tests
  - Accepted values: ~15 tests
- **Tests personnalisés**: 1 (valid_airport_code)

### Macros
- **Total**: 6 macros réutilisables
- **Catégories**:
  - Calculs: 2 (duration, haversine)
  - Transformations: 2 (categorize, extract_json)
  - Utilitaires: 2 (generate_schema, test)

### Seeds
- **Total**: 4 fichiers CSV
- **Lignes de données**: ~25 lignes

### Analyses
- **Total**: 5 analyses
- **Domaines**: Finance (1), Operations (2), Customers (1), Temporel (1)

---

## 🔄 Flux de Données Détaillé

### 1. Staging Layer → Sources

```sql
-- Exemple: stg_airports
source('demo', 'airports_data')
    ↓ [Extraction JSONB, Parsing GPS]
stg_airports (view)
```

**Transformations appliquées**:
- Extraction de données JSONB multilingues
- Parsing de coordonnées GPS (POINT → lat/lon)
- Standardisation des noms de colonnes
- Filtrage des données invalides
- Ajout de métadonnées `dbt_loaded_at`

### 2. Intermediate Layer → Staging

```sql
-- Exemple: int_flights_enriched
stg_fligths + stg_airports (dep) + stg_airports (arr) + stg_aircrafts
    ↓ [Jointures, Calculs métriques]
int_flights_enriched (table)
```

**Transformations appliquées**:
- Jointures multiples (flights, airports, aircrafts)
- Calculs de durées (réelles vs prévues)
- Calculs de retards (départ, arrivée)
- Calcul de distance géographique (Haversine)
- Catégorisation (retards, performance)
- Window functions (analytiques)

### 3. Marts Layer → Intermediate

```sql
-- Exemple: dim_passengers
stg_tickets + int_passenger_journeys
    ↓ [Agrégations, Métriques]
dim_passengers (table)
```

**Transformations appliquées**:
- Agrégations par entité métier
- Calculs de métriques clés (lifetime value, préférences)
- Segmentation (RFM, valeur client)
- Dédoublonnage et unification

---

## 📊 Matrice des Dépendances

| Modèle Marts | Sources Intermediate | Sources Staging |
|--------------|---------------------|-----------------|
| fct_bookings | int_bookings_with_revenue | - |
| fct_flights | int_flights_enriched | - |
| dim_airports | - | stg_airports |
| dim_aircrafts | - | stg_aircrafts |
| dim_passengers | int_passenger_journeys | stg_tickets |

| Modèle Intermediate | Sources Staging |
|---------------------|-----------------|
| int_flights_enriched | stg_fligths, stg_airports, stg_aircrafts |
| int_bookings_with_revenue | stg_bookings, stg_tickets, stg_ticket_flights |
| int_passenger_journeys | stg_tickets, stg_ticket_flights, stg_boarding_passes, int_flights_enriched |

---

## 🎯 Utilisation des Macros

### Dans les modèles

```sql
-- Utilisation de calculate_flight_duration
SELECT
    flight_id,
    {{ calculate_flight_duration('actual_departure', 'actual_arrival', 'hours') }} AS duration_hours
FROM {{ ref('stg_fligths') }}

-- Utilisation de categorize_flight_status
SELECT
    flight_id,
    status,
    {{ categorize_flight_status('status') }} AS status_category
FROM {{ ref('stg_fligths') }}

-- Utilisation de extract_json_contact
SELECT
    passenger_name,
    {{ extract_json_contact('contact_data', 'email') }} AS email,
    {{ extract_json_contact('contact_data', 'phone') }} AS phone
FROM {{ ref('stg_tickets') }}
```

### Dans les tests

```sql
# Dans _staging.yml
models:
  - name: stg_airports
    columns:
      - name: airport_code
        tests:
          - valid_airport_code
```

---

## 🎨 Conventions de Nommage

### Préfixes des modèles
- `stg_` : Staging layer (views)
- `int_` : Intermediate layer (tables)
- `fct_` : Fact tables (marts)
- `dim_` : Dimension tables (marts)

### Schémas PostgreSQL
- `staging` : Modèles staging
- `intermediate` : Modèles intermediate
- `marts` : Modèles marts (tous domaines)
- `seeds` : Tables seeds

### Colonnes
- `snake_case` pour tous les noms
- Suffixes explicites : `_id`, `_code`, `_date`, `_amount`, etc.
- Métadonnées : `dbt_loaded_at`, `dbt_updated_at`

---

## 🚀 Pipeline de Déploiement

### Ordre d'exécution recommandé

```bash
# 1. Charger les seeds (données de référence)
dbt seed

# 2. Exécuter staging (views rapides)
dbt run --select staging

# 3. Exécuter intermediate (tables avec calculs)
dbt run --select intermediate

# 4. Exécuter marts (tables finales)
dbt run --select marts

# 5. Exécuter tous les tests
dbt test

# Pipeline complet
dbt build  # = seed + run + test
```

### Ordonnancement par priorité

1. **Haute priorité** (quotidien)
   - staging (rafraîchissement données)
   - int_flights_enriched
   - fct_flights

2. **Priorité moyenne** (hebdomadaire)
   - int_bookings_with_revenue
   - fct_bookings
   - dim_passengers

3. **Basse priorité** (mensuel)
   - Seeds (mises à jour référence)
   - Dimensions statiques

---

## 📈 Métriques Clés Disponibles

### Finance
- ✅ Revenus totaux / par période
- ✅ Revenu moyen par passager
- ✅ Distribution par classe tarifaire
- ✅ Segmentation valeur client
- ✅ Lifetime value

### Opérations
- ✅ Taux de ponctualité
- ✅ Retards moyens (départ/arrivée)
- ✅ Taux d'occupation des vols
- ✅ Distance moyenne des routes
- ✅ Durée moyenne des vols

### Clients
- ✅ Nombre de vols par passager
- ✅ Classe préférée
- ✅ Distance totale parcourue
- ✅ Taux de rétention
- ✅ Segmentation RFM

---

## 🔧 Améliorations Futures Proposées

### Court terme
- [ ] Ajouter snapshots pour SCD (Slowly Changing Dimensions)
- [ ] Créer tests de performance (temps d'exécution)
- [ ] Ajouter exposures pour dashboards BI

### Moyen terme
- [ ] Implémenter incremental models pour grandes tables
- [ ] Ajouter orchestration avec Airflow/Prefect
- [ ] Créer métriques dbt (metrics.yml)

### Long terme
- [ ] Implémenter dbt Cloud pour CI/CD
- [ ] Créer packages dbt réutilisables
- [ ] Ajouter machine learning features

---

## 📚 Ressources Additionnelles

### Documentation interne
- `models/README.md` - Guide des modèles
- `seeds/README.md` - Documentation seeds
- `analyses/README.md` - Guide analyses
- `README.md` - Documentation principale

### Documentation externe
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
- [dbt Style Guide](https://github.com/dbt-labs/corp/blob/main/dbt_style_guide.md)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

**Structure créée dans le cadre du Data Engineering Workshop - IFRI Future of AI**

*Dernière mise à jour: Décembre 2024*
