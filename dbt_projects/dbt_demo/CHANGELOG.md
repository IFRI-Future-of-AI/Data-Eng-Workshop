# 📝 Changelog - Projet dbt Airlines

Historique des modifications et enrichissements du projet dbt.

---

## [2.0.0] - Décembre 2024 - 🎉 Enrichissement Complet

### 🆕 Ajouts Majeurs

#### Modèles SQL (13 nouveaux)
- **Staging** (5 nouveaux):
  - `stg_airports.sql` - Aéroports avec extraction JSONB et GPS
  - `stg_aircrafts.sql` - Appareils avec catégorisation autonomie
  - `stg_seats.sql` - Sièges avec position (fenêtre/couloir/milieu)
  - `stg_boarding_passes.sql` - Cartes embarquement avec parsing siège
  - `stg_ticket_flights.sql` - Segments vol avec catégorie prix

- **Intermediate** (3 nouveaux):
  - `int_flights_enriched.sql` - Vols enrichis (durées, retards, distances GPS)
  - `int_bookings_with_revenue.sql` - Réservations avec métriques revenus
  - `int_passenger_journeys.sql` - Parcours passagers complets

- **Marts** (5 nouveaux):
  - `fct_bookings.sql` - Fait des réservations (Finance)
  - `fct_flights.sql` - Fait des vols (Operations)
  - `dim_airports.sql` - Dimension aéroports
  - `dim_aircrafts.sql` - Dimension appareils
  - `dim_passengers.sql` - Dimension passagers avec lifetime value

#### Macros (6 nouvelles)
- `calculate_flight_duration()` - Calcul durées avec unité paramétrable
- `calculate_haversine_distance()` - Distance GPS entre 2 points
- `categorize_flight_status()` - Catégorisation statuts vols
- `extract_json_contact()` - Extraction données JSONB
- `generate_schema_name()` - Gestion schémas personnalisés
- `test_valid_airport_code()` - Test personnalisé codes IATA

#### Seeds (4 nouveaux)
- `flight_status_codes.csv` - Codes statuts avec catégories
- `fare_class_descriptions.csv` - Classes tarifaires avec services
- `airport_regions.csv` - Régions et types de hubs
- `aircraft_manufacturers.csv` - Constructeurs et spécifications

#### Analyses (5 nouvelles)
- `revenue_by_route.sql` - Rentabilité par route avec efficacité
- `flight_occupancy_rates.sql` - Taux remplissage avec catégories
- `passenger_loyalty_analysis.sql` - Segmentation RFM et lifetime value
- `seasonal_trends.sql` - Tendances avec croissance et indice saisonnalité
- `on_time_performance.sql` - Ponctualité par route et appareil

#### Documentation (9 fichiers)
- `README.md` - Documentation principale (280 lignes)
- `STRUCTURE.md` - Architecture détaillée (450 lignes)
- `QUICKSTART.md` - Guide démarrage rapide (220 lignes)
- `SUGGESTIONS.md` - Améliorations futures (400 lignes)
- `CHANGELOG.md` - Historique des modifications
- `models/README.md` - Guide des modèles (330 lignes)
- `seeds/README.md` - Documentation seeds (160 lignes)
- `analyses/README.md` - Guide analyses (280 lignes)
- Documentation YML enrichie (700+ lignes au total)

### 🔄 Modifications

#### Modèles Existants
- `stg_bookings.sql` - Conservé (déjà bien structuré)
- `stg_tickets.sql` - Conservé (déjà bien structuré)
- `stg_fligths.sql` - Conservé (déjà bien structuré)

#### Configuration
- **dbt_project.yml**:
  - Ajout configuration par couche (staging, intermediate, marts)
  - Ajout tags par domaine métier
  - Configuration seeds avec schéma dédié
  
- **models/schema.yml**:
  - Enrichissement avec 8 tables sources (vs 3 avant)
  - Ajout ~120 définitions de colonnes
  - Ajout ~80 tests (unique, not_null, relationships, accepted_values)

- **models/staging/_staging.yml**:
  - Documentation complète des 8 modèles staging
  - ~150 définitions de colonnes
  - Tests exhaustifs sur toutes les colonnes clés

### 📊 Statistiques du Changement

#### Avant (v1.0.0)
- 3 modèles staging
- 1 modèle silver
- 1 fichier de documentation YML
- 0 macros
- 1 seed (mock_data.csv)
- 0 analyses
- 1 README basique

#### Après (v2.0.0)
- **16 modèles SQL** (8 staging + 3 intermediate + 5 marts)
- **6 macros réutilisables**
- **4 seeds de référence**
- **5 analyses prêtes à l'emploi**
- **9 fichiers de documentation** (~2,120 lignes)
- **~80 tests de qualité**
- **Architecture en 3 couches** (staging → intermediate → marts)

#### Lignes de Code
- **SQL**: ~2,800 lignes
- **Documentation**: ~2,120 lignes
- **YAML**: ~1,200 lignes
- **Total**: ~6,120 lignes

