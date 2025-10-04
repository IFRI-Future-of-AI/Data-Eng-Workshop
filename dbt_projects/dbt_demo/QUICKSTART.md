# ⚡ Guide de Démarrage Rapide - dbt Airlines

Ce guide vous permettra d'être opérationnel en 5 minutes avec le projet dbt.

---

## 📋 Prérequis (2 minutes)

### 1. Vérifier PostgreSQL

Assurez-vous que la base de données Airlines est accessible:

```bash
psql -h localhost -p 5432 -U postgres -d demo
```

Credentials par défaut:
- **Host**: localhost
- **Port**: 5432
- **Database**: demo
- **Schema**: bookings
- **User**: postgres
- **Password**: postgres

### 2. Installer dbt

```bash
# Avec pip
pip install dbt-postgres

# Avec conda
conda install -c conda-forge dbt-postgres

# Vérifier l'installation
dbt --version
```

---

## 🚀 Démarrage (3 minutes)

### Étape 1: Naviguer vers le projet

```bash
cd dbt_projects/dbt_demo
```

### Étape 2: Tester la connexion

```bash
dbt debug
```

✅ Si tout est OK, vous devriez voir "All checks passed!"

### Étape 3: Exécuter le pipeline complet

```bash
# Option 1: Pipeline complet (seeds + run + test)
dbt build

# Option 2: Étape par étape
dbt seed      # 1. Charger les données de référence
dbt run       # 2. Créer tous les modèles
dbt test      # 3. Valider la qualité des données
```

⏱️ Temps d'exécution estimé: 2-3 minutes

### Étape 4: Visualiser les résultats

```bash
# Générer et ouvrir la documentation interactive
dbt docs generate
dbt docs serve
```

Ouvre automatiquement votre navigateur sur http://localhost:8080

---

## 🎯 Commandes Essentielles

### Exécution par couche

```bash
# Staging uniquement (views - rapide)
dbt run --select staging

# Intermediate (tables - moyen)
dbt run --select intermediate

# Marts (tables finales - moyen)
dbt run --select marts
```

### Exécution par domaine métier

```bash
# Finance
dbt run --select marts.finance

# Opérations
dbt run --select marts.operations

# Clients
dbt run --select marts.customers
```

### Tests

```bash
# Tous les tests
dbt test

# Tests d'un modèle spécifique
dbt test --select stg_bookings

# Tests d'une couche
dbt test --select staging
```

### Analyses

```bash
# Compiler une analyse (génère le SQL)
dbt compile --select analysis:revenue_by_route

# Le SQL compilé est dans: target/compiled/dbt_demo/analyses/
```

---

## 📊 Premiers Pas avec les Données

### 1. Consulter les modèles staging

```sql
-- Dans votre client SQL (DBeaver, pgAdmin, etc.)

-- Voir les réservations
SELECT * FROM staging.stg_bookings LIMIT 10;

-- Voir les vols
SELECT * FROM staging.stg_fligths LIMIT 10;

-- Voir les aéroports avec coordonnées
SELECT 
    airport_code,
    airport_name,
    city_name,
    latitude,
    longitude
FROM staging.stg_airports;
```

### 2. Explorer les modèles intermediate

```sql
-- Vols enrichis avec détails
SELECT 
    flight_no,
    departure_city,
    arrival_city,
    actual_flight_duration_hours,
    delay_category
FROM intermediate.int_flights_enriched
WHERE delay_category != 'À l''heure'
LIMIT 20;

-- Réservations avec revenus
SELECT 
    booking_year_month,
    SUM(total_booking_amount) as monthly_revenue,
    COUNT(*) as bookings_count
FROM intermediate.int_bookings_with_revenue
GROUP BY booking_year_month
ORDER BY booking_year_month;
```

### 3. Utiliser les marts

