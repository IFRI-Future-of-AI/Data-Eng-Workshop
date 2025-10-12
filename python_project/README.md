# 🚕 Python Project - NYC Taxi Data Pipeline

> Un projet Python complet de Data Engineering pour télécharger, transformer et charger les données de taxis NYC dans PostgreSQL.

[![Python](https://img.shields.io/badge/Python-3.10+-blue?logo=python)](https://www.python.org/)
[![uv](https://img.shields.io/badge/uv-Package_Manager-green)](https://github.com/astral-sh/uv)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue?logo=postgresql)](https://www.postgresql.org/)
[![Polars](https://img.shields.io/badge/Polars-DataFrame-orange)](https://www.pola.rs/)

## 📋 Table des Matières

- [Vue d'ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Utilisation](#-utilisation)
- [Structure du Projet](#-structure-du-projet)
- [Modules](#-modules)
- [Configuration](#-configuration)
- [Bonnes Pratiques](#-bonnes-pratiques)

---

## 🎯 Vue d'ensemble

Ce projet implémente un **pipeline ETL complet** pour gérer les données publiques des taxis jaunes de New York City (NYC Yellow Taxi Trip Records). Il illustre les bonnes pratiques de Data Engineering en Python.

### Fonctionnalités

- ✅ **Téléchargement automatisé** : Récupération des données mensuelles depuis AWS S3
- ✅ **Gestion incrémentale** : Téléchargement uniquement des fichiers manquants
- ✅ **Transformation de données** : Utilisation de Polars pour des transformations rapides
- ✅ **Chargement PostgreSQL** : Ingestion automatique dans une base de données
- ✅ **Logging structuré** : Traçabilité complète de toutes les opérations
- ✅ **Gestion d'erreurs** : Robustesse face aux problèmes réseau et de données

---

## 🏗️ Architecture

Le projet suit une architecture modulaire classique en Data Engineering :

```
┌─────────────────┐
│   AWS S3        │  Données sources (Parquet)
│   (NYC Open     │
│    Data)        │
└────────┬────────┘
         │ download.py
         ▼
┌─────────────────┐
│  Local Storage  │  Stockage temporaire
│  ./data/        │
└────────┬────────┘
         │ save.py
         ▼
┌─────────────────┐
│  PostgreSQL     │  Base de données cible
│  (workshop)     │
└─────────────────┘
```

### Flux de données

1. **Download** : Téléchargement des fichiers Parquet depuis AWS
2. **Storage** : Sauvegarde locale dans `./data/yellow_tripdata/`
3. **Schema Generation** : Détection automatique du schéma avec Polars
4. **Database Creation** : Création des tables PostgreSQL
5. **Data Loading** : Chargement par batch dans PostgreSQL

---

## 📋 Prérequis

- **Python** 3.10 ou supérieur
- **uv** - Gestionnaire de packages rapide ([Installation](https://github.com/astral-sh/uv))
- **PostgreSQL** 15+ avec base de données accessible
- **Docker** (optionnel) - Pour lancer PostgreSQL localement

### Vérifier les prérequis

```bash
# Python version
python --version  # >= 3.10

# uv installé
uv --version

# PostgreSQL accessible
psql --version
```

---

## ⚡ Installation

### 1. Cloner le repository

```bash
git clone https://github.com/IFRI-Future-of-AI/Data-Eng-Workshop.git
cd Data-Eng-Workshop/python_project
```

### 2. Configurer l'environnement

Créer un fichier `.env` avec vos identifiants PostgreSQL :

```bash
POSTGRESQL_HOST=localhost
POSTGRESQL_PORT=5432
POSTGRESQL_DATABASE=workshop
POSTGRESQL_USER=postgres
POSTGRESQL_PASSWORD=postgres
```

> **Note** : Le fichier `.env` est déjà présent avec des valeurs par défaut.

### 3. Installer les dépendances

Avec **uv** (recommandé) :

```bash
# Créer un environnement virtuel et installer les dépendances
uv venv
source .venv/bin/activate  # Linux/Mac
# ou
.venv\Scripts\activate  # Windows

# Installer les dépendances
uv pip install -e .
```

Avec **pip** (alternative) :

```bash
pip install -r pyproject.toml
```

### 4. Lancer PostgreSQL (si nécessaire)

Si vous n'avez pas PostgreSQL installé, utilisez Docker :

```bash
# Depuis la racine du projet
cd ..
docker compose up -d
```

---

## 🚀 Utilisation

### Exécution du pipeline complet

```bash
python main.py
```

### Workflow détaillé

Le script `main.py` exécute automatiquement :

1. **Téléchargement des zones de taxi** (`download_taxi_zones()`)
2. **Téléchargement des données mensuelles** (`download_data_month_to_month()`)
   - Période : Novembre 2023 à Octobre 2025
   - Format : Parquet
3. **Chargement dans PostgreSQL** (`save_all_files_in_folder_in_postgresql_database()`)

### Utilisation personnalisée

Vous pouvez modifier `main.py` pour ajuster la période de téléchargement :

```python
from src import (
    download_data_month_to_month, 
    save_all_files_in_folder_in_postgresql_database,
    download_taxi_zones
)

def main():
    # Télécharger les zones de taxi
    download_taxi_zones()
    
    # Télécharger une période personnalisée
    download_data_month_to_month(
        start_month='2024-01',  # Janvier 2024
        end_month='2024-12'     # Décembre 2024
    )
    
    # Charger dans PostgreSQL
    save_all_files_in_folder_in_postgresql_database()

if __name__ == "__main__":
    main()
```

---

## 📊 Structure du Projet

```
python_project/
├── data/                    # Données téléchargées (ignoré par Git)
│   └── yellow_tripdata/     # Fichiers Parquet mensuels
├── logs/                    # Logs structurés (ignoré par Git)
│   ├── download.log
│   ├── database.log
│   └── save.log
├── src/                     # Code source (package Python)
│   ├── __init__.py          # Initialisation du package
│   ├── constants.py         # Constantes et configuration
│   ├── database.py          # Connexion et gestion PostgreSQL
│   ├── download.py          # Téléchargement des données
│   ├── logger.py            # Configuration du logging
│   ├── save.py              # Sauvegarde dans PostgreSQL
│   ├── transform.py         # Transformations de données
│   └── visualize.py         # Visualisations (Plotly)
├── .env                     # Variables d'environnement (ne pas committer)
├── .gitignore               # Fichiers ignorés par Git
├── .python-version          # Version Python (pour pyenv/uv)
├── main.py                  # Point d'entrée principal
├── pyproject.toml           # Configuration du projet et dépendances
├── uv.lock                  # Lockfile des dépendances
└── README.md                # Ce fichier
```

---

## 🧩 Modules

### 1. `constants.py` - Configuration centralisée

```python
# URLs et chemins
NYC_TRIPS_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/..."
TAXI_ZONE_URL = "https://d37ci6vzurychx.cloudfront.net/misc/..."
DATABASE_NAME = "workshop"

# Mapping de types pour PostgreSQL
SCHEMA_MAPPING = {
    'String': 'VARCHAR',
    'Int64': 'BIGINT',
    'Float64': 'DOUBLE PRECISION',
    'Datetime': 'TIMESTAMP',
}
```

### 2. `logger.py` - Logging structuré

Fournit une fonction de configuration du logging :

```python
logger = configure_logging(
    log_file="download.log",
    logger_name="download"
)
```

**Caractéristiques** :
- Logs dans fichier + console
- Format standardisé avec timestamp
- Séparation par module

### 3. `download.py` - Téléchargement de données

**Fonctions principales** :

- `download_taxi_zones()` : Télécharge le fichier de référence des zones
- `download_data_month_to_month()` : Téléchargement par plage de dates
- `download_data_for_month()` : Téléchargement d'un mois spécifique
- `verify_if_file_already_downloaded()` : Évite les téléchargements redondants

**Exemple** :

```python
from src.download import download_data_month_to_month

# Télécharger 6 mois de données
download_data_month_to_month(
    start_month='2024-01',
    end_month='2024-06'
)
```

### 4. `database.py` - Gestion PostgreSQL

**Fonctions principales** :

- `connect_to_postgresql_database()` : Connexion à PostgreSQL
- `create_database_in_postgresql_database()` : Création de base de données

**Exemple** :

```python
from src.database import connect_to_postgresql_database

conn = connect_to_postgresql_database(database_name="workshop")
# Utiliser la connexion...
conn.close()
```

### 5. `save.py` - Chargement dans PostgreSQL

**Fonctions principales** :

- `generate_file_schema_for_postgresql_database()` : Détection automatique du schéma
- `create_table_in_postgresql_database()` : Création de tables
- `save_file_in_postgresql_database()` : Chargement d'un fichier
- `save_all_files_in_folder_in_postgresql_database()` : Chargement batch

**Workflow** :

1. Scan du dossier `./data/yellow_tripdata/`
2. Pour chaque fichier Parquet :
   - Génération du schéma PostgreSQL
   - Création de la table (avec `DROP IF EXISTS`)
   - Chargement des données (100 premières lignes pour demo)

### 6. `transform.py` - Transformations

Module pour les transformations de données avec Polars.

### 7. `visualize.py` - Visualisations

Module pour créer des visualisations avec Plotly.

---

## ⚙️ Configuration

### Variables d'environnement (.env)

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `POSTGRESQL_HOST` | Hôte PostgreSQL | `localhost` |
| `POSTGRESQL_PORT` | Port PostgreSQL | `5432` |
| `POSTGRESQL_DATABASE` | Base de données par défaut | `workshop` |
| `POSTGRESQL_USER` | Utilisateur PostgreSQL | `postgres` |
| `POSTGRESQL_PASSWORD` | Mot de passe PostgreSQL | `postgres` |

### Personnaliser les constantes

Éditez `src/constants.py` pour modifier :

- URLs de téléchargement
- Dossiers de stockage
- Mapping de types SQL

---

## 🎓 Bonnes Pratiques Implémentées

Ce projet illustre plusieurs bonnes pratiques de Data Engineering :

### 1. **Architecture modulaire**
- ✅ Séparation claire des responsabilités (download, database, save)
- ✅ Code réutilisable dans le package `src/`
- ✅ Point d'entrée unique (`main.py`)

### 2. **Gestion de configuration**
- ✅ Variables d'environnement avec `.env`
- ✅ Constantes centralisées dans `constants.py`
- ✅ Fichier `.env` non versionné (dans `.gitignore`)

### 3. **Logging et observabilité**
- ✅ Logging structuré par module
- ✅ Logs dans fichier ET console
- ✅ Niveaux de log appropriés (INFO, ERROR, WARNING)

### 4. **Robustesse**
- ✅ Gestion des erreurs avec try/except
- ✅ Vérification de l'existence des fichiers
- ✅ Validation des statuts HTTP
- ✅ Création automatique des dossiers

### 5. **Performance**
- ✅ Utilisation de Polars (plus rapide que Pandas)
- ✅ Format Parquet (compression efficace)
- ✅ Téléchargement incrémental
- ✅ Chargement par batch

### 6. **Documentation**
- ✅ Docstrings sur toutes les fonctions
- ✅ Type hints (typing)
- ✅ README complet
- ✅ Commentaires sur le code complexe

### 7. **Gestion de dépendances**
- ✅ Utilisation de `uv` (moderne et rapide)
- ✅ Fichier `pyproject.toml` (standard Python moderne)
- ✅ Lockfile `uv.lock` pour reproductibilité

### 8. **Version control**
- ✅ `.gitignore` adapté (données, logs, venv)
- ✅ Fichiers sensibles exclus (`.env`)
- ✅ Structure de projet propre

---

## 🔧 Dépannage

### Problème : Erreur de connexion PostgreSQL

```bash
# Vérifier que PostgreSQL est lancé
docker compose ps

# Tester la connexion manuellement
psql -h localhost -U postgres -d workshop
```

### Problème : Téléchargement échoue (403)

Certains mois peuvent ne pas être disponibles sur AWS. Le script log les erreurs et continue.

### Problème : Table déjà existante

Les tables sont automatiquement recréées (DROP IF EXISTS) pour éviter les conflits.

### Problème : Logs trop verbeux

Modifiez le niveau de log dans `logger.py` :

```python
logger = configure_logging(
    log_file="download.log",
    log_level=logging.WARNING  # Au lieu de INFO
)
```

---

## 📚 Ressources

### Documentation Python
- [Polars Documentation](https://pola-rs.github.io/polars-book/) - DataFrame rapide
- [psycopg2 Guide](https://www.psycopg.org/docs/) - PostgreSQL pour Python
- [SQLAlchemy Docs](https://docs.sqlalchemy.org/) - ORM et connexions DB
- [python-dotenv](https://pypi.org/project/python-dotenv/) - Gestion des .env

### Outils
- [uv Package Manager](https://github.com/astral-sh/uv) - Gestionnaire Python moderne
- [Docker PostgreSQL](https://hub.docker.com/_/postgres) - Image officielle

### Dataset
- [NYC TLC Trip Record Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page) - Données officielles
- [Data Dictionary](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf) - Description des colonnes

---

## 👤 Auteur

**Abraham KOLOBOE** - *Data Engineer & Formateur*

- GitHub: [@abrahamkoloboe27](https://github.com/abrahamkoloboe27)
- LinkedIn: [Abraham KOLOBOE](https://www.linkedin.com/in/abraham-zacharie-koloboe-data-science-ia-generative-llms-machine-learning/)
- Organisation: [IFRI Future of AI](https://github.com/IFRI-Future-of-AI)

---

## 📜 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](../LICENSE) pour plus de détails.

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Forkez le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Pushez sur la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

---

<div align="center">
  
**Créé dans le cadre du Data Engineering Workshop - IFRI Future of AI** 🎓

[⬆ Retour au Projet Principal](../README.md)

</div>
