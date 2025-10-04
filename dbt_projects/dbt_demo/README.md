# 🚀 Projet dbt - Airlines Database

> Projet dbt complet pour l'analyse de données d'une compagnie aérienne. Implémente une architecture en couches (staging → intermediate → marts) avec modèles, tests, macros et analyses.

[![dbt](https://img.shields.io/badge/dbt-1.0+-orange.svg)](https://www.getdbt.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue?logo=postgresql)](https://www.postgresql.org/)

---

## 📋 Table des Matières

- [Vue d'ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Démarrage Rapide](#-démarrage-rapide)
- [Structure du Projet](#-structure-du-projet)
- [Modèles Disponibles](#-modèles-disponibles)
- [Macros et Tests](#-macros-et-tests)
- [Analyses](#-analyses)
- [Documentation](#-documentation)

---

## 🎯 Vue d'ensemble

Ce projet dbt transforme les données brutes de la base Airlines en modèles analytiques prêts pour le reporting et la BI. Il couvre l'ensemble du pipeline de données depuis le nettoyage jusqu'aux métriques métier.

### Domaines Couverts

- 💰 **Finance**: Revenus, réservations, segmentation client
- ✈️ **Opérations**: Performance des vols, ponctualité, flotte
- 👥 **Clients**: Fidélisation, parcours passagers, préférences

---

## 🏗️ Architecture

```
📦 dbt_demo
├── 📁 models/
│   ├── 📄 schema.yml              # Définition des sources
│   ├── 📁 staging/                # Couche 1: Nettoyage (views)
│   │   ├── stg_bookings.sql
│   │   ├── stg_tickets.sql
│   │   ├── stg_flights.sql
│   │   ├── stg_airports.sql
│   │   ├── stg_aircrafts.sql
│   │   ├── stg_seats.sql
│   │   ├── stg_boarding_passes.sql
│   │   ├── stg_ticket_flights.sql
│   │   └── _staging.yml
│   ├── 📁 intermediate/           # Couche 2: Enrichissement (tables)
│   │   ├── int_flights_enriched.sql
│   │   ├── int_bookings_with_revenue.sql
│   │   ├── int_passenger_journeys.sql
│   │   └── _intermediate.yml
│   └── 📁 marts/                  # Couche 3: Analytics (tables)
│       ├── 📁 finance/
│       │   └── fct_bookings.sql
│       ├── 📁 operations/
│       │   ├── fct_flights.sql
│       │   ├── dim_airports.sql
│       │   └── dim_aircrafts.sql
│       ├── 📁 customers/
│       │   └── dim_passengers.sql
│       └── _marts.yml
├── 📁 macros/                     # Macros réutilisables
│   ├── calculate_flight_duration.sql
│   ├── categorize_flight_status.sql
│   ├── extract_json_contact.sql
│   ├── calculate_haversine_distance.sql
│   ├── generate_schema_name.sql
│   └── test_valid_airport_code.sql
├── 📁 seeds/                      # Données de référence (CSV)
│   ├── flight_status_codes.csv
│   ├── fare_class_descriptions.csv
│   ├── airport_regions.csv
│   └── aircraft_manufacturers.csv
├── 📁 analyses/                   # Requêtes analytiques
│   ├── revenue_by_route.sql
│   ├── flight_occupancy_rates.sql
│   ├── passenger_loyalty_analysis.sql
│   ├── seasonal_trends.sql
│   └── on_time_performance.sql
└── 📁 tests/                      # Tests personnalisés
```

---

## 🚀 Démarrage Rapide

### Prérequis

- PostgreSQL 15+ avec base Airlines chargée
- dbt-core 1.0+
- Python 3.8+

### Installation

1. **Installer dbt**
   ```bash
   pip install dbt-postgres
   ```

2. **Configurer le profil**
   
   Vérifier `profiles.yml`:
   ```yaml
   dbt_demo:
     outputs:
       dev:
         type: postgres
         host: localhost
         port: 5432
         user: postgres
         pass: postgres
         dbname: demo
         schema: bookings
     target: dev
   ```

3. **Tester la connexion**
   ```bash
   cd dbt_projects/dbt_demo
   dbt debug
   ```

### Exécution

```bash
# Pipeline complet
dbt seed      # Charger les données de référence
dbt run       # Créer tous les modèles
dbt test      # Exécuter les tests de qualité

# Ou en une commande
dbt build

# Générer et visualiser la documentation
dbt docs generate
dbt docs serve
```

---

## 📊 Structure du Projet

### Couche 1: Staging

**Matérialisation**: Views  
**Objectif**: Nettoyer et standardiser les données sources

- ✅ Extraction de JSONB (noms multilingues)
- ✅ Standardisation des noms de colonnes
- ✅ Filtrage des données invalides
- ✅ Ajout de métadonnées de traçabilité

### Couche 2: Intermediate

**Matérialisation**: Tables  
**Objectif**: Enrichir et consolider les données

- ✅ Calculs de durées et retards
- ✅ Calculs de distances géographiques
- ✅ Agrégations par entité métier
- ✅ Enrichissement avec dimensions

### Couche 3: Marts

**Matérialisation**: Tables  
**Objectif**: Modèles finaux optimisés pour l'analyse

- ✅ **Facts**: Événements métier (vols, réservations)
- ✅ **Dimensions**: Référentiels (aéroports, appareils, passagers)
- ✅ Organisation par domaine métier

---

## 📦 Modèles Disponibles

### Staging (8 modèles)

| Modèle | Description | Clé |
|--------|-------------|-----|
| `stg_bookings` | Réservations | book_ref |
| `stg_tickets` | Billets | ticket_no |
| `stg_fligths` | Vols | flight_id |
| `stg_airports` | Aéroports | airport_code |
| `stg_aircrafts` | Appareils | aircraft_code |
| `stg_seats` | Sièges | aircraft_code, seat_no |
| `stg_boarding_passes` | Cartes embarquement | ticket_no, flight_id |
| `stg_ticket_flights` | Segments de vol | ticket_no, flight_id |

### Intermediate (3 modèles)

| Modèle | Description |
|--------|-------------|
| `int_flights_enriched` | Vols + aéroports + appareils + calculs |
| `int_bookings_with_revenue` | Réservations + revenus + passagers |
| `int_passenger_journeys` | Parcours complets des passagers |

### Marts (5 modèles)

| Domaine | Modèle | Type |
|---------|--------|------|
| Finance | `fct_bookings` | Fait |
| Operations | `fct_flights` | Fait |
| Operations | `dim_airports` | Dimension |
| Operations | `dim_aircrafts` | Dimension |
| Customers | `dim_passengers` | Dimension |

---

## 🔧 Macros et Tests

### Macros Disponibles

- `calculate_flight_duration()` - Calcule durées de vol
- `categorize_flight_status()` - Catégorise statuts
- `extract_json_contact()` - Extrait données JSONB
- `calculate_haversine_distance()` - Distance GPS
- `test_valid_airport_code()` - Test personnalisé codes IATA

### Tests Implémentés

- ✅ Unicité des clés primaires
- ✅ Non-nullité des colonnes critiques
- ✅ Relations (foreign keys)
- ✅ Valeurs acceptées (énumérations)
- ✅ Tests personnalisés (codes IATA)

---

## 📈 Analyses

5 analyses prêtes à l'emploi:

1. **revenue_by_route** - Routes les plus rentables
2. **flight_occupancy_rates** - Taux de remplissage
3. **passenger_loyalty_analysis** - Segmentation clients
4. **seasonal_trends** - Tendances saisonnières
5. **on_time_performance** - Ponctualité des vols

Voir `analyses/README.md` pour détails.

---

## 📚 Documentation

Chaque dossier contient un README détaillé:

- 📖 `models/README.md` - Guide complet des modèles
- 🌱 `seeds/README.md` - Documentation des seeds
- 📈 `analyses/README.md` - Guide des analyses

### Générer la documentation interactive

```bash
dbt docs generate
dbt docs serve
```

Ouvre un site web avec:
- Lineage des modèles (DAG)
- Documentation complète
- Dictionnaire de données
- Tests et leurs statuts

---

## 🎓 Commandes Utiles

```bash
# Exécuter par couche
dbt run --select staging
dbt run --select intermediate
dbt run --select marts

# Exécuter par domaine
dbt run --select marts.finance
dbt run --select marts.operations

# Exécuter avec tests
dbt build --select staging

# Tester un modèle
dbt test --select stg_bookings

# Compiler une analyse
dbt compile --select analysis:revenue_by_route

# Debug
dbt debug
```

---

## 🎯 KPIs Disponibles

Les modèles permettent de calculer ces KPIs:

### Finance
- Revenus totaux et par période
- Revenu par passager
- Distribution par classe tarifaire
- Segmentation de valeur client

### Opérations
- Taux de ponctualité
- Retards moyens
- Taux d'occupation des vols
- Performance par route/appareil

### Clients
- Lifetime value
- Nombre de vols par passager
- Classe préférée
- Taux de rétention

---

## 🤝 Contribution

Pour contribuer:

1. Créer une branche feature
2. Ajouter votre modèle/analyse
3. Documenter dans le README approprié
4. Ajouter des tests
5. Soumettre une PR

---

## 📜 Licence

MIT License - Voir LICENSE

---

## 🔗 Ressources

### dbt
- [Documentation officielle](https://docs.getdbt.com/)
- [Best Practices](https://docs.getdbt.com/guides/best-practices)
- [Community](https://community.getdbt.com/)

### Projet
- [GitHub Repository](https://github.com/IFRI-Future-of-AI/Data-Eng-Workshop)
- [Documentation Database](../../Database.md)
- [Exercices SQL](../../Request.md)

---

**Créé par Abraham KOLOBOE dans le cadre du Data Engineering Workshop - IFRI Future of AI** 🎓
