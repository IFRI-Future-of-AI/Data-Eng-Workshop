# 📁 Scripts SQL Avancés - Airlines Database

Ce dossier contient les scripts SQL avancés pour l'analyse de la base de données Airlines Demo.

## 📋 Contenu du Dossier

### 🎯 **Windows Functions.sql** ⭐
**Guide complet des fonctions window en SQL**

Le fichier principal créé pour répondre à la demande. Il contient :

#### 🏆 Fonctions de Classement
- `ROW_NUMBER()` - Numérotation séquentielle unique
- `RANK()` - Classement avec ex-aequos (avec trous)
- `DENSE_RANK()` - Classement dense sans trous

#### 🔄 Fonctions de Décalage
- `LAG()` - Accès aux valeurs précédentes
- `LEAD()` - Accès aux valeurs suivantes

#### 🎯 Fonctions de Valeur
- `FIRST_VALUE()` - Première valeur de la fenêtre
- `LAST_VALUE()` - Dernière valeur de la fenêtre  
- `NTH_VALUE()` - Nième valeur de la fenêtre

#### 📊 Fonctions d'Agrégation Window
- `SUM() OVER` - Sommes cumulatives et fenêtres glissantes
- `AVG() OVER` - Moyennes mobiles
- `COUNT() OVER` - Comptages sur fenêtres

#### 📈 Fonctions Statistiques
- `PERCENT_RANK()` - Rang en pourcentage
- `CUME_DIST()` - Distribution cumulative
- `NTILE()` - Segmentation en groupes égaux

#### 🚀 Exemples Avancés
- Analyses complètes combinant plusieurs fonctions
- Cas d'usage métier réalistes
- Optimisations et bonnes pratiques

---

### 📄 Autres Fichiers

- **`CTE-VS-Subqueries.sql`** - Comparaison CTE vs sous-requêtes
- **`Dates Functions.sql`** - Fonctions de manipulation de dates
- **`Query-Prod-Example.sql`** - Exemples de requêtes production
- **`Request.sql`** - Requêtes de base du workshop
- **`sql-seance-1.sql`** - Scripts de la première session
- **`tests.sql`** - Scripts de test

## 🎓 Utilisation

### Prérequis
- PostgreSQL (base de données Airlines Demo chargée)
- Accès en lecture aux tables : `flights`, `bookings`, `tickets`, `airports`, etc.

### Exécution
```sql
-- Copier-coller les sections qui vous intéressent
-- Chaque exemple est autonome et documenté
-- Les commentaires expliquent chaque fonction
```

## 🎯 Objectifs Pédagogiques

Ce guide permet d'apprendre :
- ✅ **Syntaxe complète** des fonctions window
- ✅ **Cas d'usage pratiques** avec données réalistes
- ✅ **Différences entre fonctions** et quand les utiliser
- ✅ **Optimisation** et bonnes pratiques
- ✅ **Exemples complexes** combinant plusieurs fonctions

## 🔍 Navigation Rapide

| Section | Contenu | Lignes |
|---------|---------|---------|
| **1. Classement** | ROW_NUMBER, RANK, DENSE_RANK | 14-89 |
| **2. Décalage** | LAG, LEAD | 90-135 |
| **3. Valeurs** | FIRST_VALUE, LAST_VALUE, NTH_VALUE | 136-201 |
| **4. Agrégation** | SUM, AVG, COUNT sur fenêtres | 202-297 |
| **5. Statistiques** | PERCENT_RANK, CUME_DIST, NTILE | 298-350 |
| **6. Avancé** | Exemples complexes combinés | 351-412 |
| **7. Documentation** | Notes importantes et conseils | 413-443 |

## 💡 Conseils d'Utilisation

1. **Commencez par les bases** : ROW_NUMBER et RANK
2. **Testez chaque exemple** sur votre base de données
3. **Modifiez les PARTITION BY** selon vos besoins d'analyse
4. **Attention aux performances** sur les gros volumes
5. **Utilisez les index** sur les colonnes PARTITION BY et ORDER BY

---
*Créé dans le cadre du Data Engineering Workshop - IFRI Future of AI*