```sql
-- Top 10 des routes par revenus
SELECT 
    departure_airport_code,
    arrival_airport_code,
    COUNT(*) as flights_count
FROM marts.fct_flights
GROUP BY departure_airport_code, arrival_airport_code
ORDER BY flights_count DESC
LIMIT 10;

-- Passagers VIP
SELECT 
    passenger_name,
    total_flights_taken,
    lifetime_value,
    preferred_cabin_class
FROM marts.dim_passengers
WHERE lifetime_value > 100000
ORDER BY lifetime_value DESC;
```

---

## 🎨 Visualiser le Lineage

Dans la documentation dbt (http://localhost:8080):

1. Cliquez sur un modèle (ex: `fct_bookings`)
2. En bas à droite, cliquez sur "View Lineage Graph"
3. Explorez les dépendances en amont et en aval

---

## 🐛 Résolution de Problèmes

### Erreur: "Database not found"

```bash
# Vérifier la connexion
dbt debug

# Vérifier PostgreSQL
docker ps  # Si utilisation de Docker
```

### Erreur: "Compilation Error"

```bash
# Nettoyer les artefacts
dbt clean

# Recompiler
dbt compile
```

### Tests échouent

```bash
# Voir les détails des tests qui échouent
dbt test --store-failures

# Les résultats sont dans target/run_results.json
```

### Modèle trop lent

```bash
# Voir les temps d'exécution
cat target/run_results.json | grep "execution_time"

# Exécuter un seul modèle
dbt run --select nom_du_modele
```

---

## 📈 Prochaines Étapes

### 1. Explorer les analyses

```bash
# Compiler toutes les analyses
for analysis in analyses/*.sql; do
    dbt compile --select "analysis:$(basename $analysis .sql)"
done

# Exécuter le SQL compilé dans votre client SQL
```

### 2. Créer votre premier modèle

```sql
-- models/marts/custom/my_analysis.sql
{{
    config(
        materialized = 'table',
        schema = 'marts',
        tags = ['custom']
    )
}}

SELECT
    booking_year_month,
    SUM(total_booking_amount) as revenue
FROM {{ ref('fct_bookings') }}
GROUP BY booking_year_month
```

```bash
# Exécuter votre modèle
dbt run --select my_analysis
```

### 3. Connecter un outil BI

- **Metabase**: Connecter à PostgreSQL, pointer vers schéma `marts`
- **Power BI**: Utiliser connecteur PostgreSQL
- **Tableau**: Connecter via pilote PostgreSQL
- **Looker**: Définir connexion dans LookML

---

## 🎓 Apprentissage

### Documentation recommandée

1. **Architecture**: Lire `STRUCTURE.md`
2. **Modèles**: Lire `models/README.md`
3. **Analyses**: Lire `analyses/README.md`

### Tutoriels dbt

- [dbt Learn](https://courses.getdbt.com/)
- [dbt Discourse](https://discourse.getdbt.com/)
- [dbt Slack](https://community.getdbt.com/)

### Exercices pratiques

1. Créer un nouveau modèle staging
2. Ajouter une analyse personnalisée
3. Créer une macro pour un calcul récurrent
4. Ajouter des tests sur vos modèles

---

## ✅ Checklist de Validation

Vérifiez que tout fonctionne:

- [ ] `dbt debug` passe tous les checks
- [ ] `dbt seed` charge les seeds sans erreur
- [ ] `dbt run` crée tous les modèles (16 models)
- [ ] `dbt test` passe tous les tests (~80 tests)
- [ ] `dbt docs serve` ouvre la documentation
- [ ] Vous pouvez interroger les marts dans SQL

---

## 🆘 Besoin d'Aide ?

1. **Documentation du projet**: Lire les README dans chaque dossier
2. **Documentation dbt**: https://docs.getdbt.com/
3. **Logs dbt**: Consulter `logs/dbt.log`
4. **Communauté**: https://community.getdbt.com/

---

**Félicitations! Vous êtes prêt à utiliser dbt! 🎉**

*Guide créé pour le Data Engineering Workshop - IFRI Future of AI*
