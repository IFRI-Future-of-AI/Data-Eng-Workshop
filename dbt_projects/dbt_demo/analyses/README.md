# 📈 Analyses - Requêtes Analytiques

## 📋 Vue d'ensemble

Le dossier `analyses/` contient des requêtes SQL analytiques prêtes à l'emploi qui exploitent les modèles dbt pour générer des insights métier. Ces analyses ne créent pas de tables mais peuvent être exécutées à la demande pour des rapports.

---

## 📊 Analyses Disponibles

### 1. revenue_by_route.sql

**Objectif**: Identifier les routes aériennes les plus rentables.

**Métriques calculées**:
- Revenus totaux par route
- Nombre de passagers
- Nombre de vols
- Prix moyen du billet
- Revenu par vol
- Revenu par kilomètre (efficacité)
- Classement par revenus et efficacité

**Cas d'usage**:
- Optimisation du réseau de routes
- Planification de nouvelles lignes
- Identification des routes sous-performantes

**Exemple de sortie**:
```
route           | city_route              | total_revenue | revenue_rank
----------------|-------------------------|---------------|-------------
DME → LED       | Moscow → St Petersburg  | 15,234,500   | 1
SVO → KZN       | Moscow → Kazan         | 12,876,300   | 2
```

---

### 2. flight_occupancy_rates.sql

**Objectif**: Analyser le taux de remplissage des avions pour optimiser la capacité.

**Métriques calculées**:
- Capacité totale des sièges
- Sièges réservés
- Sièges vides
- Taux d'occupation (%)
- Catégories de remplissage (Complet, Quasi-complet, Bon, Moyen, Faible)

**Cas d'usage**:
- Gestion de la capacité
- Optimisation de la flotte
- Stratégies de pricing dynamique
- Identification des vols sous-performants

**Exemple de sortie**:
```
route           | avg_occupancy_rate | total_flights | full_flights | low_occupancy_flights
----------------|-------------------|---------------|--------------|----------------------
LED → DME       | 87.5%            | 234          | 45           | 12
```

---

### 3. passenger_loyalty_analysis.sql

**Objectif**: Segmenter les passagers selon leur fidélité et valeur.

**Métriques calculées**:
- Segmentation RFM (Récence, Fréquence, Montant)
- Lifetime value par segment
- Type de voyageur (Business, Frequent Economy, Leisure)
- Part du chiffre d'affaires par segment
- Métriques moyennes par segment

**Segments de fidélité**:
- **VIP Elite**: ≥20 vols et ≥100,000 en dépenses
- **Fidèle Premium**: ≥10 vols et ≥50,000 en dépenses
- **Régulier**: ≥5 vols et ≥20,000 en dépenses
- **Occasionnel**: ≥2 vols
- **Nouveau**: 1 vol

**Cas d'usage**:
- Programme de fidélisation
- Marketing personnalisé
- Prévision de churn
- Stratégies de rétention

**Exemple de sortie**:
```
loyalty_segment | traveler_type      | passenger_count | total_segment_revenue | revenue_share_pct
----------------|-------------------|----------------|----------------------|------------------
VIP Elite       | Business Traveler | 234            | 23,456,789          | 34.5%
```

---

### 4. seasonal_trends.sql

**Objectif**: Identifier les tendances saisonnières des réservations.

**Métriques calculées**:
- Réservations et revenus par mois
- Croissance mensuelle (%)
- Moyenne mobile sur 3 mois
- Indice de saisonnalité
- Catégories de saisons (Haute, Normale, Basse)

**Cas d'usage**:
- Planification de capacité
- Stratégies de pricing saisonnier
- Prévisions de revenus
- Gestion du personnel

**Exemple de sortie**:
```
month_name | total_revenue | revenue_growth_pct | seasonality_index | season_category
-----------|---------------|-------------------|-------------------|----------------
Juillet    | 45,678,900   | +15.3%           | 125.4             | Haute saison
Janvier    | 28,456,100   | -8.7%            | 78.2              | Basse saison
```

---

### 5. on_time_performance.sql

**Objectif**: Évaluer la ponctualité des vols par route et appareil.