### 🎯 Nouvelles Fonctionnalités

#### Calculs Avancés
- ✅ Durées de vol (réelles vs prévues)
- ✅ Calculs de retards (départ, arrivée)
- ✅ Distances géographiques (formule Haversine)
- ✅ Catégorisation automatique (retards, prix, performance)
- ✅ Window functions (ROW_NUMBER, LAG, LEAD, etc.)

#### Métriques Métier
- ✅ Lifetime value par passager
- ✅ Segmentation RFM (Récence, Fréquence, Montant)
- ✅ Taux d'occupation des vols
- ✅ Performance de ponctualité
- ✅ Tendances saisonnières

#### Qualité des Données
- ✅ Tests d'unicité sur clés primaires
- ✅ Tests de relations (foreign keys)
- ✅ Tests de valeurs acceptées (énumérations)
- ✅ Test personnalisé pour codes IATA
- ✅ Tests de non-nullité sur colonnes critiques

### 🏗️ Améliorations d'Architecture

#### Organisation
- ✅ Architecture en couches claire (staging → intermediate → marts)
- ✅ Organisation par domaine métier (finance, operations, customers)
- ✅ Séparation des concerns (nettoyage, enrichissement, analytics)
- ✅ Nomenclature cohérente (préfixes stg_, int_, fct_, dim_)

#### Performance
- ✅ Views pour staging (rapide)
- ✅ Tables pour intermediate et marts (optimisé pour requêtes)
- ✅ Indexation implicite via clés primaires
- ✅ Dénormalisation contrôlée dans marts

#### Maintenabilité
- ✅ Documentation exhaustive inline et externe
- ✅ Macros pour éviter duplication de code
- ✅ Tests automatisés pour validation continue
- ✅ Structure modulaire et scalable

---

## [1.0.0] - Octobre 2024 - 🌟 Version Initiale

### Contenu Initial

#### Modèles
- `stg_bookings.sql` - Modèle staging des réservations
- `stg_tickets.sql` - Modèle staging des billets
- `stg_fligths.sql` - Modèle staging des vols
- `tickets_with_bookings.sql` - Jointure tickets et bookings

#### Configuration
- Configuration de base dbt_project.yml
- Connexion PostgreSQL dans profiles.yml
- Schéma sources basique (3 tables)

#### Documentation
- README.md basique
- Documentation YML minimale

---

## 📈 Évolution des Métriques

| Métrique | v1.0.0 | v2.0.0 | Évolution |
|----------|---------|---------|-----------|
| Modèles SQL | 4 | 16 | +300% |
| Macros | 0 | 6 | ∞ |
| Seeds | 1 | 4 | +300% |
| Analyses | 0 | 5 | ∞ |
| Tests | ~10 | ~80 | +700% |
| Documentation (lignes) | ~100 | ~2,120 | +2,020% |
| Couches architecture | 2 | 3 | +50% |

---

## 🎯 Roadmap Future (v3.0.0)

Voir `SUGGESTIONS.md` pour liste complète.

### Priorités Court Terme
- [ ] Incremental models pour grandes tables
- [ ] Snapshots pour historisation (SCD Type 2)
- [ ] Tests de performance
- [ ] CI/CD avec GitHub Actions

### Priorités Moyen Terme
- [ ] Orchestration Airflow
- [ ] Monitoring avancé
- [ ] Data catalog integration
- [ ] Métriques dbt natives

### Priorités Long Terme
- [ ] dbt Cloud migration
- [ ] Machine learning features
- [ ] Reverse ETL
- [ ] Real-time streaming models

---

## 🤝 Contributeurs

### Version 2.0.0
- **Abraham KOLOBOE** - Enrichissement complet et documentation
- **IFRI Future of AI** - Support et review

### Version 1.0.0
- **Abraham KOLOBOE** - Création initiale du projet
- **IFRI Future of AI** - Workshop et formation

---

## 📚 Références

### Documentation Créée
- Architecture: `STRUCTURE.md`
- Démarrage: `QUICKSTART.md`
- Améliorations: `SUGGESTIONS.md`
- Modèles: `models/README.md`
- Seeds: `seeds/README.md`
- Analyses: `analyses/README.md`

### Standards Appliqués
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
- [dbt Style Guide](https://github.com/dbt-labs/corp/blob/main/dbt_style_guide.md)
- [SQL Style Guide](https://www.sqlstyle.guide/)

---

## 📝 Notes de Version

### Breaking Changes
Aucun breaking change - Rétrocompatibilité maintenue avec v1.0.0

### Migrations Nécessaires
Aucune migration nécessaire - Nouveaux modèles s'ajoutent aux existants

### Dépendances
- dbt-core >= 1.0.0
- dbt-postgres >= 1.0.0
- PostgreSQL >= 12.0

---

**Merci d'avoir contribué au projet dbt Airlines! 🚀**

*Pour toute question, consulter la documentation ou contacter l'équipe Data Engineering Workshop*
