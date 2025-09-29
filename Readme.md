# 🛩️ Data Engineering Workshop - Airlines Database

> A practical Data Engineering workshop with SQL pipelines & exercises for learning database management and query optimization.

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue?logo=postgresql)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

## 📋 Table des Matières

- [🎯 Objectif du Workshop](#-objectif-du-workshop)
- [🏗️ Architecture de la Base de Données](#️-architecture-de-la-base-de-données)
- [🚀 Démarrage Rapide](#-démarrage-rapide)
- [📊 Structure du Projet](#-structure-du-projet)
- [💡 Exercices SQL](#-exercices-sql)
- [📚 Ressources](#-ressources)
- [👤 Auteur](#-auteur)
- [📜 Licence](#-licence)

## 🎯 Objectif du Workshop

Ce workshop propose une approche pratique de l'ingénierie des données à travers :
- **Manipulation de données** avec PostgreSQL
- **Requêtes SQL avancées** (JOINs, agrégations, fonctions window)
- **Pipeline de données** avec Docker
- **Analyse de données** sur un dataset réaliste d'une compagnie aérienne

## 🏗️ Architecture de la Base de Données

Le workshop utilise une base de données de démonstration **Airlines** simulant le système d'une compagnie aérienne :

### 📊 Schéma Principal

![Schéma de la base de données Airlines](assets/schema.png)

### 🗄️ Tables Principales

| Table | Description | Rôle |
|-------|-------------|------|
| **bookings** | Réservations principales | Point central des réservations |
| **tickets** | Billets individuels | Un billet par passager |
| **ticket_flights** | Segments de vol | Correspondances et trajets multiples |
| **flights** | Vols programmés | Informations de vol complètes |
| **airports** | Aéroports | Données géographiques et codes |
| **aircrafts** | Modèles d'avions | Spécifications techniques |
| **seats** | Configuration des sièges | Plan de cabine par appareil |
| **boarding_passes** | Cartes d'embarquement | Attribution des sièges |

### 🔄 Relations Principales
- **1 réservation** → **N billets** (plusieurs passagers)
- **1 billet** → **N segments de vol** (correspondances)
- **1 vol** → **1 appareil** → **N sièges**
- **1 siège** → **1 carte d'embarquement** par vol

## 🚀 Démarrage Rapide

### 📋 Prérequis

- [Docker](https://www.docker.com/get-started) et Docker Compose
- [Git](https://git-scm.com/)
- Un client PostgreSQL (optionnel) : [pgAdmin](https://www.pgadmin.org/), [DBeaver](https://dbeaver.io/)

### ⚡ Installation

1. **Cloner le repository :**
   ```bash
   git clone https://github.com/IFRI-Future-of-AI/Data-Eng-Workshop.git
   cd Data-Eng-Workshop
   ```

2. **Lancer la base de données :**
   ```bash
   docker compose up -d
   ```

3. **Vérifier le déploiement :**
   ```bash
   docker compose ps
   ```

### 🔗 Connexion à la Base

| Paramètre | Valeur |
|-----------|--------|
| **Host** | `localhost` |
| **Port** | `5432` |
| **Database** | `postgres` |
| **Username** | `postgres` |
| **Password** | `postgres` |

## 📊 Structure du Projet

```
Data-Eng-Workshop/
├── 📁 assets/          # Images et diagrammes
│   └── schema.png      # Schéma de la base de données
├── 📁 data/            # Données de démonstration
│   └── demo-small-en.sql
├── 📁 pdf/             # Présentations du workshop
├── 📁 sql/             # Scripts SQL avancés
├── 📄 Database.md      # Documentation du schéma
├── 📄 Request.md       # Exercices SQL détaillés
├── 🐳 docker-compose.yml  # Configuration Docker
└── 📖 README.md        # Ce fichier
```

## 💡 Exercices SQL

### 🎯 Niveau Débutant
- ✅ **Sélection simple** : Afficher tous les vols
- ✅ **Filtrage** : Vols au départ d'un aéroport spécifique
- ✅ **Tri et limitation** : Les 5 derniers vols enregistrés
- ✅ **Agrégation** : Nombre total de tickets émis

### 🎯 Niveau Intermédiaire
- ✅ **INNER JOIN** : Vols avec noms d'aéroports
- ✅ **CROSS JOIN** : Combinaisons vol-appareil
- ✅ **Cast de types** : Conversion de dates en texte
- ✅ **CASE WHEN** : Catégorisation des statuts

### 🎯 Niveau Avancé
- ✅ **COALESCE** : Gestion des valeurs nulles
- ✅ **JSON** : Extraction de données de contact
- ✅ **Fonctions window** : Analyses temporelles
- ✅ **CTE** : Requêtes complexes structurées

### 📝 Accès aux Exercices

Consultez le fichier [Request.md](Request.md) pour tous les exercices SQL avec :
- 📋 **Énoncés détaillés**
- 💻 **Requêtes SQL complètes**
- 🎯 **Objectifs pédagogiques**
- 🔍 **Solutions expliquées**

## 📚 Ressources

### 📖 Documentation
- [Documentation PostgreSQL](https://www.postgresql.org/docs/)
- [Guide SQL pour Débutants](https://www.w3schools.com/sql/)
- [Docker Compose Guide](https://docs.docker.com/compose/)

### 🔧 Outils Recommandés
- **IDE SQL** : [DBeaver](https://dbeaver.io/), [pgAdmin](https://www.pgadmin.org/)
- **Client Terminal** : `psql`
- **Visualisation** : [Grafana](https://grafana.com/), [Metabase](https://www.metabase.com/)

### 📊 Dataset
Le dataset Airlines contient :
- **✈️ Vols** : Horaires, statuts, routes
- **🎫 Réservations** : Données clients et billets
- **🛫 Aéroports** : Codes IATA, géolocalisation
- **🛩️ Appareils** : Modèles et configurations

## 👤 Auteur

**Abraham KOLOBOE** - *Data Engineer & Formateur*

- GitHub: [@abrahamkoloboe27](https://github.com/abrahamkoloboe27)
- LinkedIn: [Abraham KOLOBOE](https://linkedin.com/in/abraham-koloboe)
- Organisation: [IFRI Future of AI](https://github.com/IFRI-Future-of-AI)

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Forkez le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Pushez sur la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📜 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

<div align="center">
  
  **⭐ Si ce workshop vous a été utile, n'hésitez pas à lui donner une étoile !**
  
  Made with ❤️ by [IFRI Future of AI](https://github.com/IFRI-Future-of-AI)
  
</div>
