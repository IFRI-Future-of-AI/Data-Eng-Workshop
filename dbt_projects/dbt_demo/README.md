# 🛩️ Projet dbt Airlines - Data Engineering Workshop

Bienvenue dans le projet dbt Airlines ! Ce projet transforme les données brutes d'une compagnie aérienne en un data warehouse analytique structuré.

## 🎯 Vue d'ensemble

Ce projet implémente une architecture de données moderne en 3 couches (Bronze/Silver/Gold) pour analyser:
- ✈️ Les opérations de vols (ponctualité, retards, annulations)
- 🎫 Les réservations et revenus
- 👥 Le comportement des passagers
- 🏢 La performance des aéroports et appareils

## 📚 Documentation complète

Pour une documentation détaillée de l'architecture, consultez [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)

## 🚀 Démarrage rapide

### Prérequis
- Python 3.7+
- PostgreSQL (via Docker Compose du projet principal)
- dbt-core et dbt-postgres installés

### Installation

```bash
# Installer dbt (si nécessaire)
pip install dbt-core dbt-postgres

# Vérifier la connexion
dbt debug

# Charger les données de référence
dbt seed

# Exécuter tous les modèles
dbt run

# Exécuter les tests
dbt test

# Générer et visualiser la documentation
dbt docs generate
dbt docs serve
```

## 📊 Structure du projet

### Couches de données

1. **Bronze (Staging)** - models/stagging/
   - 8 modèles de staging (views)
   - Nettoyage et standardisation des données sources
   - Extraction des données JSON

2. **Silver (Intermediate)** - models/silvers/
   - 6 modèles intermédiaires (tables)
   - Jointures et enrichissements
   - Calculs de métriques métier

3. **Gold (Analytics)** - models/golds/
   - 6 modèles analytiques (tables)
   - 2 tables de faits, 4 tables de dimension
   - Prêt pour le BI et reporting

### Composants additionnels

- **7 Macros** - Fonctions réutilisables pour transformations
- **3 Seeds** - Données de référence (statuts, classes tarifaires)
- **5 Analyses** - Requêtes analytiques prêtes à l'emploi
- **5 Tests personnalisés** - Validation de la qualité des données

## 👥 Contributeurs

**IFRI Future of AI** - Data Engineering Workshop