**Métriques calculées**:
- Taux de ponctualité (vols à l'heure ≤15 min)
- Retard moyen et médian
- Taux de retards sévères (>60 min)
- Performance par route
- Performance par modèle d'appareil

**Catégories de performance**:
- **À l'heure**: ≤0 min de retard
- **Acceptable**: 1-15 min
- **Retardé**: 16-60 min
- **Très retardé**: >60 min

**Cas d'usage**:
- Amélioration opérationnelle
- Identification des routes problématiques
- Maintenance prédictive
- Satisfaction client

**Exemple de sortie**:
```
route           | total_flights | on_time_rate_pct | avg_delay_minutes | severe_delay_rate_pct
----------------|---------------|-----------------|-------------------|----------------------
LED → DME       | 456           | 87.3%           | 8.5               | 2.1%
```

---

## 🚀 Utilisation

### Compiler une analyse
```bash
# Compile le SQL sans l'exécuter
dbt compile --select analysis:revenue_by_route
```

Le SQL compilé se trouve dans `target/compiled/dbt_demo/analyses/`

### Exécuter manuellement
1. Compiler l'analyse avec dbt
2. Copier le SQL compilé
3. Exécuter dans votre outil SQL (DBeaver, pgAdmin, etc.)

### Automatiser avec un script
```bash
# Exemple de script pour exécuter toutes les analyses
for analysis in analyses/*.sql; do
    echo "Compiling $analysis..."
    dbt compile --select "analysis:$(basename $analysis .sql)"
done
```

---

## 📊 Visualisation des Résultats

### Outils recommandés

1. **Power BI / Tableau**
   - Connecter directement aux modèles marts
   - Créer des dashboards interactifs

2. **Metabase / Redash**
   - Importer les requêtes compilées
   - Créer des visualisations

3. **Jupyter Notebook**
   ```python
   import pandas as pd
   from sqlalchemy import create_engine
   
   engine = create_engine('postgresql://...')
   df = pd.read_sql_file('compiled/revenue_by_route.sql', engine)
   ```

---

## 🎯 Ajout de Nouvelles Analyses

Pour créer une nouvelle analyse:

1. **Créer le fichier SQL**
   ```bash
   touch analyses/my_new_analysis.sql
   ```

2. **Utiliser les modèles dbt**
   ```sql
   -- analyses/my_new_analysis.sql
   SELECT
       col1,
       col2,
       COUNT(*) as metric
   FROM {{ ref('fct_bookings') }}
   GROUP BY col1, col2
   ```

3. **Documenter dans ce README**
   - Objectif
   - Métriques
   - Cas d'usage

4. **Tester**
   ```bash
   dbt compile --select analysis:my_new_analysis
   ```

---

## 📋 Checklist des Bonnes Pratiques

- ✅ Utiliser `{{ ref() }}` pour référencer les modèles
- ✅ Commenter le SQL pour expliquer la logique
- ✅ Nommer les colonnes de manière explicite
- ✅ Limiter les résultats si nécessaire (LIMIT)
- ✅ Optimiser les performances (indexes, partitions)
- ✅ Documenter l'objectif et les cas d'usage
- ✅ Tester sur des données de production

---

## 💡 Exemples d'Insights Métier

### Routes à développer
```sql
-- Identifier les routes avec haute demande mais peu de vols
SELECT * FROM revenue_by_route
WHERE on_time_rate_pct > 80
AND total_flights < 50
ORDER BY total_passengers DESC
```

### Segments clients à cibler
```sql
-- Passagers "Réguliers" proches de devenir "Fidèle Premium"
SELECT * FROM passenger_loyalty_analysis
WHERE loyalty_segment = 'Régulier'
AND lifetime_value > 40000
```

---

## 🔄 Fréquence de Rafraîchissement

| Analyse | Fréquence Recommandée |
|---------|----------------------|
| revenue_by_route | Hebdomadaire |
| flight_occupancy_rates | Quotidien |
| passenger_loyalty_analysis | Mensuel |
| seasonal_trends | Mensuel |
| on_time_performance | Quotidien |

---

## 🤝 Contribution

Vous avez une idée d'analyse utile ? Créez-la et partagez-la !

1. Créer le fichier `.sql`
2. Tester avec des données réelles
3. Documenter dans ce README
4. Soumettre une pull request

---

**Créé dans le cadre du Data Engineering Workshop - IFRI Future of AI**
